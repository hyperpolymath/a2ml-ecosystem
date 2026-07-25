// SPDX-License-Identifier: MPL-2.0
// (MPL-2.0 preferred; MPL-2.0 required for Hex.pm)
//
// a2ml_gleam_contract_test — Contract/invariant tests for A2ML parser/renderer.
//
// Tests the behavioural contracts that the API must uphold regardless of input.
// Each test validates a named invariant.

import a2ml_gleam/parser
import a2ml_gleam/renderer
import a2ml_gleam/types.{Automated, Reviewed, Unverified, Verified}
import gleam/string

// ---------------------------------------------------------------------------
// INVARIANT: parse of empty string returns Error(EmptyInput)
// ---------------------------------------------------------------------------

pub fn invariant_parse_empty_returns_error_test() {
  let assert Error(parser.EmptyInput) = parser.parse("")
}

pub fn invariant_parse_whitespace_returns_error_test() {
  let assert Error(parser.EmptyInput) = parser.parse("   \n\t  ")
}

// ---------------------------------------------------------------------------
// INVARIANT: parse success returns Ok(Document)
// ---------------------------------------------------------------------------

pub fn invariant_parse_title_ok_test() {
  let assert Ok(_doc) = parser.parse("# Hello A2ML")
}

pub fn invariant_parse_paragraph_ok_test() {
  let assert Ok(_doc) = parser.parse("A simple paragraph.")
}

pub fn invariant_parse_directive_ok_test() {
  let assert Ok(_doc) = parser.parse("@version 1.0")
}

// ---------------------------------------------------------------------------
// INVARIANT: parse_trust_level returns Ok for all canonical levels
// ---------------------------------------------------------------------------

pub fn invariant_parse_trust_level_ok_for_canonical_test() {
  let assert Ok(Unverified) = parser.parse_trust_level("unverified")
  let assert Ok(Automated) = parser.parse_trust_level("automated")
  let assert Ok(Reviewed) = parser.parse_trust_level("reviewed")
  let assert Ok(Verified) = parser.parse_trust_level("verified")
}

// ---------------------------------------------------------------------------
// INVARIANT: parse_trust_level is case-insensitive
// ---------------------------------------------------------------------------

pub fn invariant_parse_trust_level_case_insensitive_test() {
  let assert Ok(Unverified) = parser.parse_trust_level("UNVERIFIED")
  let assert Ok(Automated) = parser.parse_trust_level("Automated")
  let assert Ok(Reviewed) = parser.parse_trust_level("REVIEWED")
  let assert Ok(Verified) = parser.parse_trust_level("Verified")
}

// ---------------------------------------------------------------------------
// INVARIANT: parse_trust_level returns Error for unknown inputs
// ---------------------------------------------------------------------------

pub fn invariant_parse_trust_level_error_for_unknown_test() {
  let assert Error(parser.UnknownTrustLevel(_)) =
    parser.parse_trust_level("invalid")
  let assert Error(parser.UnknownTrustLevel(_)) =
    parser.parse_trust_level("none")
  let assert Error(parser.UnknownTrustLevel(_)) = parser.parse_trust_level("")
}

// ---------------------------------------------------------------------------
// INVARIANT: render always returns a non-empty string
// ---------------------------------------------------------------------------

pub fn invariant_render_returns_non_empty_string_test() {
  let assert Ok(doc) = parser.parse("# Render Contract\n\n@version 1.0")
  let output = renderer.render(doc)
  let assert True = output != ""
}

// ---------------------------------------------------------------------------
// INVARIANT: render_trust_level produces stable lowercase strings
// ---------------------------------------------------------------------------

pub fn invariant_render_trust_level_stable_test() {
  let assert True = renderer.render_trust_level(Unverified) == "unverified"
  let assert True = renderer.render_trust_level(Automated) == "automated"
  let assert True = renderer.render_trust_level(Reviewed) == "reviewed"
  let assert True = renderer.render_trust_level(Verified) == "verified"
}

// ---------------------------------------------------------------------------
// INVARIANT: attestations list is always a list (never absent)
// ---------------------------------------------------------------------------

pub fn invariant_attestations_always_list_test() {
  let assert Ok(doc) = parser.parse("# No Attestations\n\n@version 1.0")
  let assert True = doc.attestations == []
}

// ---------------------------------------------------------------------------
// INVARIANT: manifest version is Ok when @version directive is present
// ---------------------------------------------------------------------------

pub fn invariant_manifest_version_present_test() {
  let assert Ok(doc) = parser.parse("# Manifest\n\n@version 3.0")
  let manifest = parser.extract_manifest(doc)
  let assert True = manifest.version == Ok("3.0")
}

pub fn invariant_manifest_version_absent_test() {
  let assert Ok(doc) = parser.parse("# No Version")
  let manifest = parser.extract_manifest(doc)
  let assert True = manifest.version == Error(Nil)
}

// ---------------------------------------------------------------------------
// INVARIANT: rendered output contains the pedigree section markers
// ---------------------------------------------------------------------------

pub fn invariant_render_title_in_output_test() {
  let assert Ok(doc) = parser.parse("# My Title\n\n@version 1.0")
  let output = renderer.render(doc)
  let assert True = string.contains(output, "# My Title")
}
