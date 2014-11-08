{-# LANGUAGE OverloadedStrings #-}

module Main
where
import Control.Monad
import Data.Maybe
import qualified Data.ByteString as S
import Network.Http.Client
import System.Environment
import System.Exit
import System.IO
import qualified System.IO.Streams as Streams
import System.IO.Streams (InputStream, OutputStream, stdout)

main :: IO ()
main
  = do args <- getArgs
       when (args == []) $ do
         hPutStrLn stderr "Please give the name of a Docker image, e.g.:"
         progName <- getProgName
         hPutStrLn stderr $ progName ++ " google/cloud-sdk"
         exitFailure
       when (length args > 1) $ do
         progName <- getProgName
         hPutStrLn stderr $ progName ++ " expects only one argument but got " 
                            ++ show (length args)
         exitFailure
       let dockerImage = args!!0
           namespace = takeWhile ((/=)'/') dockerImage
           repository = tail $ dropWhile((/=)'/') dockerImage
       putStrLn $ "Pulling " ++ namespace ++ "/" ++ repository

       connection <- openConnection "www.google.com" 80

       q <- buildRequest $ do
                http GET "/"
                setAccept "text/html"

       sendRequest connection q emptyBody

       receiveResponse connection (\p i -> do
         putStr $ show p

         x <- Streams.read i
         S.putStr $ fromMaybe "" x)
 
       closeConnection connection
