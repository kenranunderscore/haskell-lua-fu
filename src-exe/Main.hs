{-# LANGUAGE TypeApplications #-}
{-# LANGUAGE OverloadedStrings #-}

import Control.Monad (unless)
import HsLua
import Control.Monad (void)
import Data.Version (makeVersion)
import Prelude
import qualified SDL
import SDL (($=))
import SDL.Vect

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
  SDL.initialize [SDL.InitVideo]
  w <- SDL.createWindow "sdl" SDL.defaultWindow { SDL.windowInitialSize = V2 2000 1000 }
  r <- SDL.createRenderer w (-1) SDL.defaultRenderer 
  SDL.showWindow w
  SDL.clear r
  let rect = SDL.Rectangle (P $ V2 200 300) (V2 100 100)
  let loop = do
        events <- SDL.pollEvents
        let quit = elem SDL.QuitEvent $ map SDL.eventPayload events
        SDL.rendererDrawColor r $= V4 140 100 30 1
        SDL.drawRect r $ Just rect
        SDL.present r
        unless quit loop
  loop
  SDL.destroyRenderer r
  SDL.destroyWindow w
  SDL.quit
