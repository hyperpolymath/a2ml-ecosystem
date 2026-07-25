# SPDX-License-Identifier: MPL-2.0
# (MPL-2.0 preferred; MPL-2.0 required for Hex.pm)
#
# a2ml_bench_test.exs — Timing/benchmark tests for A2ML parser/renderer.
#
# Uses ExUnit with wall-clock assertions to detect gross performance regressions.
# Not a microbenchmark harness — guards against orders-of-magnitude slowdowns.

defmodule A2MLBenchTest do
  use ExUnit.Case, async: false

  # Maximum acceptable wall-clock time (milliseconds) for the bulk operations.
  # Deliberately generous to avoid CI flakiness.
  @parse_budget_ms 5_000
  @render_budget_ms 5_000
  @roundtrip_budget_ms 10_000

  # ---------------------------------------------------------------------------
  # Benchmark: parse 500 documents within budget
  # ---------------------------------------------------------------------------

  test "bench: parse 500 documents within #{@parse_budget_ms}ms" do
    input = "# Bench Parse\n\n@version 1.0\n\nA benchmark paragraph."

    {elapsed_us, _} =
      :timer.tc(fn ->
        Enum.each(1..500, fn _ -> A2ML.parse(input) end)
      end)

    elapsed_ms = div(elapsed_us, 1_000)

    assert elapsed_ms < @parse_budget_ms,
           "parse 500 took #{elapsed_ms}ms — exceeded #{@parse_budget_ms}ms budget"
  end

  # ---------------------------------------------------------------------------
  # Benchmark: render 500 documents within budget
  # ---------------------------------------------------------------------------

  test "bench: render 500 documents within #{@render_budget_ms}ms" do
    input =
      "# Bench Render\n\n@version 2.0\n\n!attest\n  identity: Jonathan D.A. Jewell\n  role: author\n  trust-level: verified"

    assert {:ok, doc} = A2ML.parse(input)

    {elapsed_us, _} =
      :timer.tc(fn ->
        Enum.each(1..500, fn _ -> A2ML.render(doc) end)
      end)

    elapsed_ms = div(elapsed_us, 1_000)

    assert elapsed_ms < @render_budget_ms,
           "render 500 took #{elapsed_ms}ms — exceeded #{@render_budget_ms}ms budget"
  end

  # ---------------------------------------------------------------------------
  # Benchmark: 200 full roundtrips within budget
  # ---------------------------------------------------------------------------

  test "bench: 200 full roundtrips within #{@roundtrip_budget_ms}ms" do
    input =
      "# Roundtrip Bench\n\n@version 3.0\n\n@author Jonathan D.A. Jewell\n\nA paragraph.\n\n!attest\n  identity: Bot\n  role: scanner\n  trust-level: automated"

    {elapsed_us, _} =
      :timer.tc(fn ->
        Enum.each(1..200, fn _ ->
          assert {:ok, doc1} = A2ML.parse(input)
          rendered = A2ML.render(doc1)
          assert {:ok, _doc2} = A2ML.parse(rendered)
        end)
      end)

    elapsed_ms = div(elapsed_us, 1_000)

    assert elapsed_ms < @roundtrip_budget_ms,
           "200 roundtrips took #{elapsed_ms}ms — exceeded #{@roundtrip_budget_ms}ms budget"
  end

  # ---------------------------------------------------------------------------
  # Benchmark: trust level from_string 1000 times is fast
  # ---------------------------------------------------------------------------

  test "bench: TrustLevel.from_string 1000 calls is fast" do
    levels = ["unverified", "automated", "reviewed", "verified", "REVIEWED", "Verified"]

    {elapsed_us, _} =
      :timer.tc(fn ->
        Enum.each(1..1000, fn i ->
          level = Enum.at(levels, rem(i, length(levels)))
          A2ML.Types.TrustLevel.from_string(level)
        end)
      end)

    elapsed_ms = div(elapsed_us, 1_000)

    assert elapsed_ms < 500,
           "1000 from_string calls took #{elapsed_ms}ms — expected < 500ms"
  end
end
