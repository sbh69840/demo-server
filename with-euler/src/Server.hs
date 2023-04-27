{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE DeriveAnyClass #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE TypeApplications #-}
module Server where

import qualified Data.HashMap.Strict as HM

import           EulerHS.Prelude
import qualified EulerHS.Runtime      as R
import qualified EulerHS.Language     as L
import qualified EulerHS.Interpreters as I

import Network.Wai.Handler.Warp (run)
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



data Env = Env !R.FlowRuntime
type MethodHandler = ReaderT Env (ExceptT ServerError IO)
type AppServer  = ServerT FooAPI MethodHandler


-- Handlers connected to the API
fooServer' :: AppServer
fooServer' = getFoo

-- Conversion between handlers and server monad stacks
fooServer :: Env -> Server FooAPI
fooServer env = hoistServer fooAPI f fooServer'
  where
    f :: ReaderT Env (ExceptT ServerError IO) a -> Handler a
    f r = do
      eResult <- liftIO $ runExceptT $ runReaderT r env
      case eResult of
        Left err  -> throwError err
        Right res -> pure res


-- Warp HTTP application
fooApp :: Env -> Application
fooApp = serve fooAPI . fooServer


-- Wrapper to run a flow with a predefined flow runtime.
runFlow :: L.Flow a -> MethodHandler a
runFlow flow = do
  Env flowRt <- ask
  eRes <- lift $ lift $ try $ I.runFlow flowRt flow
  case eRes of
    Left (err :: SomeException) -> do
      liftIO $ putStrLn @String $ "Exception handled: " <> show err
      throwError err500
    Right res -> pure res


fooFlow :: Int -> L.Flow FooMessage
fooFlow should_log = do
  case should_log of
    0 ->
      pure $ FooMessage $ fromMaybe "default" (HM.lookup 1 myHashMap)
    otherwise -> do
      L.logDebug "hashmap" $ show $ HM.toList myHashMap
      pure $ FooMessage "done"
  where
    myHashMap :: HM.HashMap Int Text
    myHashMap = HM.fromList [(i, show i) | i <- [1..20000000]]

-- Method handlers
getFoo :: Maybe Int -> MethodHandler FooMessage
getFoo should_log = do
  runFlow $ fooFlow (fromMaybe 0 should_log)

-- Foo server entry point
runFooServer :: R.FlowRuntime -> Int -> IO ()
runFooServer flowRt port = do
  putStrLn @String $ "Starting Foo Server on port " ++ show port ++ "..."
  let env = Env flowRt
  run port $ fooApp env
