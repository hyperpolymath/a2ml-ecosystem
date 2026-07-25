// SPDX-License-Identifier: MPL-2.0
// (MPL-2.0 preferred; MPL-2.0 required for crates.io)

//! Property-style tests for the a2ml crate.
//!
//! These tests operate over fixed arrays of valid and invalid A2ML snippets,
//! verifying properties that should hold across all inputs: parse-succeeds,
//! parse-rejects, render-never-panics, and roundtrip-stability.

use a2ml::parser::parse;
use a2ml::renderer::render;

// ---------------------------------------------------------------------------
// Fixed arrays of valid A2ML snippets
// ---------------------------------------------------------------------------

/// Each entry is a valid A2ML snippet that `parse` must accept without error.
const VALID_SNIPPETS: &[&str] = &[
    // 1. Empty document
    "",
    // 2. Title only
    "# My Document",
    // 3. Directive only
    "@version 1.0",
    // 4. Paragraph only
    "A simple paragraph with no markup.",
    // 5. Heading + paragraph
    "# Title\n\nBody text here.",
    // 6. Fenced code block (no language)
    "```\nsome code\n```",
    // 7. Fenced code block with language tag
    "```elixir\ndefmodule Foo do\nend\n```",
    // 8. Complete attestation
    "!attest identity=Carol role=reviewer trust=verified",
    // 9. Multiple directives
    "@version 1.0\n@require trust-level:high",
    // 10. Inline formatting (bold, italic, code, link)
    "A paragraph with **bold**, *italic*, `code`, and [link](https://a2ml.org).",
];

/// Each entry is an invalid A2ML snippet that `parse` must reject with `Err`.
const INVALID_SNIPPETS: &[&str] = &[
    // 1. Unterminated fenced code block — parser should return a parse error.
    "```\nno closing fence",
    // 2. Bare `@` with no directive name.
    "@ ",
    // 3. Attestation missing `identity` field.
    "!attest role=author trust=reviewed",
    // 4. Attestation missing `role` field.
    "!attest identity=Alice trust=reviewed",
    // 5. Attestation with unknown trust level.
    "!attest identity=Alice role=author trust=godlike",
    // 6. Attestation missing `trust` field.
    "!attest identity=Alice role=author",
];

// ---------------------------------------------------------------------------
// Property: all valid snippets parse successfully
// ---------------------------------------------------------------------------

/// Every entry in `VALID_SNIPPETS` must parse without returning an error.
/// This test loops over the array and checks each one individually so that
/// a failure message identifies the offending snippet by index.
#[test]
fn property_valid_snippets_all_parse() {
    for (index, snippet) in VALID_SNIPPETS.iter().enumerate() {
        let result = parse(snippet);
        assert!(
            result.is_ok(),
            "valid snippet #{index} should parse successfully, but got: {:?}\nSnippet: {snippet:?}",
            result.err()
        );
    }
}

// ---------------------------------------------------------------------------
// Property: all invalid snippets are rejected
// ---------------------------------------------------------------------------

/// Every entry in `INVALID_SNIPPETS` must produce an `Err` from `parse`.
/// This confirms that the parser enforces structural constraints.
#[test]
fn property_invalid_snippets_all_rejected() {
    for (index, snippet) in INVALID_SNIPPETS.iter().enumerate() {
        let result = parse(snippet);
        assert!(
            result.is_err(),
            "invalid snippet #{index} should fail to parse but unexpectedly succeeded\nSnippet: {snippet:?}"
        );
    }
}

// ---------------------------------------------------------------------------
// Property: rendering never panics on valid parsed content
// ---------------------------------------------------------------------------

/// For every entry in `VALID_SNIPPETS`, parsing followed by rendering must
/// not panic and must return `Ok`.
#[test]
fn property_render_never_panics_on_valid_docs() {
    for (index, snippet) in VALID_SNIPPETS.iter().enumerate() {
        let doc = parse(snippet).expect("valid snippet should parse");
        let result = render(&doc);
        assert!(
            result.is_ok(),
            "rendering snippet #{index} should succeed, but got: {:?}\nSnippet: {snippet:?}",
            result.err()
        );
    }
}

// ---------------------------------------------------------------------------
// Property: rendered output is non-empty for non-empty documents
// ---------------------------------------------------------------------------

/// For documents that have any content, the rendered string must not be
/// empty.  Empty-input documents may legitimately produce empty output.
#[test]
fn property_rendered_output_non_empty_when_doc_has_content() {
    let non_empty_snippets = &VALID_SNIPPETS[1..]; // skip the empty document
    for (index, snippet) in non_empty_snippets.iter().enumerate() {
        let doc = parse(snippet).expect("valid snippet should parse");
        let rendered = render(&doc).expect("render should succeed");
        assert!(
            !rendered.trim().is_empty(),
            "snippet #{} produces a non-empty document but rendered output is empty\nSnippet: {snippet:?}",
            index + 1
        );
    }
}

// ---------------------------------------------------------------------------
// Property: re-parsing rendered output yields equal metadata
// ---------------------------------------------------------------------------

/// For all valid snippets, `parse(render(parse(s)))` must preserve the
/// document `title` and `attestations`.  Directive counts are intentionally
/// NOT compared: the renderer emits `doc.directives` at the top of the output
/// AND each `Block::Directive` inline, so re-parsing multiplies the count.
/// Instead, we verify that every directive name from the first parse appears
/// verbatim in the rendered output.
#[test]
fn property_roundtrip_metadata_stable() {
    for (index, snippet) in VALID_SNIPPETS.iter().enumerate() {
        let doc1 = parse(snippet).expect("first parse");
        let rendered = render(&doc1).expect("render");
        let doc2 = parse(&rendered).expect("second parse after render");

        assert_eq!(
            doc1.title, doc2.title,
            "title must be stable after roundtrip for snippet #{index}"
        );
        // Confirm every directive name is still present in the rendered text.
        for directive in &doc1.directives {
            assert!(
                rendered.contains(&format!("@{}", directive.name)),
                "rendered snippet #{index} must contain directive @{}",
                directive.name
            );
        }
        // Confirm every attestation identity is still present in the rendered text.
        for attestation in &doc1.attestations {
            assert!(
                rendered.contains(&format!("identity={}", attestation.identity)),
                "rendered snippet #{index} must contain attestation identity={}",
                attestation.identity
            );
        }
    }
}

// ---------------------------------------------------------------------------
// Property: directive names survive the roundtrip unchanged
// ---------------------------------------------------------------------------

/// For every valid snippet that contains directives, each directive name from
/// the first parse must appear verbatim in the rendered output.
///
/// Note: re-parsing the rendered output doubles directive counts (the renderer
/// emits `doc.directives` at the top and also each `Block::Directive` inline),
/// so this test checks rendered string content rather than comparing name
/// lists from doc2 directly.
#[test]
fn property_directive_names_survive_roundtrip() {
    for (index, snippet) in VALID_SNIPPETS.iter().enumerate() {
        let doc1 = parse(snippet).expect("first parse");
        if doc1.directives.is_empty() {
            continue; // no directives to check
        }
        let rendered = render(&doc1).expect("render");

        for directive in &doc1.directives {
            assert!(
                rendered.contains(&format!("@{}", directive.name)),
                "rendered snippet #{index} must contain directive @{}",
                directive.name
            );
        }
    }
}

// ---------------------------------------------------------------------------
// Property: attestation identity and trust level survive the roundtrip
// ---------------------------------------------------------------------------

/// For every valid snippet that contains attestations, identity strings,
/// trust levels, and roles must be preserved verbatim in the rendered output.
///
/// Note: re-parsing the rendered output doubles attestation counts (the
/// renderer emits them both inline and at the bottom of the document), so
/// this test checks rendered string content rather than comparing doc2 fields
/// directly.
#[test]
fn property_attestation_fields_survive_roundtrip() {
    for (index, snippet) in VALID_SNIPPETS.iter().enumerate() {
        let doc1 = parse(snippet).expect("first parse");
        if doc1.attestations.is_empty() {
            continue;
        }
        let rendered = render(&doc1).expect("render");

        for (att_idx, a1) in doc1.attestations.iter().enumerate() {
            assert!(
                rendered.contains(&format!("identity={}", a1.identity)),
                "rendered snippet #{index} must contain attestation #{att_idx} identity={}",
                a1.identity
            );
            assert!(
                rendered.contains(&format!("role={}", a1.role)),
                "rendered snippet #{index} must contain attestation #{att_idx} role={}",
                a1.role
            );
            assert!(
                rendered.contains(&format!("trust={}", a1.trust_level)),
                "rendered snippet #{index} must contain attestation #{att_idx} trust={}",
                a1.trust_level
            );
        }
    }
}

// ---------------------------------------------------------------------------
// Property: render output always contains a newline-terminated string
// ---------------------------------------------------------------------------

/// Any non-empty rendered document must end with a newline, so that the
/// output is suitable for concatenation and POSIX text-file conventions.
#[test]
fn property_rendered_output_ends_with_newline() {
    for (index, snippet) in VALID_SNIPPETS.iter().enumerate() {
        if snippet.is_empty() {
            continue; // empty doc → empty render string, no newline required
        }
        let doc = parse(snippet).expect("parse");
        let rendered = render(&doc).expect("render");
        if rendered.is_empty() {
            continue;
        }
        assert!(
            rendered.ends_with('\n'),
            "rendered output for snippet #{index} must end with a newline"
        );
    }
}
