module DevelMain where

import           Application              (getApplicationRepl, shutdownApp)
import           Prelude

import           Control.Concurrent
import           Control.Exception        (finally)
import           Control.Monad            ((>=>))
import           Data.IORef
import           Foreign.Store
import           GHC.Word
import           Network.Wai.Handler.Warp

update :: IO ()
update = do
    mtidStore <- lookupStore tidStoreNum
    case mtidStore of
      -- no server running
        Nothing -> do
            done <- storeAction doneStore newEmptyMVar
            tid  <- start done
            _    <- storeAction (Store tidStoreNum) (newIORef tid)
            return ()
        -- server is already running
        Just tidStore -> restartAppInNewThread tidStore
  where
    doneStore :: Store (MVar ())
    doneStore = Store 0

    -- shut the server down with killThread and wait for the done signal
    restartAppInNewThread :: Store (IORef ThreadId) -> IO ()
    restartAppInNewThread tidStore = modifyStoredIORef tidStore $ \tid -> do
        killThread tid
        withStore doneStore takeMVar
        readStore doneStore >>= start


    -- | Start the server in a separate thread.
    start
        :: MVar () -- ^ Written to when the thread is killed.
        -> IO ThreadId
    start done = do
        (port, site, app) <- getApplicationRepl
        forkIO
            (finally (runSettings (setPort port defaultSettings) app)
                        -- Note that this implies concurrency
                        -- between shutdownApp and the next app that is starting.
                        -- Normally this should be fine
                     (putMVar done () >> shutdownApp site)
            )

-- | kill the server
shutdown :: IO ()
shutdown = do
    mtidStore <- lookupStore tidStoreNum
    case mtidStore of
      -- no server running
        Nothing       -> putStrLn "no Yesod app running"
        Just tidStore -> do
            withStore tidStore $ readIORef >=> killThread
            putStrLn "Yesod app is shutdown"

tidStoreNum :: Word32
tidStoreNum = 1

modifyStoredIORef :: Store (IORef a) -> (a -> IO a) -> IO ()
modifyStoredIORef store f = withStore store $ \ref -> do
    v <- readIORef ref
    f v >>= writeIORef ref
