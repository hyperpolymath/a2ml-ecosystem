-- SPDX-License-Identifier: MPL-2.0
-- (MPL-2.0 preferred; MPL-2.0 required for Hackage OSI-approved policy)
--
-- bench/Main.hs — Criterion benchmarks for a2ml-haskell.
--
-- Measures parse and render throughput across a range of document sizes
-- and content types to identify performance regressions.
--
-- Run with: cabal bench

module Main (main) where

import           Criterion.Main

import           Data.A2ML.Parser   (parseA2ML)
import           Data.A2ML.Renderer (renderA2ML)
import           Data.A2ML.Types

import qualified Data.Text as T

-- ---------------------------------------------------------------------------
-- Fixtures
-- ---------------------------------------------------------------------------

-- | A small document: one heading and a paragraph.
smallDoc :: T.Text
smallDoc = T.unlines
  [ "# Hello World"
  , ""
  , "A simple introduction paragraph."
  ]

-- | A medium document with multiple sections and inline markup.
mediumDoc :: T.Text
mediumDoc = T.unlines
  [ "# Main Title"
  , ""
  , "Introduction paragraph with **bold** and *italic* text."
  , ""
  , "## Section One"
  , ""
  , "First section paragraph with `inline code` and [a link](https://example.com)."
  , ""
  , "- Bullet item alpha"
  , "- Bullet item beta"
  , "- Bullet item gamma"
  , ""
  , "## Section Two"
  , ""
  , "@abstract:"
  , "This is the abstract body spanning"
  , "multiple lines of text."
  , "@end"
  , ""
  , "Concluding paragraph."
  ]

-- | A large document with 30 sections.
largeDoc :: T.Text
largeDoc =
  let header = "# Large Document\n\n"
      section i = T.unlines
        [ "## Section " <> T.pack (show (i :: Int))
        , ""
        , "Paragraph " <> T.pack (show i) <> " with **bold** and *italic* and `code`."
        , ""
        , "- Item A in section " <> T.pack (show i)
        , "- Item B in section " <> T.pack (show i)
        , ""
        ]
  in header <> mconcat (map section [1..30])

-- | Parse mediumDoc once for render benchmarks.
parsedMedium :: Document
parsedMedium = case parseA2ML mediumDoc of
  Right d -> d
  Left  e -> error ("Fixture parse failed: " <> show e)

-- ---------------------------------------------------------------------------
-- Benchmark suite
-- ---------------------------------------------------------------------------

main :: IO ()
main = defaultMain
  [ bgroup "parse"
      [ bench "small document"   $ nf parseA2ML smallDoc
      , bench "medium document"  $ nf parseA2ML mediumDoc
      , bench "large document"   $ nf parseA2ML largeDoc
      ]
  , bgroup "render"
      [ bench "medium document"  $ nf renderA2ML parsedMedium
      ]
  , bgroup "roundtrip"
      [ bench "small roundtrip"  $ nf (\d -> parseA2ML (renderA2ML d))
                                       (case parseA2ML smallDoc of Right x -> x; _ -> error "bad")
      , bench "medium roundtrip" $ nf (\d -> parseA2ML (renderA2ML d)) parsedMedium
      ]
  ]
