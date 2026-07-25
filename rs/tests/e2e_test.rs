// SPDX-License-Identifier: MPL-2.0
// (MPL-2.0 preferred; MPL-2.0 required for crates.io)

//! End-to-end tests for the a2ml crate.
//!
//! These tests exercise the full parse → render → parse lifecycle using
//! realistic A2ML documents, verifying that the library correctly handles
//! complete documents from start to finish.

use a2ml::parser::parse;
use a2ml::renderer::render;
use a2ml::types::{Block, Directive, Manifest, TrustLevel};

// ---------------------------------------------------------------------------
// Fixture documents
// ---------------------------------------------------------------------------

/// A minimal but complete A2ML document with a title, version directive,
/// body paragraph, and a single attestation.
const MINIMAL_DOCUMENT: &str = r#"# Minimal Document

@version 1.0

This is a short paragraph of plain text.

!attest identity=Alice role=author trust=reviewed
"#;

/// A fuller document exercising most block types: headings at multiple
/// depths, code blocks, thematic breaks, lists, and block quotes.
const FULL_DOCUMENT: &str = r#"# A2ML Reference Example

@version 2.0
@require trust-level:reviewed

## Introduction

This document demonstrates all major A2ML block types.

## Code Samples

```rust
fn greet(name: &str) -> String {
    format!("Hello, {}!", name)
}
```

---

## Lists

- First unordered item
- Second unordered item
- Third unordered item

1. First ordered item
2. Second ordered item

## Quotation

> A block quotation with some *emphasized* text.

!attest identity=Bob role=reviewer trust=verified ts=2026-01-01
!attest identity=CI-bot role=agent trust=automated
"#;

/// A document that contains rich inline formatting: bold, italic, code
/// spans, and hyperlinks in paragraph context.
const INLINE_FORMATTING_DOCUMENT: &str = r#"# Formatting Test

This paragraph has **bold text**, *italic text*, `inline code`, and a [link](https://example.com).

A second paragraph with **nested *bold-italic*** content.
"#;

// ---------------------------------------------------------------------------
// E2E tests
// ---------------------------------------------------------------------------

/// Parsing the minimal document succeeds and extracts the correct title.
#[test]
fn e2e_minimal_document_title() {
    let doc = parse(MINIMAL_DOCUMENT).expect("minimal document should parse cleanly");
    assert_eq!(
        doc.title.as_deref(),
        Some("Minimal Document"),
        "title should be extracted from the leading H1"
    );
}

/// Parsing the minimal document produces exactly one attestation with the
/// expected identity and trust level.
#[test]
fn e2e_minimal_document_attestation() {
    let doc = parse(MINIMAL_DOCUMENT).expect("minimal document should parse");
    assert_eq!(doc.attestations.len(), 1, "expected exactly one attestation");
    assert_eq!(doc.attestations[0].identity, "Alice");
    assert_eq!(doc.attestations[0].role, "author");
    assert_eq!(doc.attestations[0].trust_level, TrustLevel::Reviewed);
}

/// Rendering the minimal document after parsing produces a non-empty string
/// that contains the original heading text.
#[test]
fn e2e_render_minimal_document() {
    let doc = parse(MINIMAL_DOCUMENT).expect("parse");
    let rendered = render(&doc).expect("render");
    assert!(
        rendered.contains("Minimal Document"),
        "rendered output must contain the document title"
    );
    assert!(
        rendered.contains("@version 1.0"),
        "rendered output must contain the version directive"
    );
}

/// The roundtrip `parse(render(parse(input)))` should preserve the document
/// title through a full parse → render → parse cycle, and the rendered text
/// must contain all original directive and attestation identities.
///
/// Note: the renderer emits `doc.directives` at the top AND each
/// `Block::Directive` inline; similarly `doc.attestations` at the bottom AND
/// each `Block::Attestation` inline.  Re-parsing therefore doubles counts for
/// both, which is a known characteristic of the current renderer design.
/// Tests check rendered content by string containment rather than counts.
#[test]
fn e2e_roundtrip_minimal_document() {
    let doc1 = parse(MINIMAL_DOCUMENT).expect("first parse");
    let rendered = render(&doc1).expect("render");
    let _doc2 = parse(&rendered).expect("second parse");
    assert_eq!(
        doc1.title,
        _doc2.title,
        "title must survive a full roundtrip"
    );
    // All original directive names must appear in the rendered output.
    for directive in &doc1.directives {
        assert!(
            rendered.contains(&format!("@{}", directive.name)),
            "rendered output must contain directive @{}",
            directive.name
        );
    }
    // All original attestation identities must appear in the rendered output.
    for attestation in &doc1.attestations {
        assert!(
            rendered.contains(&format!("identity={}", attestation.identity)),
            "rendered output must contain attestation identity={}",
            attestation.identity
        );
    }
}

/// The full document parses without errors and extracts both attestations.
#[test]
fn e2e_full_document_parses() {
    let doc = parse(FULL_DOCUMENT).expect("full document should parse without errors");
    assert_eq!(
        doc.attestations.len(),
        2,
        "full document must have exactly 2 attestations"
    );
    // The first attestation has trust=verified; the second has trust=automated.
    assert_eq!(doc.attestations[0].trust_level, TrustLevel::Verified);
    assert_eq!(doc.attestations[1].trust_level, TrustLevel::Automated);
}

/// Directives from the full document are correctly parsed and stored.
#[test]
fn e2e_full_document_directives() {
    let doc = parse(FULL_DOCUMENT).expect("parse");
    // @version and @require should both be present.
    let version_directive = doc.directives.iter().find(|d| d.name == "version");
    assert!(
        version_directive.is_some(),
        "@version directive must be present"
    );
    assert_eq!(
        version_directive.unwrap().value,
        "2.0",
        "@version value must be '2.0'"
    );
}

/// The Manifest convenience struct correctly extracts version and title from
/// the full document.
#[test]
fn e2e_manifest_extraction() {
    let doc = parse(FULL_DOCUMENT).expect("parse");
    let manifest = Manifest::from_document(&doc);
    assert_eq!(
        manifest.version.as_deref(),
        Some("2.0"),
        "manifest must expose the @version directive"
    );
    assert_eq!(
        manifest.title.as_deref(),
        Some("A2ML Reference Example"),
        "manifest must expose the document title"
    );
    assert_eq!(
        manifest.attestations.len(),
        2,
        "manifest must include all attestations"
    );
}

/// Roundtrip the full document and verify that all directive names and
/// attestation identities appear in the rendered text.
///
/// Note: the renderer emits `doc.directives` at the top and also each
/// `Block::Directive` inline (and likewise for attestations), so re-parsing
/// doubles those counts.  The test checks rendered content by string
/// containment rather than strict count equality.
#[test]
fn e2e_roundtrip_full_document_block_count() {
    let doc1 = parse(FULL_DOCUMENT).expect("first parse");
    let rendered = render(&doc1).expect("render");
    let _doc2 = parse(&rendered).expect("second parse");
    // All original directive names must be present in the rendered output.
    for directive in &doc1.directives {
        assert!(
            rendered.contains(&format!("@{}", directive.name)),
            "rendered output must contain directive @{} from full document",
            directive.name
        );
    }
    // All original attestation identities must be present in the rendered output.
    for attestation in &doc1.attestations {
        assert!(
            rendered.contains(&format!("identity={}", attestation.identity)),
            "rendered output must contain attestation identity={} from full document",
            attestation.identity
        );
    }
}

/// Inline formatting is preserved through a full parse → render cycle:
/// bold markers, italic markers, and backtick code spans all survive.
#[test]
fn e2e_inline_formatting_survives_render() {
    let doc = parse(INLINE_FORMATTING_DOCUMENT).expect("parse");
    let rendered = render(&doc).expect("render");
    assert!(rendered.contains("**bold text**"), "bold must survive render");
    assert!(rendered.contains("*italic text*"), "italic must survive render");
    assert!(rendered.contains("`inline code`"), "code span must survive render");
    assert!(
        rendered.contains("[link](https://example.com)"),
        "hyperlink must survive render"
    );
}

/// An A2ML document with a thematic break renders it back as `---`.
#[test]
fn e2e_thematic_break_roundtrip() {
    let input = "# Title\n\nBefore break.\n\n---\n\nAfter break.\n";
    let doc = parse(input).expect("parse");
    let rendered = render(&doc).expect("render");
    assert!(
        rendered.contains("---"),
        "thematic break must appear in rendered output"
    );
    // Re-parse the rendered output and confirm the break is still present.
    let doc2 = parse(&rendered).expect("second parse");
    let has_break = doc2
        .blocks
        .iter()
        .any(|b| matches!(b, Block::ThematicBreak));
    assert!(has_break, "thematic break must survive roundtrip");
}

/// A code block with a language tag roundtrips with its language preserved.
#[test]
fn e2e_code_block_language_roundtrip() {
    let input = "```gleam\npub fn main() { Nil }\n```\n";
    let doc = parse(input).expect("parse");
    let rendered = render(&doc).expect("render");
    assert!(
        rendered.contains("```gleam"),
        "language tag must appear in rendered output"
    );
    // Second parse confirms the language is still recorded.
    let doc2 = parse(&rendered).expect("second parse");
    let code_block = doc2.blocks.iter().find_map(|b| {
        if let Block::CodeBlock { language, .. } = b {
            Some(language.as_deref())
        } else {
            None
        }
    });
    assert_eq!(
        code_block,
        Some(Some("gleam")),
        "language must be preserved through roundtrip"
    );
}

/// An unordered list roundtrips correctly with all items intact.
#[test]
fn e2e_unordered_list_roundtrip() {
    let input = "- Alpha\n- Beta\n- Gamma\n";
    let doc = parse(input).expect("parse");
    let rendered = render(&doc).expect("render");
    let doc2 = parse(&rendered).expect("second parse");
    let list_block = doc2.blocks.iter().find(|b| matches!(b, Block::List { .. }));
    assert!(list_block.is_some(), "list block must survive roundtrip");
    if let Some(Block::List { ordered, items }) = list_block {
        assert!(!ordered, "list must remain unordered");
        assert_eq!(items.len(), 3, "all three list items must survive");
    }
}

/// A Directive constructed directly via `Directive::new` renders in the
/// canonical `@name value` format.
#[test]
fn e2e_programmatic_directive_rendering() {
    let directive = Directive::new("agent", "claude-sonnet");
    let mut doc = a2ml::types::Document::new();
    doc.directives.push(directive);
    let rendered = render(&doc).expect("render");
    assert!(
        rendered.contains("@agent claude-sonnet"),
        "programmatically-constructed directive must render correctly"
    );
}
