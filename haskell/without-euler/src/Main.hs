{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE DeriveAnyClass #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE NoImplicitPrelude #-}
module Main where

import Control.Monad.IO.Class (liftIO)

import Data.Text (Text)
import Data.Aeson (ToJSON)
import Data.Maybe (fromMaybe)
import GHC.Generics (Generic)

import qualified Data.HashMap.Strict as HM

import Network.Wai.Handler.Warp (run)
import Relude
import Servant

-- Response for /get_foo 
data FooMessage = FooMessage
  { msg :: Text
  }
  deriving (Show, Eq, Ord, Generic, ToJSON)

type FooAPI =
  ( "get_foo"
    :> QueryParam "log" Int
    :> Get '[JSON] FooMessage
  )

fooAPI :: Proxy FooAPI
fooAPI = Proxy


fooServer :: Server FooAPI
fooServer = getFoo


-- Warp HTTP application
fooApp :: Application
fooApp = serve fooAPI fooServer


fooFlow :: Int -> IO FooMessage
fooFlow should_log = do
  case should_log of
    0 ->
      pure $ FooMessage $ fromMaybe "default" (HM.lookup 1 myHashMap)
    otherwise -> do
      print $ show $ HM.toList myHashMap
      pure $ FooMessage "done"
  where
    myHashMap :: HM.HashMap Int Text
    myHashMap = HM.fromList [(i, show i) | i <- [1..20000000]]

getFoo :: Maybe Int -> Handler FooMessage
getFoo should_log = liftIO $ fooFlow (fromMaybe 0 should_log)

-- Foo server entry point
runFooServer :: Int -> IO ()
runFooServer port = do
  putStrLn $ "Starting Foo Server on port " ++ show port ++ "..."
  run port fooApp

main :: IO ()
main = runFooServer 8081
