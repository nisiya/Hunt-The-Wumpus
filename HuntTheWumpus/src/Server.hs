{-# LANGUAGE DeriveDataTypeable #-}
module Server
    ( huntServer
    ) where

import Codec.Binary.UTF8.String
import Network.BufferType
import Network.HTTP.Server (defaultConfig,
                            insertHeader,
                            respond,
                            rqBody,
                            rspBody,
                            serverWith,
                            srvLog,
                            srvPort,
                            Handler,
                            HeaderName(HdrContentLength,HdrContentEncoding),
                            Response,
                            StatusCode(OK)
                           )
import Network.HTTP.Server.Logger (stdLogger)
--import System.Random (getStdGen,randomR)
import System.Environment (getArgs)
import Text.JSON.Generic

type CaveMap = [Room]
data Room = BatRm | PitRm | WumpusRm | EmptyRm
  deriving (Eq,Data,Typeable)

data RoomType = BatRm | PitRm | WumpusRm | EmptyRm
data Room = Room Int RoomType

instance Show Room where
  show BatRm    = "BatRm"
  show PitRm    = "PitRm"
  show WumpusRm = "WumpusRm"
  show EmptyRm  = "EmptyRm"



huntServer :: IO ()
huntServer = do
    args <- map read <$> getArgs
    -- create the map
    caveMap :: CaveMap
    caveMap <- [BatRm, PitRm, WumpusRm, Empty, Empty,
                Empty, Empty, BatRm, PitRm , Empty,
                BatRm, Empty, PitRm, Empty, Empty,
                Empty, Empty, Empty, PitRm, Empty]
    --gen <- getStdGen
    --num <- return (fst $ randomR (1,10) gen :: Int)
    let port = if null args then 2018 else head args
    serverWith defaultConfig { srvLog = stdLogger, srvPort = port } $ handleGuess (Guess num)

handleGuess :: Guess -> Handler String
handleGuess n addr url req =
    if userGuess == n
    then return $ sendText OK ("You win! The number is " ++ (show $ guess userGuess) ++ "!\n")
    else return $ sendText OK ("Try again... the number is not " ++ (show $ guess userGuess) ++ "\n")
  where userGuess = decodeJSON $ rqBody req

sendText :: StatusCode -> String -> Response String
sendText s v = insertHeader HdrContentLength (show (length txt))
             $ insertHeader HdrContentEncoding "UTF-8"
             $ insertHeader HdrContentEncoding "text/plain"
             $ (respond s :: Response String) { rspBody = txt }
  where
    txt = encodeString v

