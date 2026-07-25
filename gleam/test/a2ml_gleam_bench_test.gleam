// SPDX-License-Identifier: MPL-2.0
// (MPL-2.0 preferred; MPL-2.0 required for Hex.pm)
//
// a2ml_gleam_bench_test — Timing/benchmark tests for A2ML parser/renderer.
//
// Uses repetition-based guards to detect gross performance regressions.
// Gleam does not have a built-in benchmarking harness, so these tests
// verify that bulk operations complete without error rather than asserting
// wall-clock bounds (which would be flaky in CI).

import a2ml_gleam/parser
import a2ml_gleam/renderer
import a2ml_gleam/types.{Automated, Reviewed, Unverified, Verified}
import gleam/list

// ---------------------------------------------------------------------------
// Benchmark: parse 500 documents without error
// ---------------------------------------------------------------------------

pub fn bench_parse_500_test() {
  let input = "# Bench Parse\n\n@version 1.0\n\nA benchmark paragraph."

  list.range(from: 1, to: 500)
  |> list.each(fn(_) {
    let assert Ok(_) = parser.parse(input)
  })
}

// ---------------------------------------------------------------------------
// Benchmark: render 500 documents without error
// ---------------------------------------------------------------------------

pub fn bench_render_500_test() {
  let input =
    "# Bench Render\n\n@version 2.0\n\n!attest\n  identity: Jonathan D.A. Jewell\n  role: author\n  trust-level: verified"

  let assert Ok(doc) = parser.parse(input)

  list.range(from: 1, to: 500)
  |> list.each(fn(_) {
    let out = renderer.render(doc)
    let assert True = out != ""
  })
}

// ---------------------------------------------------------------------------
// Benchmark: 200 full roundtrips without error
// ---------------------------------------------------------------------------

pub fn bench_200_roundtrips_test() {
  let input =
    "# Roundtrip Bench\n\n@version 3.0\n\n@author Jonathan D.A. Jewell\n\nA paragraph.\n\n!attest\n  identity: Bot\n  role: scanner\n  trust-level: automated"

  list.range(from: 1, to: 200)
  |> list.each(fn(_) {
    let assert Ok(doc1) = parser.parse(input)
    let rendered = renderer.render(doc1)
    let assert Ok(_doc2) = parser.parse(rendered)
  })
}

// ---------------------------------------------------------------------------
// Benchmark: parse_trust_level 1000 times without error
// ---------------------------------------------------------------------------

pub fn bench_parse_trust_level_1000_test() {
  let levels = ["unverified", "automated", "reviewed", "verified"]
  let count = list.length(levels)

  list.range(from: 0, to: 999)
  |> list.each(fn(i) {
    let level = case i % count {
      0 -> "unverified"
      1 -> "automated"
      2 -> "reviewed"
      _ -> "verified"
    }
    let _ = parser.parse_trust_level(level)
    Nil
  })
}

// ---------------------------------------------------------------------------
// Benchmark: render_trust_level 1000 times without error
// ---------------------------------------------------------------------------

pub fn bench_render_trust_level_1000_test() {
  let count = 4

  list.range(from: 0, to: 999)
  |> list.each(fn(i) {
    let level = case i % count {
      0 -> Unverified
      1 -> Automated
      2 -> Reviewed
      _ -> Verified
    }
    let _ = renderer.render_trust_level(level)
    Nil
  })
}
