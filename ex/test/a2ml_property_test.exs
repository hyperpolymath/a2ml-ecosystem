# SPDX-License-Identifier: MPL-2.0
# (MPL-2.0 preferred; MPL-2.0 required for Hex.pm)
#
# a2ml_property_test.exs — Property-based tests for A2ML parser/renderer.
#
# Validates determinism, idempotency, and structural invariants across
# a range of inputs without relying on external property-testing libraries.

defmodule A2MLPropertyTest do
  use ExUnit.Case, async: true

  alias A2ML.Types.TrustLevel

  # ---------------------------------------------------------------------------
  # Property: parse is deterministic — same input always produces same output
  # ---------------------------------------------------------------------------

  test "parse is deterministic over 50 identical calls" do
    input = "# Determinism Test\n\n@version 1.0\n\nA test paragraph."

    results = Enum.map(1..50, fn _ -> A2ML.parse(input) end)
    first = hd(results)

    Enum.each(results, fn result ->
      assert result == first,
             "parse/1 returned different results on identical input"
    end)
  end

  # ---------------------------------------------------------------------------
  # Property: render is deterministic — rendering the same document yields
  # the same string every time
  # ---------------------------------------------------------------------------

  test "render is deterministic over 50 identical calls" do
    input = "# Render Prop\n\n@version 2.0\n\nHello, A2ML!"

    assert {:ok, doc} = A2ML.parse(input)
    outputs = Enum.map(1..50, fn _ -> A2ML.render(doc) end)
    first = hd(outputs)

    Enum.each(outputs, fn out ->
      assert out == first,
             "render/1 returned different results for the same document"
    end)
  end

  # ---------------------------------------------------------------------------
  # Property: all valid trust level strings round-trip through from_string/to_string
  # ---------------------------------------------------------------------------

  test "all trust level strings round-trip" do
    levels = ["unverified", "automated", "reviewed", "verified"]

    Enum.each(levels, fn name ->
      assert {:ok, level} = TrustLevel.from_string(name)
      assert TrustLevel.to_string(level) == name
    end)
  end

  # ---------------------------------------------------------------------------
  # Property: trust level compare is anti-symmetric
  #           compare(a, b) == :lt  iff  compare(b, a) == :gt
  # ---------------------------------------------------------------------------

  test "trust level compare is anti-symmetric" do
    pairs = [
      {:unverified, :automated},
      {:unverified, :reviewed},
      {:unverified, :verified},
      {:automated, :reviewed},
      {:automated, :verified},
      {:reviewed, :verified}
    ]

    Enum.each(pairs, fn {a, b} ->
      assert TrustLevel.compare(a, b) == :lt
      assert TrustLevel.compare(b, a) == :gt
    end)
  end

  # ---------------------------------------------------------------------------
  # Property: trust level compare is reflexive — compare(x, x) == :eq
  # ---------------------------------------------------------------------------

  test "trust level compare is reflexive" do
    Enum.each([:unverified, :automated, :reviewed, :verified], fn level ->
      assert TrustLevel.compare(level, level) == :eq
    end)
  end

  # ---------------------------------------------------------------------------
  # Property: roundtrip preserves title across several documents
  # ---------------------------------------------------------------------------

  test "roundtrip preserves document title" do
    titles = ["Hello World", "My Report", "AI Doc 2026", "Test Title"]

    Enum.each(titles, fn title ->
      input = "# #{title}\n\n@version 1.0\n\nContent here."
      assert {:ok, doc1} = A2ML.parse(input)
      rendered = A2ML.render(doc1)
      assert {:ok, doc2} = A2ML.parse(rendered)
      assert doc1.title == doc2.title
    end)
  end

  # ---------------------------------------------------------------------------
  # Property: invalid trust level strings never produce :ok
  # ---------------------------------------------------------------------------

  test "invalid trust level strings never return {:ok, _}" do
    invalid_names = [
      "none", "all", "safe", "high", "low", "admin", "root",
      "unknown", "nil", "", "trusted", "REVIEWED1", "aut0mated",
      "review", "verif", "unverify", "0", "true", "false"
    ]

    Enum.each(invalid_names, fn name ->
      result = TrustLevel.from_string(name)

      assert match?({:error, _}, result),
             "Expected {:error, _} for #{inspect(name)}, got #{inspect(result)}"
    end)
  end

  # ---------------------------------------------------------------------------
  # Property: directives are preserved across roundtrip
  # ---------------------------------------------------------------------------

  test "directives are preserved across roundtrip" do
    input = "# Directive Test\n\n@version 3.0\n\n@author Jonathan D.A. Jewell"
    assert {:ok, doc1} = A2ML.parse(input)
    assert length(doc1.directives) == 2

    rendered = A2ML.render(doc1)
    assert {:ok, doc2} = A2ML.parse(rendered)
    assert length(doc1.directives) == length(doc2.directives)
  end
end
