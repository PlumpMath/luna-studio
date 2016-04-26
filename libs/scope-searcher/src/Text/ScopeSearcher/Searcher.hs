{-# LANGUAGE OverloadedStrings #-}

module Text.ScopeSearcher.Searcher (
      findSuggestions
    , Nameable(..)
    , Weightable(..)
    , Match(..)
    , Submatch(..)
    ) where

import           Prelude

import           Data.Char      (isAlphaNum, isUpper)
import           Data.List      (maximumBy, sort)
import           Data.Maybe     (mapMaybe)
import           Data.Text.Lazy (Text)
import qualified Data.Text.Lazy as Text


class Nameable a where
    name :: a -> Text

class Weightable a where
    weight :: a -> Double

-- nameToLower :: (Nameable a) => a -> Text
-- nameToLower t = Text.toLower (name t)

data Submatch = Submatch { start :: Int
                         , len   :: Int
                         } deriving (Eq, Show)

data Match a = Match Double a [Submatch]
             deriving (Show, Eq)

instance Eq t => Ord (Match t) where
    (Match a _ _) `compare` (Match b _ _) = b `compare` a

findSuggestions :: (Nameable a, Weightable a, Ord (Match a), Eq (Match a)) => [a] -> Text -> [Match a]
findSuggestions index query =
    sort $ (mapMaybe (tryMatch lowQuery) index)
    where
        lowQuery = Text.toLower query

tryMatch :: (Nameable a, Weightable a) => Text -> a -> Maybe (Match a)
tryMatch ""    _                 = Nothing
tryMatch query choice
    | name choice == ""          = Nothing
    | otherwise                  = isSubstringMatch
    where
        choiceRank x     = (weight choice) * rank (name choice) query x
        isSubstringMatch = fmap (\x -> Match (choiceRank x) choice x) bestMatchVal
        bestMatchVal     = bestMatch matches
        bestMatch :: [[Submatch]] -> Maybe [Submatch]
        bestMatch []     = Nothing
        bestMatch m      = Just $ maximumBy (compareMatches $ name choice) m
        matches :: [[Submatch]]
        matches          = findSubsequenceOf query (name choice)


indexesToSubmatch :: [Int] -> [Submatch]
indexesToSubmatch l = reverse $ foldl merge [] l where
    merge []                    next = [Submatch next 1]
    merge ((Submatch s l) : xs) next
        | next == s + l              = (Submatch s (l + 1)) : xs
        | otherwise                  = (Submatch next 1) : (Submatch s l) : xs


findSubsequenceOf :: Text -> Text -> [[Submatch]]
findSubsequenceOf a b = fmap indexesToSubmatch $ findSubsequenceOf' 0 a b where
    findSubsequenceOf' :: Int -> Text -> Text -> [[Int]]
    findSubsequenceOf' _   ""  _                     = [[]]
    findSubsequenceOf' _   _   ""                    = []
    findSubsequenceOf' idx a   b  | isPrefix         = skipHead ++ takePrefix
                                  | otherwise        = skipHead
                                  where
                                       isPrefix      = Text.head (Text.toLower a) == Text.head (Text.toLower b)
                                       -- dropPrefix    = Text.drop . fromIntegral
                                       skipHead      = findSubsequenceOf' (idx + 1) a (Text.tail b)
                                       takePrefix    = fmap (idx :) $ findSubsequenceOf' (idx + 1) (Text.tail a) (Text.tail b)

compareMatches :: Text -> [Submatch] -> [Submatch] -> Ordering
compareMatches name a b = (compareMatchesCapitalsHit name a b) `mappend` (compareFirstPrefixStart a b)

compareMatchesCapitalsHit :: Text -> [Submatch] -> [Submatch] -> Ordering
compareMatchesCapitalsHit name a b = ((countWordBoundaries name a) `compare` (countWordBoundaries name b))

compareFirstPrefixStart :: [Submatch] -> [Submatch] -> Ordering
compareFirstPrefixStart []                 []               = EQ
compareFirstPrefixStart []                 _                = LT
compareFirstPrefixStart _                  []               = GT
compareFirstPrefixStart (Submatch s1 _ : _) (Submatch s2 _ : _) = s2 `compare` s1

rank :: Text -> Text -> [Submatch] -> Double
-- Ranking algorithm heavily inspired on Textmate implementation: https://github.com/textmate/textmate/blob/master/Frameworks/text/src/ranker.cc
rank choice query match
    | n == capitalsTouched = (denom - 1) / denom + penalty
    | otherwise            = let subtract = substrings * n + (n - capitalsTouched) in (denom - subtract) / denom + penalty
    where
        capitalsTouched = fromIntegral $ countWordBoundaries choice match
        totalCapitals   = fromIntegral $ countTrue $ wordBoundaries choice
        n               = fromIntegral $ Text.length query
        m               = fromIntegral $ Text.length choice
        substrings      = fromIntegral $ length match
        denom           = n * (n + 1) + 1.0
        prefixSize      = case match of
            ((Submatch 0 l) : xs) -> fromIntegral l
            _                     -> fromIntegral 0
        penalty = (m - prefixSize) / m / (2.0 * denom) + capitalsTouched / totalCapitals / (4.0 * denom) + n / m / (8.0 * denom)


countWordBoundaries :: Text -> [Submatch] -> Int
countWordBoundaries t sm = sum $ fmap (countTrue . substring) sm where
     wb = wordBoundaries t
     substring :: Submatch -> [Bool]
     substring (Submatch s l) = take l $ drop s wb

countTrue :: [Bool] -> Int
countTrue list = sum $ map fromEnum list

wordBoundaries :: Text -> [Bool]
wordBoundaries t = reverse out where
                   f :: (Bool, [Bool]) -> Char -> (Bool, [Bool])
                   f (atBow, l) c = (((not $ isAlphaNum c) && c /= '.'), (atBow && isAlphaNum c || isUpper c) : l)
                   (_, out) = Text.foldl f (True, []) t