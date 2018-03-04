{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE NoImplicitPrelude     #-}
{-# LANGUAGE OverloadedStrings     #-}
{-# LANGUAGE TemplateHaskell       #-}
{-# LANGUAGE TypeFamilies          #-}
module Handler.Home where

import           Import

getHomeR :: Handler Html
getHomeR = defaultLayout $ do
  setTitle "Welcome To Yesod!"
  $(widgetFile "homepage")
