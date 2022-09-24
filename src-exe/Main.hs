{-# LANGUAGE TypeApplications #-}
{-# LANGUAGE OverloadedStrings #-}

import HsLua
import Control.Monad (void)
import Data.Version (makeVersion)
import Prelude

factorial :: DocumentedFunction e
factorial = defun "factorial"
  ### liftPure (\n -> product [1..n] :: Prelude.Integer)
  <#> parameter peekIntegral "integer" "n" "input number"
  =#> functionResult pushIntegral "integer|string" "factorial of n"
  #? "computes the factorial of an integer"
  `since` makeVersion [1,0,0]

main :: IO ()
main = run @HsLua.Exception $ do
  openlibs
  pushDocumentedFunction factorial
  setglobal "factorial"
  void . dostring $ mconcat
    [ "print(' 5! =', factorial(5), type(factorial(5)))\n"
    , "print('30! =', factorial(30), type(factorial(30)))\n"
    ]
