// SPDX-License-Identifier: MPL-2.0
// (MPL-2.0 preferred; MPL-2.0 required for crates.io)

//! Criterion benchmarks for the a2ml crate.
//!
//! Measures parse throughput, render throughput, and roundtrip latency
//! across small, medium, and large A2ML documents.

use criterion::{black_box, criterion_group, criterion_main, BenchmarkId, Criterion};

use a2ml::parser::parse;
use a2ml::renderer::render;
use a2ml::types::TrustLevel;

// ---------------------------------------------------------------------------
// Document fixtures
// ---------------------------------------------------------------------------

/// A small A2ML document (~10 lines).
fn small_document() -> String {
    r#"# Small Document

@version 1.0

A short introductory paragraph describing the purpose of this document.

!attest identity=Alice role=author trust=reviewed
"#
    .to_string()
}

/// A medium A2ML document (~100 lines).
fn medium_document() -> String {
    let mut doc = String::with_capacity(4_096);
    doc.push_str("# Medium Document\n\n");
    doc.push_str("@version 1.0\n");
    doc.push_str("@require trust-level:reviewed\n\n");

    for section in 1..=5 {
        doc.push_str(&format!("## Section {}\n\n", section));
        doc.push_str(
            "This is a paragraph with **bold text**, *italic text*, and `inline code`.\n\n",
        );
        doc.push_str("- First item in the list\n");
        doc.push_str("- Second item in the list\n");
        doc.push_str("- Third item in the list\n\n");
        doc.push_str("```rust\nfn example() -> &'static str {\n    \"value\"\n}\n```\n\n");
        doc.push_str("---\n\n");
    }

    doc.push_str("!attest identity=Bob role=reviewer trust=verified ts=2026-01-01\n");
    doc
}

/// A large A2ML document (~1 000 lines).
fn large_document() -> String {
    let mut doc = String::with_capacity(80_000);
    doc.push_str("# Large Benchmark Document\n\n");
    doc.push_str("@version 1.0\n\n");

    for i in 0..100 {
        doc.push_str(&format!("## Chapter {}\n\n", i + 1));
        for para in 0..5 {
            doc.push_str(&format!(
                "Paragraph {} of chapter {}. Contains **bold**, *italic*, and `code`.\n\n",
                para + 1,
                i + 1
            ));
        }
        doc.push_str("```\ncode block content line 1\ncode block content line 2\n```\n\n");
    }

    doc.push_str("!attest identity=CI-agent role=agent trust=automated\n");
    doc
}

// ---------------------------------------------------------------------------
// Parse benchmarks
// ---------------------------------------------------------------------------

/// Benchmark parsing a small A2ML document.
fn bench_parse_small(c: &mut Criterion) {
    let input = small_document();
    c.bench_with_input(
        BenchmarkId::new("parse", "small"),
        &input,
        |b, input| {
            b.iter(|| {
                let doc = parse(black_box(input)).expect("small document must parse");
                black_box(doc);
            });
        },
    );
}

/// Benchmark parsing a medium A2ML document.
fn bench_parse_medium(c: &mut Criterion) {
    let input = medium_document();
    c.bench_with_input(
        BenchmarkId::new("parse", "medium"),
        &input,
        |b, input| {
            b.iter(|| {
                let doc = parse(black_box(input)).expect("medium document must parse");
                black_box(doc);
            });
        },
    );
}

/// Benchmark parsing a large A2ML document.
fn bench_parse_large(c: &mut Criterion) {
    let input = large_document();
    c.bench_with_input(
        BenchmarkId::new("parse", "large"),
        &input,
        |b, input| {
            b.iter(|| {
                let doc = parse(black_box(input)).expect("large document must parse");
                black_box(doc);
            });
        },
    );
}

// ---------------------------------------------------------------------------
// Render benchmarks
// ---------------------------------------------------------------------------

/// Benchmark rendering a small pre-parsed document.
fn bench_render_small(c: &mut Criterion) {
    let doc = parse(&small_document()).expect("parse");
    c.bench_function("render/small", |b| {
        b.iter(|| {
            let output = render(black_box(&doc)).expect("render must succeed");
            black_box(output);
        });
    });
}

/// Benchmark rendering a medium pre-parsed document.
fn bench_render_medium(c: &mut Criterion) {
    let doc = parse(&medium_document()).expect("parse");
    c.bench_function("render/medium", |b| {
        b.iter(|| {
            let output = render(black_box(&doc)).expect("render must succeed");
            black_box(output);
        });
    });
}

/// Benchmark rendering a large pre-parsed document.
fn bench_render_large(c: &mut Criterion) {
    let doc = parse(&large_document()).expect("parse");
    c.bench_function("render/large", |b| {
        b.iter(|| {
            let output = render(black_box(&doc)).expect("render must succeed");
            black_box(output);
        });
    });
}

// ---------------------------------------------------------------------------
// Roundtrip benchmarks
// ---------------------------------------------------------------------------

/// Benchmark the full parse → render → parse roundtrip on a small document.
fn bench_roundtrip_small(c: &mut Criterion) {
    let input = small_document();
    c.bench_function("roundtrip/small", |b| {
        b.iter(|| {
            let doc1 = parse(black_box(&input)).expect("first parse");
            let rendered = render(&doc1).expect("render");
            let doc2 = parse(&rendered).expect("second parse");
            black_box(doc2);
        });
    });
}

/// Benchmark the full parse → render → parse roundtrip on a medium document.
fn bench_roundtrip_medium(c: &mut Criterion) {
    let input = medium_document();
    c.bench_function("roundtrip/medium", |b| {
        b.iter(|| {
            let doc1 = parse(black_box(&input)).expect("first parse");
            let rendered = render(&doc1).expect("render");
            let doc2 = parse(&rendered).expect("second parse");
            black_box(doc2);
        });
    });
}

/// Benchmark the full parse → render → parse roundtrip on a large document.
fn bench_roundtrip_large(c: &mut Criterion) {
    let input = large_document();
    c.bench_function("roundtrip/large", |b| {
        b.iter(|| {
            let doc1 = parse(black_box(&input)).expect("first parse");
            let rendered = render(&doc1).expect("render");
            let doc2 = parse(&rendered).expect("second parse");
            black_box(doc2);
        });
    });
}

// ---------------------------------------------------------------------------
// Attestation-heavy document benchmarks
//
// Attestation blocks (`!attest`) are parsed separately from the main document
// tree.  These benchmarks measure the cost of parsing documents that contain
// many attestation records — the typical pattern in multi-reviewer workflows.
// ---------------------------------------------------------------------------

/// A document containing 20 attestation records.
fn attestation_heavy_document() -> String {
    let mut doc = String::with_capacity(4_096);
    doc.push_str("# Attested Document\n\n@version 1.0\n\n");
    doc.push_str("This document has been reviewed by many parties.\n\n");

    let roles = ["author", "reviewer", "auditor", "approver", "witness"];
    let trusts = ["reviewed", "verified", "automated", "manual", "attested"];
    for i in 0..20 {
        doc.push_str(&format!(
            "!attest identity=Agent{} role={} trust={} ts=2026-01-{:02}\n",
            i,
            roles[i % roles.len()],
            trusts[i % trusts.len()],
            (i % 28) + 1,
        ));
    }
    doc
}

/// A document containing 30 directives (`@`-prefixed metadata lines).
fn directive_heavy_document() -> String {
    let mut doc = String::with_capacity(4_096);
    doc.push_str("# Directive Document\n\n");

    let keys = [
        "version",
        "require",
        "schema",
        "lang",
        "encoding",
        "created",
        "modified",
        "author",
        "project",
        "stability",
    ];
    for i in 0..30 {
        doc.push_str(&format!(
            "@{} value-{}\n",
            keys[i % keys.len()],
            i
        ));
    }
    doc.push_str("\nBody paragraph after directives.\n");
    doc
}

/// Benchmark parsing a document with many attestation records.
fn bench_parse_attestation_heavy(c: &mut Criterion) {
    let input = attestation_heavy_document();
    c.bench_function("parse/attestation_heavy_20", |b| {
        b.iter(|| {
            let doc = parse(black_box(&input)).expect("attestation document must parse");
            black_box(doc);
        });
    });
}

/// Benchmark parsing a document with many directives.
fn bench_parse_directive_heavy(c: &mut Criterion) {
    let input = directive_heavy_document();
    c.bench_function("parse/directive_heavy_30", |b| {
        b.iter(|| {
            let doc = parse(black_box(&input)).expect("directive document must parse");
            black_box(doc);
        });
    });
}

/// Benchmark extracting attestation records from a parsed document.
///
/// Isolates the attestation-access pattern used when verifying provenance
/// chains — separate from the overall parse cost.
fn bench_attestation_access(c: &mut Criterion) {
    let input = attestation_heavy_document();
    let doc = parse(&input).expect("parse attestation document");

    c.bench_function("attestation/access_20_records", |b| {
        b.iter(|| {
            // Simulate a verifier walking the full attestation chain.
            let count = black_box(&doc)
                .attestations
                .iter()
                .filter(|a| a.trust_level == TrustLevel::Verified)
                .count();
            black_box(count);
        });
    });
}

/// Benchmark render of an attestation-heavy document (provenance serialisation).
fn bench_render_attestation_heavy(c: &mut Criterion) {
    let doc = parse(&attestation_heavy_document()).expect("parse");
    c.bench_function("render/attestation_heavy_20", |b| {
        b.iter(|| {
            let output = render(black_box(&doc)).expect("render must succeed");
            black_box(output);
        });
    });
}

// ---------------------------------------------------------------------------
// Criterion registration
// ---------------------------------------------------------------------------

criterion_group!(
    parse_benches,
    bench_parse_small,
    bench_parse_medium,
    bench_parse_large
);

criterion_group!(
    render_benches,
    bench_render_small,
    bench_render_medium,
    bench_render_large
);

criterion_group!(
    roundtrip_benches,
    bench_roundtrip_small,
    bench_roundtrip_medium,
    bench_roundtrip_large
);

criterion_group!(
    attestation_benches,
    bench_parse_attestation_heavy,
    bench_parse_directive_heavy,
    bench_attestation_access,
    bench_render_attestation_heavy,
);

criterion_main!(parse_benches, render_benches, roundtrip_benches, attestation_benches);
