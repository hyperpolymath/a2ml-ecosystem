// SPDX-License-Identifier: MPL-2.0
// (MPL-2.0 preferred; MPL-2.0 required for Hex.pm)
//
// a2ml_gleam_aspect_test — Aspect tests for A2ML parser/renderer.
//
// Tests cross-cutting concerns: security (input safety), correctness,
// performance, and resilience. These complement the unit and contract tests
// by validating behavioural aspects that cut across the whole API surface.

import a2ml_gleam/parser
import a2ml_gleam/renderer
import a2ml_gleam/types.{Verified}
import gleam/list
import gleam/string

// ---------------------------------------------------------------------------
// Aspect: Security — empty and whitespace inputs are handled gracefully
// ---------------------------------------------------------------------------

pub fn aspect_security_empty_input_test() {
  let assert Error(_) = parser.parse("")
}

pub fn aspect_security_whitespace_only_test() {
  let assert Error(_) = parser.parse("     \n   \t  ")
}

// ---------------------------------------------------------------------------
// Aspect: Security — very long strings do not panic the parser
// ---------------------------------------------------------------------------

pub fn aspect_security_long_string_test() {
  let long = string.repeat("x", 1000)
  let result = parser.parse(long)
  // A2ML may parse long text as a paragraph — either ok or error, not panic.
  case result {
    Ok(_) -> Nil
    Error(_) -> Nil
  }
}

pub fn aspect_security_long_title_test() {
  let long_title = string.repeat("a", 200)
  let input = "# " <> long_title <> "\n\n@version 1.0"
  let result = parser.parse(input)
  case result {
    Ok(_) -> Nil
    Error(_) -> Nil
  }
}

// ---------------------------------------------------------------------------
// Aspect: Correctness — attestation fields survive roundtrip
// ---------------------------------------------------------------------------

pub fn aspect_correctness_attestation_roundtrip_test() {
  let input =
    "# Attestation Roundtrip\n\n!attest\n  identity: Jonathan D.A. Jewell\n  role: author\n  trust-level: verified\n  timestamp: 2026-04-04T00:00:00Z"

  let assert Ok(doc1) = parser.parse(input)
  let assert [a] = doc1.attestations
  let assert True = a.identity == "Jonathan D.A. Jewell"
  let assert True = a.trust_level == Verified

  let rendered = renderer.render(doc1)
  let assert Ok(doc2) = parser.parse(rendered)
  let assert [a2] = doc2.attestations
  let assert True = a2.identity == a.identity
  let assert True = a2.trust_level == a.trust_level
}

pub fn aspect_correctness_multiple_attestations_roundtrip_test() {
  let input =
    "# Two Attestors\n\n!attest\n  identity: Alice\n  role: author\n  trust-level: reviewed\n\n!attest\n  identity: Bob\n  role: reviewer\n  trust-level: reviewed"

  let assert Ok(doc1) = parser.parse(input)
  let assert True = list.length(doc1.attestations) == 2

  let rendered = renderer.render(doc1)
  let assert Ok(doc2) = parser.parse(rendered)
  let assert True = list.length(doc2.attestations) == 2
}

pub fn aspect_correctness_directive_value_survives_roundtrip_test() {
  let input = "# Directive Roundtrip\n\n@version 2.5"
  let assert Ok(doc1) = parser.parse(input)
  let rendered = renderer.render(doc1)
  let assert Ok(doc2) = parser.parse(rendered)
  let manifest1 = parser.extract_manifest(doc1)
  let manifest2 = parser.extract_manifest(doc2)
  let assert True = manifest1.version == manifest2.version
}

// ---------------------------------------------------------------------------
// Aspect: Performance — parsing 100 identical inputs completes without error
// ---------------------------------------------------------------------------

pub fn aspect_performance_parse_100_identical_test() {
  let input = "# Performance Test\n\n@version 1.0\n\nA performance paragraph."

  list.range(from: 1, to: 100)
  |> list.each(fn(_) {
    let assert Ok(_) = parser.parse(input)
  })
}

pub fn aspect_performance_render_100_identical_test() {
  let input = "# Render Performance\n\n@version 2.0\n\nRender test."
  let assert Ok(doc) = parser.parse(input)

  list.range(from: 1, to: 100)
  |> list.each(fn(_) {
    let out = renderer.render(doc)
    let assert True = out != ""
  })
}

// ---------------------------------------------------------------------------
// Aspect: Resilience — unusual but syntactically possible inputs
// ---------------------------------------------------------------------------

pub fn aspect_resilience_directive_only_test() {
  let result = parser.parse("@version 1.0")
  case result {
    Ok(_) -> Nil
    Error(_) -> Nil
  }
}

pub fn aspect_resilience_attestation_only_test() {
  let input =
    "!attest\n  identity: Bot\n  role: scanner\n  trust-level: automated"
  let result = parser.parse(input)
  case result {
    Ok(_) -> Nil
    Error(_) -> Nil
  }
}

pub fn aspect_resilience_unknown_trust_level_returns_error_test() {
  let assert Error(parser.UnknownTrustLevel(_)) =
    parser.parse_trust_level("notreal")
}
