# SPDX-License-Identifier: MPL-2.0
# (MPL-2.0 preferred; MPL-2.0 required for Hex.pm)
#
# a2ml_contract_test.exs — Contract/invariant tests for A2ML parser/renderer.
#
# Tests the behavioural contracts that the API must uphold regardless of input.
# Each test validates a named invariant.

defmodule A2MLContractTest do
  use ExUnit.Case, async: true

  alias A2ML.Types.{Manifest, TrustLevel}

  # ---------------------------------------------------------------------------
  # INVARIANT: parse of empty/whitespace input returns {:error, :empty_input}
  # ---------------------------------------------------------------------------

  test "INVARIANT: parse empty string returns {:error, :empty_input}" do
    assert {:error, :empty_input} = A2ML.parse("")
  end

  test "INVARIANT: parse whitespace-only string returns {:error, :empty_input}" do
    assert {:error, :empty_input} = A2ML.parse("   \n\t  ")
  end

  # ---------------------------------------------------------------------------
  # INVARIANT: parse success always returns {:ok, %A2ML.Types.Document{}}
  # ---------------------------------------------------------------------------

  test "INVARIANT: successful parse always returns {:ok, Document}" do
    assert {:ok, %A2ML.Types.Document{}} = A2ML.parse("# Hello A2ML")
    assert {:ok, %A2ML.Types.Document{}} = A2ML.parse("A simple paragraph.")
    assert {:ok, %A2ML.Types.Document{}} = A2ML.parse("@version 1.0")
  end

  # ---------------------------------------------------------------------------
  # INVARIANT: parse error returns {:error, _} — never raises
  # ---------------------------------------------------------------------------

  test "INVARIANT: parse of garbage input returns {:error, _} or {:ok, _} — never raises" do
    # A2ML is fairly permissive and may parse some garbage as paragraphs.
    # The invariant here is: it must not raise an exception.
    garbage_inputs = ["%%%!!!", "12345", "null", "true", "[]"]

    Enum.each(garbage_inputs, fn input ->
      result = A2ML.parse(input)
      assert match?({:ok, _}, result) or match?({:error, _}, result),
             "Expected result tuple for #{inspect(input)}, got #{inspect(result)}"
    end)
  end

  # ---------------------------------------------------------------------------
  # INVARIANT: TrustLevel.from_string returns {:ok, atom} for all valid levels
  # ---------------------------------------------------------------------------

  test "INVARIANT: from_string returns {:ok, atom} for all canonical trust level names" do
    assert {:ok, :unverified} = TrustLevel.from_string("unverified")
    assert {:ok, :automated} = TrustLevel.from_string("automated")
    assert {:ok, :reviewed} = TrustLevel.from_string("reviewed")
    assert {:ok, :verified} = TrustLevel.from_string("verified")
  end

  # ---------------------------------------------------------------------------
  # INVARIANT: TrustLevel.from_string is case-insensitive
  # ---------------------------------------------------------------------------

  test "INVARIANT: from_string is case-insensitive" do
    assert {:ok, :unverified} = TrustLevel.from_string("UNVERIFIED")
    assert {:ok, :automated} = TrustLevel.from_string("Automated")
    assert {:ok, :reviewed} = TrustLevel.from_string("REVIEWED")
    assert {:ok, :verified} = TrustLevel.from_string("Verified")
  end

  # ---------------------------------------------------------------------------
  # INVARIANT: TrustLevel.from_string returns {:error, :unknown_trust_level}
  #            for unknown inputs — never {:ok, _}
  # ---------------------------------------------------------------------------

  test "INVARIANT: invalid trust level string never returns {:ok, _}" do
    assert {:error, :unknown_trust_level} = TrustLevel.from_string("invalid")
    assert {:error, :unknown_trust_level} = TrustLevel.from_string("none")
    assert {:error, :unknown_trust_level} = TrustLevel.from_string("")
  end

  # ---------------------------------------------------------------------------
  # INVARIANT: render always returns a String, never nil or raises
  # ---------------------------------------------------------------------------

  test "INVARIANT: render always returns a binary string" do
    assert {:ok, doc} = A2ML.parse("# Render Contract\n\n@version 1.0")
    output = A2ML.render(doc)
    assert is_binary(output)
    assert byte_size(output) > 0
  end

  # ---------------------------------------------------------------------------
  # INVARIANT: Manifest.from_document always returns a Manifest struct
  # ---------------------------------------------------------------------------

  test "INVARIANT: Manifest.from_document always returns a Manifest struct" do
    assert {:ok, doc} = A2ML.parse("# Title\n\n@version 2.0")
    manifest = Manifest.from_document(doc)
    assert %Manifest{} = manifest
    assert manifest.version == "2.0"
    assert manifest.title == "Title"
  end

  test "INVARIANT: Manifest.from_document with no directives has nil version" do
    assert {:ok, doc} = A2ML.parse("# No Version")
    manifest = Manifest.from_document(doc)
    assert manifest.version == nil
    assert manifest.title == "No Version"
  end

  # ---------------------------------------------------------------------------
  # INVARIANT: attestations list is always a list (never nil)
  # ---------------------------------------------------------------------------

  test "INVARIANT: doc.attestations is always a list even with no attestations" do
    assert {:ok, doc} = A2ML.parse("# No Attestations\n\n@version 1.0")
    assert is_list(doc.attestations)
    assert doc.attestations == []
  end
end
