-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- Aggregator for a2ml-showcase Idris2 test suite. Single binary, single
-- exit code: 0 if every test passed, 1 otherwise. Run via:
--
--   idris2 --build a2ml-showcase-tests.ipkg
--   ./build/exec/a2ml-showcase-tests
--
-- The runner prints a summary per suite and a grand total at the end.

module Main

import Test.Spec
import ValidateTest
import System

%default covering

main : IO ()
main = do
  (p, f) <- runTestSuite "ValidateTest" ValidateTest.allSuites
  putStrLn ""
  putStrLn $ "=== Total: " ++ show p ++ " passed, " ++ show f ++ " failed ==="
  if f > 0
    then exitWith (ExitFailure 1)
    else pure ()
