// SPDX-License-Identifier: MPL-2.0
//
// tests/bench_test.mjs — Performance benchmarks for a2ml-deno.
//
// Uses Deno.bench() to measure parser and renderer throughput across
// a range of document sizes and content types.
//
// Run with: deno bench tests/bench_test.mjs

import { parse, render } from "../src/A2ML.res.mjs";
import { parseInlines } from "../src/A2ML_Parser.res.mjs";

// ---------------------------------------------------------------------------
// Fixtures — pre-built inputs to avoid allocation inside bench loops
// ---------------------------------------------------------------------------

/** A minimal single-heading document. */
const SMALL_DOC = "# Hello World\n\nA simple paragraph.\n";

/** A medium document with headings, paragraphs, list, and a directive. */
const MEDIUM_DOC = `# Main Title

Introduction paragraph with **bold** and *italic* text.

## Section One

First section paragraph. This one is longer and contains more words.

- Bullet item alpha
- Bullet item beta with \`inline code\`
- Bullet item gamma with [a link](https://example.com)

## Section Two

@version: 1.2.3

Second section with a thematic break below.

---

Footer paragraph.
`;

/** A large document with 50 headings and paragraphs. */
const LARGE_DOC = (() => {
  const lines = ["# Large Document\n"];
  for (let i = 1; i <= 50; i++) {
    lines.push(`\n## Section ${i}\n`);
    lines.push(`\nThis is paragraph number ${i} with **bold** and *italic* and \`code\`.\n`);
    lines.push(`\n- Item A in section ${i}\n- Item B in section ${i}\n`);
  }
  return lines.join("");
})();

/** A document with many inline elements. */
const INLINE_HEAVY_DOC = `# Inline Elements Test

${"**bold** and *italic* and `code` and [link](https://example.com) and @ref(ref1). ".repeat(20)}
`;

/** A document with many directives. */
const DIRECTIVE_HEAVY_DOC = (() => {
  const lines = ["# Directive Document\n"];
  for (let i = 1; i <= 20; i++) {
    lines.push(`@custom-directive-${i}: value-${i}\n`);
  }
  return lines.join("");
})();

// ---------------------------------------------------------------------------
// Benchmarks
// ---------------------------------------------------------------------------

Deno.bench("parse: small document (single heading + paragraph)", () => {
  parse(SMALL_DOC);
});

Deno.bench("parse: medium document (multi-section with list and directive)", () => {
  parse(MEDIUM_DOC);
});

Deno.bench("parse: large document (50 sections, paragraphs, lists)", () => {
  parse(LARGE_DOC);
});

Deno.bench("parse: inline-heavy document (20x repeated inline markup)", () => {
  parse(INLINE_HEAVY_DOC);
});

Deno.bench("parse: directive-heavy document (20 directives)", () => {
  parse(DIRECTIVE_HEAVY_DOC);
});

Deno.bench("parseInlines: empty string", () => {
  parseInlines("");
});

Deno.bench("parseInlines: plain text only", () => {
  parseInlines("Plain text with no markup characters at all");
});

Deno.bench("parseInlines: mixed inline markup", () => {
  parseInlines("**bold** and *italic* and `code` and [link](https://example.com) and @ref(id)");
});

Deno.bench("render: medium document", {
  fn: () => {
    const parsed = parse(MEDIUM_DOC);
    if (parsed.TAG === "Ok") {
      render(parsed._0);
    }
  },
});

Deno.bench("roundtrip: parse + render + re-parse (medium document)", () => {
  const first = parse(MEDIUM_DOC);
  if (first.TAG === "Ok") {
    const rendered = render(first._0);
    parse(rendered);
  }
});
