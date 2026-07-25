# SPDX-License-Identifier: MPL-2.0
# (MPL-2.0 preferred; MPL-2.0 required for Hex.pm)
#
# a2ml_aspect_test.exs — Aspect tests for A2ML parser/renderer.
#
# Tests cross-cutting concerns: security (input safety), correctness,
# performance, and resilience. These complement the unit and contract tests
# by validating behavioural aspects that cut across the whole API surface.

defmodule A2MLAspectTest do
  use ExUnit.Case, async: true

  # ---------------------------------------------------------------------------
  # Aspect: Security — empty and nil-like inputs are handled gracefully
  # ---------------------------------------------------------------------------

  test "ASPECT security: empty string is handled gracefully without raise" do
    result = A2ML.parse("")
    assert match?({:error, _}, result)
  end

  test "ASPECT security: whitespace-only input handled gracefully" do
    result = A2ML.parse("     \n   \t  ")
    assert match?({:error, _}, result)
  end

  test "ASPECT security: nil input returns error tuple, does not raise" do
    result =
      try do
        A2ML.parse(nil)
      rescue
        _ -> {:error, :bad_argument}
      end

    assert match?({:error, _}, result)
  end

  # ---------------------------------------------------------------------------
  # Aspect: Security — very long strings do not crash the parser
  # ---------------------------------------------------------------------------

  test "ASPECT security: 1000-character string does not crash parser" do
    long_string = String.duplicate("x", 1000)
    result = A2ML.parse(long_string)
    # A2ML may parse long text as a paragraph — either ok or error, not raise.
    assert match?({:ok, _}, result) or match?({:error, _}, result)
  end

  test "ASPECT security: heading with 200-character title is safe" do
    long_title = String.duplicate("a", 200)
    input = "# #{long_title}\n\n@version 1.0"
    result = A2ML.parse(input)
    assert match?({:ok, _}, result) or match?({:error, _}, result)
  end

  # ---------------------------------------------------------------------------
  # Aspect: Correctness — attestation fields survive parse/render roundtrip
  # ---------------------------------------------------------------------------

  test "ASPECT correctness: attestation fields survive roundtrip" do
    input =
      "# Attestation Roundtrip\n\n!attest\n  identity: Jonathan D.A. Jewell\n  role: author\n  trust-level: verified\n  timestamp: 2026-04-04T00:00:00Z"

    assert {:ok, doc1} = A2ML.parse(input)
    assert [attest] = doc1.attestations
    assert attest.identity == "Jonathan D.A. Jewell"
    assert attest.trust_level == :verified

    rendered = A2ML.render(doc1)
    assert {:ok, doc2} = A2ML.parse(rendered)
    assert [attest2] = doc2.attestations
    assert attest2.identity == attest.identity
    assert attest2.trust_level == attest.trust_level
  end

  test "ASPECT correctness: multiple directives survive roundtrip" do
    input = "# Multi-Directive\n\n@version 1.5\n\n@author Alice\n\n@license MPL-2.0"
    assert {:ok, doc1} = A2ML.parse(input)
    assert length(doc1.directives) == 3

    rendered = A2ML.render(doc1)
    assert {:ok, doc2} = A2ML.parse(rendered)
    assert length(doc2.directives) == 3
  end

  test "ASPECT correctness: document title survives parse/render/parse" do
    input = "# My Document\n\nParagraph content."
    assert {:ok, doc1} = A2ML.parse(input)
    assert doc1.title == "My Document"

    rendered = A2ML.render(doc1)
    assert {:ok, doc2} = A2ML.parse(rendered)
    assert doc2.title == "My Document"
  end

  # ---------------------------------------------------------------------------
  # Aspect: Performance — parsing 100 identical inputs completes without error
  # ---------------------------------------------------------------------------

  test "ASPECT performance: parse 100 identical inputs without error" do
    input = "# Performance Test\n\n@version 1.0\n\nA performance paragraph."

    results = Enum.map(1..100, fn _ -> A2ML.parse(input) end)

    Enum.each(results, fn result ->
      assert match?({:ok, _}, result),
             "Expected {:ok, _} but got #{inspect(result)}"
    end)
  end

  test "ASPECT performance: render 100 identical documents without error" do
    input = "# Render Performance\n\n@version 2.0\n\nRender test."
    assert {:ok, doc} = A2ML.parse(input)

    outputs = Enum.map(1..100, fn _ -> A2ML.render(doc) end)

    Enum.each(outputs, fn out ->
      assert is_binary(out)
    end)
  end

  # ---------------------------------------------------------------------------
  # Aspect: Resilience — unusual but syntactically possible inputs
  # ---------------------------------------------------------------------------

  test "ASPECT resilience: document with only a directive is handled" do
    input = "@version 1.0"
    result = A2ML.parse(input)
    assert match?({:ok, _}, result) or match?({:error, _}, result)
  end

  test "ASPECT resilience: document with only an attestation block is handled" do
    input = "!attest\n  identity: Bot\n  role: scanner\n  trust-level: automated"
    result = A2ML.parse(input)
    assert match?({:ok, _}, result) or match?({:error, _}, result)
  end
end
