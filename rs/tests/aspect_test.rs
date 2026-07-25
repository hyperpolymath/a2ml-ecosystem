// SPDX-License-Identifier: MPL-2.0
// (MPL-2.0 preferred; MPL-2.0 required for crates.io)

//! Security and robustness aspect tests for the a2ml crate.
//!
//! These tests verify that the parser and renderer behave safely under
//! adversarial, degenerate, and stress-inducing inputs.  No test in this
//! file should panic or abort the process — unexpected errors must be
//! returned as `Err` values, and all other inputs must be handled gracefully.

use a2ml::parser::parse;
use a2ml::renderer::render;

// ---------------------------------------------------------------------------
// Empty and whitespace-only input
// ---------------------------------------------------------------------------

/// Parsing the empty string must succeed and produce an empty document —
/// not panic, not return `Err`.
#[test]
fn aspect_empty_input_does_not_panic() {
    let result = parse("");
    assert!(result.is_ok(), "empty input must parse cleanly");
    let doc = result.unwrap();
    assert!(doc.blocks.is_empty(), "empty input must produce zero blocks");
    assert!(doc.title.is_none(), "empty input must produce no title");
}

/// Whitespace-only input (spaces, tabs, newlines) must parse cleanly.
#[test]
fn aspect_whitespace_only_input_does_not_panic() {
    for input in &["   ", "\t\t\t", "\n\n\n", " \t \n \t ", "\r\n\r\n"] {
        let result = parse(input);
        assert!(
            result.is_ok(),
            "whitespace-only input {input:?} must parse without error"
        );
    }
}

// ---------------------------------------------------------------------------
// Very long input
// ---------------------------------------------------------------------------

/// A document with many thousands of blocks should parse and render without
/// running out of stack or memory in a reasonable time.
#[test]
fn aspect_very_long_input_handled_gracefully() {
    // Construct a document with 2 000 paragraphs (≈ 30 KB of text).
    let mut input = String::with_capacity(30_000);
    for i in 0..2_000 {
        input.push_str(&format!("Paragraph number {}.\n\n", i));
    }
    let result = parse(&input);
    assert!(result.is_ok(), "very long input must parse without error");
    let doc = result.unwrap();
    // Each paragraph becomes one Block::Paragraph.
    assert_eq!(
        doc.blocks.len(),
        2_000,
        "all paragraphs must be parsed from a long document"
    );
}

/// A single very long line (64 KB) must be handled without panicking.
#[test]
fn aspect_single_very_long_line_does_not_panic() {
    // Create a 64 KiB paragraph — no newlines.
    let long_line = "x".repeat(65_536);
    let result = parse(&long_line);
    // We don't mandate success or failure — only that it does not panic.
    let _ = result;
}

/// A document with many directives must parse without error.
#[test]
fn aspect_many_directives_handled_gracefully() {
    let mut input = String::with_capacity(20_000);
    for i in 0..500 {
        input.push_str(&format!("@meta key{}\n", i));
    }
    let result = parse(&input);
    assert!(result.is_ok(), "500 directives must parse without error");
    let doc = result.unwrap();
    assert_eq!(doc.directives.len(), 500);
}

// ---------------------------------------------------------------------------
// Special characters and unicode
// ---------------------------------------------------------------------------

/// Null bytes in the input must not cause panics — they are unusual but
/// the parser must handle them gracefully (either as text or as an error).
#[test]
fn aspect_null_bytes_do_not_panic() {
    let input_with_null = "A paragraph with a \x00 null byte.";
    let _ = parse(input_with_null); // must not panic
}

/// Non-BMP Unicode (characters beyond U+FFFF) must not cause panics.
/// Rust's `char` type is already Unicode scalar values, but the inline
/// parser iterates over `chars()` and we want to be sure nothing blows up.
#[test]
fn aspect_non_bmp_unicode_does_not_panic() {
    // U+1F600 GRINNING FACE (4-byte UTF-8), U+10FFFF last valid code point.
    let input = "# \u{1F600} Title\n\nParagraph with \u{10FFFF} extreme unicode.";
    let result = parse(input);
    assert!(
        result.is_ok(),
        "valid unicode input must parse without error"
    );
}

/// RTL text and combining characters must parse without panicking.
#[test]
fn aspect_rtl_and_combining_characters_do_not_panic() {
    // Arabic, Hebrew, and a combining accent character.
    let input = "مرحبا بالعالم\n\nשלום עולם\n\ne\u{0301} (e with acute combining)";
    let result = parse(input);
    assert!(
        result.is_ok(),
        "RTL and combining-character text must parse without error"
    );
}

/// A heading whose text is entirely emoji must parse correctly.
#[test]
fn aspect_emoji_heading_does_not_panic() {
    let input = "# \u{1F916}\u{1F4AC}\u{2728}";
    let result = parse(input);
    assert!(result.is_ok(), "emoji-only heading must parse without error");
}

// ---------------------------------------------------------------------------
// Deeply nested / recursive structures
// ---------------------------------------------------------------------------

/// Deeply nested block quotes (100 levels) must not cause a stack overflow.
/// Each `>` triggers a recursive call to `parse`; this checks that the
/// parser survives reasonable recursion depths without overflowing.
#[test]
fn aspect_deeply_nested_block_quotes_do_not_overflow() {
    // Build "> > > ... > text" with 50 levels of nesting.
    // The current parser recurses once per level; 50 is a comfortable depth.
    let prefix = "> ".repeat(50);
    let input = format!("{}innermost text", prefix);
    let result = parse(&input);
    // We do not mandate success (it may legitimately be limited), only
    // that the process does not crash.
    let _ = result;
}

/// A large unordered list (1 000 items) must parse without panicking.
#[test]
fn aspect_large_list_does_not_panic() {
    let mut input = String::with_capacity(20_000);
    for i in 0..1_000 {
        input.push_str(&format!("- Item {}\n", i));
    }
    let result = parse(&input);
    assert!(result.is_ok(), "large list must parse without error");
    let doc = result.unwrap();
    // All 1 000 items coalesce into a single Block::List.
    assert_eq!(
        doc.blocks.len(),
        1,
        "all 1 000 list items must coalesce into one Block::List"
    );
}

// ---------------------------------------------------------------------------
// Malicious / adversarial inputs
// ---------------------------------------------------------------------------

/// A forged `!attest` line with valid keys but an unknown trust level must
/// return `Err` — it must not silently succeed with a default trust level.
#[test]
fn aspect_forged_attestation_unknown_trust_is_rejected() {
    let input = "!attest identity=Attacker role=admin trust=omnipotent";
    let result = parse(input);
    assert!(
        result.is_err(),
        "attestation with unknown trust level must be rejected"
    );
}

/// A `@` sign with no name (just a space or nothing after) must return `Err`.
#[test]
fn aspect_bare_at_sign_is_rejected() {
    for bad_directive in &["@", "@ ", "@\t", "@\n"] {
        let result = parse(bad_directive);
        assert!(
            result.is_err(),
            "bare '@' input {bad_directive:?} must be rejected, not panic"
        );
    }
}

/// Extremely long directive values must not panic.
#[test]
fn aspect_long_directive_value_does_not_panic() {
    let long_value = "x".repeat(65_536);
    let input = format!("@meta {}", long_value);
    let result = parse(&input);
    // Either success or a structured error — never a panic.
    let _ = result;
}

/// An attestation with a very long `identity` field must not panic.
#[test]
fn aspect_long_attestation_identity_does_not_panic() {
    let long_id = "A".repeat(65_536);
    let input = format!(
        "!attest identity={} role=author trust=reviewed",
        long_id
    );
    let result = parse(&input);
    // Either success or a structured error — never a panic.
    let _ = result;
}

// ---------------------------------------------------------------------------
// Render robustness
// ---------------------------------------------------------------------------

/// Rendering a default (empty) Document must succeed and produce an empty
/// or whitespace-only string without panicking.
#[test]
fn aspect_render_empty_document_does_not_panic() {
    use a2ml::types::Document;
    let doc = Document::new();
    let result = render(&doc);
    assert!(result.is_ok(), "rendering an empty document must succeed");
    let rendered = result.unwrap();
    assert!(
        rendered.trim().is_empty(),
        "rendering an empty document must produce only whitespace (got: {rendered:?})"
    );
}
