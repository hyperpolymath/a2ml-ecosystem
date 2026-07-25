-- SPDX-License-Identifier: MPL-2.0
-- (MPL-2.0 preferred; MPL-2.0 required for Hackage OSI-approved policy)
--
-- tests/Spec.hs — HSpec test suite entry point for a2ml-haskell.
--
-- Discovers and runs all *Spec modules.

import           Test.Hspec

import qualified UnitSpec
import qualified E2ESpec
import qualified PropertySpec

main :: IO ()
main = hspec $ do
  describe "Unit"     UnitSpec.spec
  describe "E2E"      E2ESpec.spec
  describe "Property" PropertySpec.spec
