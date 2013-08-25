---------------------------------------------------------------------------
-- Copyright (C) Flowbox, Inc - All Rights Reserved
-- Unauthorized copying of this file, via any medium is strictly prohibited
-- Proprietary and confidential
-- Flowbox Team <contact@flowbox.io>, 2013
---------------------------------------------------------------------------

module MathSpec where

import Test.Hspec

absolute x = x

main :: IO ()
main = hspec spec

spec :: Spec
spec = do
  describe "absolute" $ do
    it "returns the original number when given a positive input" $
      absolute 1 `shouldBe` 1

    it "returns a positive number when given a negative input" $
      absolute (-1) `shouldBe` 1

    it "returns zero when given zero" $
      absolute 0 `shouldBe` 0