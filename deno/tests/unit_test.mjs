// SPDX-License-Identifier: MPL-2.0
//
// tests/unit_test.mjs — Unit tests for a2ml-deno parser and renderer.
//
// Tests each parser and renderer function in isolation to verify correct
// behaviour on well-formed and edge-case inputs.

import { parse, render, renderBlock, renderInline, emptyDocument, makeDirective, makeAttestation, parseErrorToString, trustLevelFromString, trustLevelToString } from "../src/A2ML.res.mjs";
import { parseInlines, parseAttributes, countHashes, parseA2ML } from "../src/A2ML_Parser.res.mjs";
import { assertEquals, assertMatch, assert } from "jsr:@std/assert";

// ---------------------------------------------------------------------------
// parseInlines — inline element parsing
// ---------------------------------------------------------------------------

Deno.test("parseInlines: plain text with no markup returns single Text node", () => {
  const result = parseInlines("Hello, world!");
  assertEquals(result.length, 1);
  assertEquals(result[0].TAG, "Text");
  assertEquals(result[0]._0, "Hello, world!");
});

Deno.test("parseInlines: **bold** produces Strong node", () => {
  const result = parseInlines("**bold**");
  assertEquals(result.length, 1);
  assertEquals(result[0].TAG, "Strong");
  assertEquals(result[0]._0[0]._0, "bold");
});

Deno.test("parseInlines: *italic* produces Emphasis node", () => {
  const result = parseInlines("*italic*");
  assertEquals(result.length, 1);
  assertEquals(result[0].TAG, "Emphasis");
  assertEquals(result[0]._0[0]._0, "italic");
});

Deno.test("parseInlines: `code` produces Code node", () => {
  const result = parseInlines("`hello`");
  assertEquals(result.length, 1);
  assertEquals(result[0].TAG, "Code");
  assertEquals(result[0]._0, "hello");
});

Deno.test("parseInlines: [text](url) produces Link node with correct fields", () => {
  const result = parseInlines("[click here](https://example.com)");
  assertEquals(result.length, 1);
  assertEquals(result[0].TAG, "Link");
  assertEquals(result[0].url, "https://example.com");
  assertEquals(result[0].content[0]._0, "click here");
});

Deno.test("parseInlines: @ref(id) produces InlineRef node", () => {
  const result = parseInlines("@ref(section-1)");
  assertEquals(result.length, 1);
  assertEquals(result[0].TAG, "InlineRef");
  assertEquals(result[0]._0, "section-1");
});

Deno.test("parseInlines: empty string returns empty array", () => {
  const result = parseInlines("");
  assertEquals(result.length, 0);
});

// ---------------------------------------------------------------------------
// parseAttributes — attribute string parsing
// ---------------------------------------------------------------------------

Deno.test("parseAttributes: empty string returns empty array", () => {
  const result = parseAttributes("");
  assertEquals(result.length, 0);
});

Deno.test("parseAttributes: single key=value pair", () => {
  const result = parseAttributes("lang=en");
  assertEquals(result.length, 1);
  assertEquals(result[0][0], "lang");
  assertEquals(result[0][1], "en");
});

Deno.test("parseAttributes: multiple key=value pairs separated by commas", () => {
  const result = parseAttributes("lang=en, version=1.0");
  assertEquals(result.length, 2);
  assertEquals(result[0][0], "lang");
  assertEquals(result[1][0], "version");
});

// ---------------------------------------------------------------------------
// countHashes — heading level detection
// ---------------------------------------------------------------------------

Deno.test("countHashes: single hash gives level 1", () => {
  assertEquals(countHashes("# Hello"), 1);
});

Deno.test("countHashes: five hashes gives level 5", () => {
  assertEquals(countHashes("##### Deep"), 5);
});

Deno.test("countHashes: no hashes gives 0", () => {
  assertEquals(countHashes("Plain text"), 0);
});

// ---------------------------------------------------------------------------
// trustLevelFromString / trustLevelToString
// ---------------------------------------------------------------------------

Deno.test("trustLevelFromString: 'verified' maps to Verified", () => {
  assertEquals(trustLevelFromString("verified"), "Verified");
});

Deno.test("trustLevelFromString: case-insensitive 'REVIEWED' maps to Reviewed", () => {
  assertEquals(trustLevelFromString("REVIEWED"), "Reviewed");
});

Deno.test("trustLevelToString: Automated maps to 'automated'", () => {
  assertEquals(trustLevelToString("Automated"), "automated");
});

// ---------------------------------------------------------------------------
// parseErrorToString — error formatting
// ---------------------------------------------------------------------------

Deno.test("parseErrorToString: EmptyDocument returns descriptive message", () => {
  const msg = parseErrorToString("EmptyDocument");
  assertMatch(msg, /empty/i);
});

// ---------------------------------------------------------------------------
// makeDirective / makeAttestation / emptyDocument — factory helpers
// ---------------------------------------------------------------------------

Deno.test("makeDirective: creates directive with correct name and value", () => {
  const dir = makeDirective("version", "1.0");
  assertEquals(dir.name, "version");
  assertEquals(dir.value, "1.0");
  assertEquals(dir.attributes.length, 0);
});

Deno.test("makeAttestation: creates attestation with identity and role", () => {
  const att = makeAttestation("alice", "author", "Verified");
  assertEquals(att.identity, "alice");
  assertEquals(att.role, "author");
  assertEquals(att.trustLevel, "Verified");
  assertEquals(att.timestamp, undefined);
  assertEquals(att.note, undefined);
});

Deno.test("emptyDocument: returns document with no blocks or directives", () => {
  const doc = emptyDocument();
  assertEquals(doc.blocks.length, 0);
  assertEquals(doc.directives.length, 0);
  assertEquals(doc.attestations.length, 0);
  assertEquals(doc.title, undefined);
});
