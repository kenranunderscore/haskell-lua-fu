{-# LANGUAGE DerivingStrategies #-}
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
import GHC.Float (double2Int)

data Position = Position
  { x :: !Double
  , y :: !Double
  }
  deriving stock (Eq, Show)

data RobotState = RobotState
  { position :: Position
  , hitpoints :: Int
  }
  deriving stock (Eq, Show)

newtype Tick = Tick { unTick :: Int }
  deriving stock (Eq, Show)

newtype TickEvent = TickEvent { turn :: Tick }
  deriving stock (Eq, Show)

data Robot = Robot
  { mkInitialState :: Int
  , onTick :: TickEvent -> RobotState -> Int -- FIXME: (a, Action)?
  }

type RobotWithState = (Robot, RobotState)

data GameState = GameState
  { currentTick :: Tick
  , robots :: [RobotWithState]
  }

main :: IO ()
main = do
  SDL.initialize [SDL.InitVideo]
  w <- SDL.createWindow "sdl" SDL.defaultWindow { SDL.windowInitialSize = V2 2000 1000 }
  r <- SDL.createRenderer w (-1) SDL.defaultRenderer 
  SDL.showWindow w

  let robot1 = Robot 0 (\tick _state -> 2 * (unTick . turn) tick)
      robot2 = Robot 17 (\tick _state -> (-5) * (unTick . turn) tick + 1)
      loop state = do
        events <- SDL.pollEvents
        let quit = elem SDL.QuitEvent $ map SDL.eventPayload events
        SDL.delay 20
        SDL.rendererDrawColor r $= V4 4 4 4 1
        SDL.clear r
        drawGame r state
        SDL.present r
        unless quit (loop (advance state))
  loop $ GameState (Tick 0) [(robot1, RobotState (Position 100 250) 100), (robot2, RobotState (Position 700 550) 100)]
  
  SDL.destroyRenderer r
  SDL.destroyWindow w
  SDL.quit
  where
    drawRobot :: SDL.Renderer -> Robot -> RobotState -> IO ()
    drawRobot r robot state = do
      let rect = SDL.Rectangle
           (P $ V2 (fromIntegral . double2Int . x . position $ state) (fromIntegral . double2Int . y . position $ state))
           (V2 50 50)
      SDL.rendererDrawColor r $= V4 150 50 30 1
      SDL.fillRect r $ Just rect

    drawGame r state = do
      mapM_ (uncurry $ drawRobot r) (robots state)

    advance state =
      GameState
        (Tick $ 1 + unTick (currentTick state))
        (map advanceRobot (robots state))
    advanceRobot (robot, state) =
      (robot, state{position = (position state){x = 2 + x (position state)}})
