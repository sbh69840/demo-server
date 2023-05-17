{-# LANGUAGE OverloadedStrings #-}
import Database.Redis (connect, defaultConnectInfo, runRedis, incr, get, set)
import Control.Monad (replicateM)
import Control.Monad.IO.Class (liftIO)
import System.CPUTime (getCPUTime)

iter = 100000

main = do
  conn <- connect defaultConnectInfo
  let
    key = "foo"
    runUnPipelined = show <$> do
      runRedis conn (set key "1")
      replicateM iter $ do
        runRedis conn $ incr key
        runRedis conn $ get key
  tNoPipe <- deltaT $ runUnPipelined >>= print
  putStrLn $ (show tNoPipe) ++ " micro secs"
  where
    deltaT redis = do
        start <- liftIO getCPUTime
        _ <- redis
        end <- liftIO getCPUTime
        let inMicroSeconds = fromIntegral (end - start) / 1000000 :: Double
        return $  inMicroSeconds / (fromIntegral iter)
