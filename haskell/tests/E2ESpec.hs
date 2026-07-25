-- SPDX-License-Identifier: MPL-2.0
-- (MPL-2.0 preferred; MPL-2.0 required for Hackage OSI-approved policy)
--
-- tests/E2ESpec.hs — End-to-end roundtrip tests for a2ml-haskell.
--
-- Tests the full parse → render → re-parse pipeline to verify that
-- the parser and renderer are inverse operations and that document
-- structure is preserved across a complete roundtrip.

module E2ESpec (spec) where

import           Data.A2ML
import           Data.A2ML.Parser
import           Data.A2ML.Renderer
import           Data.A2ML.Types

import qualified Data.Text as T

import           Test.Hspec

-- ---------------------------------------------------------------------------
-- Helper: roundtrip assertion
-- ---------------------------------------------------------------------------

-- | Assert that parsing, rendering, and re-parsing a document produces
-- a result with the same number of blocks as the initial parse.
assertRoundtrip :: T.Text -> IO ()
assertRoundtrip input = do
  let first = parseA2ML input
  case first of
    Left err  -> expectationFailure ("Initial parse failed: " <> show err)
    Right doc -> do
      let rendered  = renderA2ML doc
          reparsed  = parseA2ML rendered
      case reparsed of
        Left err2 -> expectationFailure
          ("Re-parse of rendered output failed: " <> show err2
           <> "\nRendered was: " <> T.unpack rendered)
        Right doc2 ->
          length (documentBlocks doc2)
            `shouldBe` length (documentBlocks doc)

-- ---------------------------------------------------------------------------
-- Spec
-- ---------------------------------------------------------------------------

spec :: Spec
spec = do
  describe "parse → render roundtrip" $ do
    it "roundtrip: simple H1 heading" $
      assertRoundtrip "# Hello World\n"

    it "roundtrip: plain paragraph" $
      assertRoundtrip "Simple paragraph text.\n"

    it "roundtrip: H1 + blank line + paragraph" $
      assertRoundtrip "# Title\n\nBody paragraph.\n"

    it "roundtrip: bullet list" $
      assertRoundtrip "- Alpha\n- Beta\n- Gamma\n"

    it "roundtrip: multi-level headings H1 through H3" $
      assertRoundtrip "# Level 1\n## Level 2\n### Level 3\n"

    it "roundtrip: directive block with body" $
      assertRoundtrip "@abstract:\nSome abstract text.\n@end\n"

    it "roundtrip: document with blank lines between blocks" $
      assertRoundtrip "# Title\n\n- item one\n- item two\n\nParagraph.\n"

    it "roundtrip: bold inline markup preserved" $ do
      let input = "# Title\n\nSome **bold** text.\n"
      first <- case parseA2ML input of
        Left  e -> fail ("Parse failed: " <> show e)
        Right d -> pure d
      let rendered = renderA2ML first
      T.isInfixOf "bold" rendered `shouldBe` True

    it "roundtrip: italic inline markup preserved" $ do
      let input = "Paragraph with *italic* text.\n"
      first <- case parseA2ML input of
        Left  e -> fail ("Parse failed: " <> show e)
        Right d -> pure d
      let rendered = renderA2ML first
      T.isInfixOf "italic" rendered `shouldBe` True

    it "roundtrip: complex mixed document" $
      assertRoundtrip $ T.unlines
        [ "# Complex Document"
        , ""
        , "Introduction paragraph with **bold** content."
        , ""
        , "## Section"
        , ""
        , "- Bullet one"
        , "- Bullet two with *italic*"
        , ""
        , "@abstract:"
        , "Abstract body text."
        , "@end"
        ]

  describe "parse error conditions" $ do
    it "empty string returns EmptyDocument error" $
      parseA2ML "" `shouldBe` Left EmptyDocument

    it "whitespace-only input returns EmptyDocument error" $
      parseA2ML "\n\n\n   " `shouldBe` Left EmptyDocument
