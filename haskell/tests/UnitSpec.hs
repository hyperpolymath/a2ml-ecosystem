-- SPDX-License-Identifier: MPL-2.0
-- (MPL-2.0 preferred; MPL-2.0 required for Hackage OSI-approved policy)
--
-- tests/UnitSpec.hs — HSpec unit tests for a2ml-haskell parser and renderer.
--
-- Tests individual functions in isolation to verify correct behaviour on
-- well-formed inputs, edge cases, and error conditions.

module UnitSpec (spec) where

import           Data.A2ML
import           Data.A2ML.Parser
import           Data.A2ML.Renderer
import           Data.A2ML.Types

import qualified Data.Map.Strict as Map
import qualified Data.Text       as T

import           Test.Hspec

-- ---------------------------------------------------------------------------
-- Spec entry point
-- ---------------------------------------------------------------------------

spec :: Spec
spec = do
  describe "parseA2ML" $ do
    it "returns Left EmptyDocument for empty input" $
      parseA2ML "" `shouldBe` Left EmptyDocument

    it "returns Left EmptyDocument for whitespace-only input" $
      parseA2ML "   \n\n  " `shouldBe` Left EmptyDocument

    it "returns Right for a minimal single-heading document" $ do
      let result = parseA2ML "# Hello\n"
      result `shouldSatisfy` \case
        Right _  -> True
        Left  _  -> False

    it "parses H1 heading into Heading 1 block" $ do
      let Right doc = parseA2ML "# Title\n"
      documentBlocks doc `shouldContain` [Heading 1 [PlainText "Title"]]

    it "parses H2 heading into Heading 2 block" $ do
      let Right doc = parseA2ML "## Subtitle\n"
      case documentBlocks doc of
        (Heading 2 _:_) -> pure ()
        other           -> expectationFailure ("Expected H2, got: " <> show other)

    it "parses plain paragraph into Paragraph block" $ do
      let Right doc = parseA2ML "Simple text.\n"
      case documentBlocks doc of
        (Paragraph _:_) -> pure ()
        other           -> expectationFailure ("Expected Paragraph, got: " <> show other)

    it "parses bullet list items as BulletList block" $ do
      let Right doc = parseA2ML "- Alpha\n- Beta\n"
      case documentBlocks doc of
        (BulletList items:_) -> length items `shouldBe` 2
        other                -> expectationFailure ("Expected BulletList, got: " <> show other)

    it "parses blank line as BlankLine block" $ do
      let Right doc = parseA2ML "# H\n\nParagraph.\n"
      documentBlocks doc `shouldContain` [BlankLine]

    it "parses a directive block by name" $ do
      let Right doc = parseA2ML "@abstract:\nSome abstract text.\n@end\n"
      case documentBlocks doc of
        (DirectiveBlock dir:_) -> directiveName dir `shouldBe` DirAbstract
        other                  -> expectationFailure ("Expected DirectiveBlock, got: " <> show other)

  describe "renderA2ML" $ do
    it "renders an empty document (no blocks) as a single newline" $
      renderA2ML (Document Nothing []) `shouldBe` "\n"

    it "renders H1 heading with # prefix and trailing newline" $
      renderA2ML (Document Nothing [Heading 1 [PlainText "Hello"]])
        `shouldBe` "# Hello\n"

    it "renders H3 heading with ### prefix" $
      renderA2ML (Document Nothing [Heading 3 [PlainText "Sub"]])
        `shouldBe` "### Sub\n"

    it "renders paragraph inline content as plain line" $
      renderA2ML (Document Nothing [Paragraph [PlainText "Text here"]])
        `shouldBe` "Text here\n"

    it "renders bullet list items with - prefix" $ do
      let doc = Document Nothing [BulletList [[PlainText "Item A"], [PlainText "Item B"]]]
      renderA2ML doc `shouldBe` "- Item A\n- Item B\n"

  describe "renderInline" $ do
    it "renders PlainText as-is" $
      renderInline (PlainText "Hello") `shouldBe` "Hello"

    it "renders Bold with ** delimiters" $
      renderInline (Bold [PlainText "bold"]) `shouldBe` "**bold**"

    it "renders Italic with * delimiters" $
      renderInline (Italic [PlainText "italic"]) `shouldBe` "*italic*"

    it "renders Link as [text](url)" $
      renderInline (Link "click" "https://example.com")
        `shouldBe` "[click](https://example.com)"

    it "renders InlineRef as @ref(id)" $
      renderInline (InlineRef "section-1") `shouldBe` "@ref(section-1)"

    it "renders InlineCode with backtick delimiters" $
      renderInline (InlineCode "code") `shouldBe` "`code`"
