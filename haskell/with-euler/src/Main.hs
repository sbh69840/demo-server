{-# LANGUAGE OverloadedStrings #-}
module Main where

import           EulerHS.Prelude

import qualified EulerHS.Types         as T
import qualified EulerHS.Runtime       as R
import Server

loggerConfig :: T.LoggerConfig
loggerConfig = T.LoggerConfig
    { T._isAsync = False
    , T._logLevel = T.Debug
    , T._logFilePath = "/tmp/logs/myFlow.log"
    , T._logToConsole = True
    , T._logToFile = False
    , T._maxQueueSize = 1000
    , T._logRawSql = T.UnsafeLogSQL_DO_NOT_USE_IN_PRODUCTION
    }

main :: IO ()
main = do
  let mkLoggerRt = R.createLoggerRuntime T.defaultFlowFormatter loggerConfig

  R.withFlowRuntime (Just mkLoggerRt) $ \flowRt ->
    runFooServer flowRt 8080
