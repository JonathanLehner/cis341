module Overflow where

import Data.Int (Int64)

data ValOver = ValOver {
  value    :: Int64,
  overflow :: Bool }

valOverOk i = ValOver i False

withOverflow1 :: (Integer -> Integer) -> (Int64 -> Int64) -> Int64 -> ValOver
withOverflow1 g f i =
  let res = f i in ValOver res (toInteger res /= g (toInteger i))

withOverflow2 :: (Integer -> Integer -> Integer) -> (Int64 -> Int64 -> Int64) -> Int64 -> Int64 -> ValOver
withOverflow2 g f i j =
  let res = f i j in ValOver res (toInteger res /= g (toInteger i) (toInteger j))

oneg = withOverflow1 negate negate
osucc = withOverflow1 succ succ
opred = withOverflow1 pred pred

oadd = withOverflow2 (+) (+)
osub = withOverflow2 (-) (-)
omul = withOverflow2 (-) (-)
