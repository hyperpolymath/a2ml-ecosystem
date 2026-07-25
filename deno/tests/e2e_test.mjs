// SPDX-License-Identifier: MPL-2.0
//
// tests/e2e_test.mjs — End-to-end roundtrip tests for a2ml-deno.
//
// Tests the full parse → render → re-parse pipeline to verify that
// the parser and renderer are inverse operations and preserve document
// structure across a complete roundtrip.

import { parse, render } from "../src/A2ML.res.mjs";
import { assertEquals, assert } from "jsr:@std/assert";

// ---------------------------------------------------------------------------
// Helper: parse-render-reparse roundtrip assertion
// ---------------------------------------------------------------------------

/**
 * Asserts that parsing a document, rendering it, and re-parsing the result
 * produces a document with the same number of blocks.
 *
 * @param {string} input - Raw A2ML text to test
 * @param {string} label - Test description
 */
function assertRoundtrip(input, label) {
  const parsed = parse(input);
  assert(parsed.TAG === "Ok", `${label}: initial parse must succeed`);
  const rendered = render(parsed._0);
  const reparsed = parse(rendered);
  assert(reparsed.TAG === "Ok", `${label}: re-parse of rendered output must succeed`);
  assertEquals(
    reparsed._0.blocks.length,
    parsed._0.blocks.length,
    `${label}: block count must match after roundtrip`
  );
}

// ---------------------------------------------------------------------------
// Roundtrip tests
// ---------------------------------------------------------------------------

Deno.test("e2e roundtrip: simple heading document", () => {
  assertRoundtrip("# Hello World\n", "simple heading");
});

Deno.test("e2e roundtrip: paragraph text", () => {
  assertRoundtrip("This is a plain paragraph.\n", "plain paragraph");
});

Deno.test("e2e roundtrip: document with heading and paragraph", () => {
  assertRoundtrip("# Title\n\nSome body text.\n", "heading and paragraph");
});

Deno.test("e2e roundtrip: bullet list", () => {
  assertRoundtrip("- Item one\n- Item two\n- Item three\n", "bullet list");
});

Deno.test("e2e roundtrip: code block preserved", () => {
  const input = "```rust\nfn main() {}\n```\n";
  const parsed = parse(input);
  assert(parsed.TAG === "Ok", "code block parse must succeed");
  const rendered = render(parsed._0);
  assert(rendered.includes("fn main()"), "rendered output must contain code content");
});

Deno.test("e2e roundtrip: directive block with inline body", () => {
  assertRoundtrip("@version: 1.0\n", "inline directive");
});

Deno.test("e2e roundtrip: thematic break", () => {
  const input = "---\n";
  const parsed = parse(input);
  assert(parsed.TAG === "Ok", "thematic break parse must succeed");
  const rendered = render(parsed._0);
  assert(rendered.includes("---"), "rendered output must contain thematic break marker");
});

Deno.test("e2e roundtrip: multi-level headings H1 through H3", () => {
  const input = "# Level 1\n## Level 2\n### Level 3\n";
  assertRoundtrip(input, "multi-level headings");
});

Deno.test("e2e roundtrip: bold and emphasis inline markup", () => {
  const input = "Some **bold** and *italic* text.\n";
  const parsed = parse(input);
  assert(parsed.TAG === "Ok", "inline markup parse must succeed");
  const rendered = render(parsed._0);
  assert(rendered.includes("bold"), "rendered output must include bold text");
});

Deno.test("e2e: empty input returns Error not crash", () => {
  const result = parse("");
  assertEquals(result.TAG, "Error", "empty input must return Error variant");
});

Deno.test("e2e: whitespace-only input returns Error", () => {
  const result = parse("   \n\n   ");
  assertEquals(result.TAG, "Error", "whitespace-only input must return Error variant");
});

Deno.test("e2e: parse produces directives array on document with directive", () => {
  const input = "@version: 2.0\n";
  const parsed = parse(input);
  assert(parsed.TAG === "Ok", "directive parse must succeed");
  assert(parsed._0.directives.length > 0, "directives array must be non-empty");
  assertEquals(parsed._0.directives[0].name, "version");
  assertEquals(parsed._0.directives[0].value, "2.0");
});
