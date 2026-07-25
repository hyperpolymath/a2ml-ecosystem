// SPDX-License-Identifier: MPL-2.0
//
// tests/property_test.mjs — Property-based tests for a2ml-deno.
//
// Tests invariants that must hold for all inputs in a given class,
// iterating over multiple representative inputs to cover the input space.

import { parse, render } from "../src/A2ML.res.mjs";
import { parseInlines } from "../src/A2ML_Parser.res.mjs";
import { assertEquals, assert } from "jsr:@std/assert";

// ---------------------------------------------------------------------------
// Property: parse returns Ok or Error, never throws
// ---------------------------------------------------------------------------

const arbitraryInputs = [
  "",
  "   ",
  "# Title\n",
  "## Subtitle\n",
  "Plain paragraph text.\n",
  "- item\n",
  "```\ncode\n```\n",
  "@directive: value\n",
  "---\n",
  "# H1\n## H2\n### H3\n#### H4\n##### H5\n",
  "**bold** and *italic*\n",
  "[link](https://example.com)\n",
  "@ref(some-id)\n",
  "First paragraph.\n\nSecond paragraph.\n",
  "> A blockquote line\n",
  "> Another quote\n> Continued\n",
  "- Alpha\n- Beta\n- Gamma\n- Delta\n",
  "# Title\n\n- Bullet one\n- Bullet two\n\nParagraph text.\n",
  "# Doc\n\n@version: 1.0\n\n---\n\nFooter text.\n",
  "`inline code` in a paragraph.\n",
];

Deno.test("property: parse never throws for any of the representative inputs", () => {
  for (const input of arbitraryInputs) {
    // Must not throw — result is either Ok or Error
    const result = parse(input);
    assert(
      result.TAG === "Ok" || result.TAG === "Error",
      `parse("${input.slice(0, 40)}") must return Ok or Error, not throw`
    );
  }
});

Deno.test("property: rendered output of a successful parse is non-empty", () => {
  const validInputs = arbitraryInputs.filter((i) => i.trim().length > 0);
  for (const input of validInputs) {
    const result = parse(input);
    if (result.TAG === "Ok") {
      const rendered = render(result._0);
      assert(
        rendered.length > 0,
        `render() must produce non-empty output for non-empty document`
      );
    }
  }
});

Deno.test("property: parse result Ok always contains blocks array", () => {
  for (const input of arbitraryInputs) {
    const result = parse(input);
    if (result.TAG === "Ok") {
      assert(
        Array.isArray(result._0.blocks),
        "Ok result must always have a blocks array"
      );
      assert(
        Array.isArray(result._0.directives),
        "Ok result must always have a directives array"
      );
      assert(
        Array.isArray(result._0.attestations),
        "Ok result must always have an attestations array"
      );
    }
  }
});

Deno.test("property: parseInlines never throws and always returns an array", () => {
  const inlineInputs = [
    "",
    "plain",
    "**bold**",
    "*italic*",
    "`code`",
    "[text](url)",
    "@ref(id)",
    "mix of **bold** and *italic* and `code`",
    "no closing bold **oops",
    "no closing italic *oops",
  ];
  for (const input of inlineInputs) {
    const result = parseInlines(input);
    assert(
      Array.isArray(result),
      `parseInlines("${input}") must return an array, not throw`
    );
  }
});

Deno.test("property: re-parsing rendered output produces same block count as initial parse", () => {
  const stableInputs = arbitraryInputs.filter((i) => i.trim().length > 0);
  let checkedCount = 0;
  for (const input of stableInputs) {
    const first = parse(input);
    if (first.TAG !== "Ok") continue;
    const rendered = render(first._0);
    const second = parse(rendered);
    if (second.TAG !== "Ok") continue;
    assertEquals(
      second._0.blocks.length,
      first._0.blocks.length,
      `Block count must be stable after roundtrip for input: "${input.slice(0, 40)}"`
    );
    checkedCount++;
  }
  assert(checkedCount >= 8, "At least 8 inputs must complete the roundtrip stability check");
});

Deno.test("property: H1 heading always sets document title", () => {
  const h1Inputs = [
    "# Simple Title\n",
    "# Title With **Bold**\n",
    "# First Title\n## Second\n",
  ];
  for (const input of h1Inputs) {
    const result = parse(input);
    assert(result.TAG === "Ok", `H1 parse must succeed for: ${input.trim()}`);
    assert(
      result._0.title !== undefined,
      `H1 document must have a title field set`
    );
  }
});

Deno.test("property: documents with only directives have non-empty directives array", () => {
  const directiveInputs = [
    "@version: 1.0\n",
    "@author: Alice\n",
    "@license: MPL-2.0\n",
  ];
  for (const input of directiveInputs) {
    const result = parse(input);
    assert(result.TAG === "Ok", `Directive parse must succeed for: ${input.trim()}`);
    assert(
      result._0.directives.length > 0,
      `Document with directive must have non-empty directives array`
    );
  }
});

Deno.test("property: empty-like inputs always produce Error", () => {
  const emptyInputs = ["", "   ", "\n", "\t\n\t", "  \n  \n  "];
  for (const input of emptyInputs) {
    const result = parse(input);
    assertEquals(
      result.TAG,
      "Error",
      `Input "${JSON.stringify(input)}" must parse as Error (EmptyDocument)`
    );
  }
});
