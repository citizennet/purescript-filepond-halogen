module FilePond
  ( Config
  , ErrorDescription
  , Event(..)
  , FilePond
  , Progress
  , Status(..)
  , URL
  , create
  , setDisabled
  ) where

import Pre
import Data.Bounded.Generic as Data.Bounded.Generic
import Data.Enum.Generic as Data.Enum.Generic
import Data.Generic.Rep as Data.Generic.Rep
import Data.MediaType as Data.MediaType
import Data.Nullable as Data.Nullable
import Data.Show.Generic as Data.Show.Generic
import Effect.Aff as Effect.Aff
import Effect.Uncurried as Effect.Uncurried
import Foreign as Foreign
import URI as URI
import URI.HostPortPair as URI.HostPortPair
import URI.URI as URI.URI
import Web.File.File as Web.File.File
import Web.HTML as Web.HTML

-- | A synonym to clean up the long type of `URI _ _ _ _ _ _ _`.
type URL
  = URI.URI URI.UserInfo (URI.HostPortPair.HostPortPair URI.Host URI.Port) URI.Path URI.HierPath URI.Query URI.Fragment

type Config uploadedFile
  = { disabled :: Boolean
    -- The file id is appended to the `download` url when fetching uploaded files.
    -- We don't use a function for loading uploaded files as it would require a
    -- CORS-enabled endpoint, which we unfortunately don't have.
    , download :: URL
    , file :: Maybe uploadedFile
    -- FilePond stores file ids internally instead of a parametrized type so we
    -- need a way of converting an `uploadedFile` to a unique id.
    , getId :: uploadedFile -> String
    , mediaTypes :: Array Data.MediaType.MediaType
    , upload :: (Progress -> Effect Unit) -> Web.File.File.File -> Aff (Either String uploadedFile)
    }

type ErrorDescription
  = { type :: String
    , code :: Number
    , body :: String
    }

data Event uploadedFile
  = AddFileProgressed { file :: Web.File.File.File, progress :: Number }
  | AddFileStarted Web.File.File.File
  | AllFilesProcessed
  | ErrorReceived { error :: ErrorDescription, file :: Maybe Web.File.File.File, status :: Status }
  | FileActivated Web.File.File.File
  | FileAdded { error :: Maybe ErrorDescription, file :: Web.File.File.File }
  | FilePrepared { file :: Web.File.File.File, output :: Foreign.Foreign }
  | FileProcessed { error :: Maybe ErrorDescription, file :: Web.File.File.File }
  | FileRemoved { error :: Maybe ErrorDescription, file :: Web.File.File.File }
  | FilesReordered (Array Web.File.File.File)
  | FilesUpdated (Array Web.File.File.File)
  | Initialized
  | ProcessFileAborted Web.File.File.File
  | ProcessFileProgressed { file :: Web.File.File.File, progress :: Number }
  | ProcessFileReverted Web.File.File.File
  | ProcessFileStarted Web.File.File.File
  | UploadResponse uploadedFile
  | WarningReceived { warning :: ErrorDescription, file :: Maybe Web.File.File.File, status :: Status }

foreign import data FilePond :: Type -> Type

type ForeignProcessFunction
  = Effect.Uncurried.EffectFn7
      String -- fieldName
      Web.File.File.File -- file
      {} -- metadata
      (Effect.Uncurried.EffectFn1 String Unit) -- onLoad
      (Effect.Uncurried.EffectFn1 String Unit) -- onError
      ForeignProgressFunction
      (Effect Unit) -- onAbort
      { abort :: Effect Unit }

type ForeignProgressFunction
  = Effect.Uncurried.EffectFn3
      Boolean -- lengthComputable
      Number -- loaded
      Number -- total
      Unit

type InternalConfig uploadedFile
  = { acceptedFileTypes :: Array Data.MediaType.MediaType
    , disabled :: Boolean
    , fileId :: Data.Nullable.Nullable String
    , load :: String
    , process :: FilePond uploadedFile -> ForeignProcessFunction
    }

type Progress
  -- The `lengthComputable` flag indicates whether the resource has a length
  -- that can be calculated. If not, the `total` has no significant value.
  -- Setting this to `false` switches the FilePond loading indicator to infinite
  -- mode.
  = { lengthComputable :: Boolean
    , loaded :: Number
    , total :: Number
    }

data Status
  = Empty
  | Idle
  | Error
  | Busy
  | Ready

derive instance genericStatus :: Data.Generic.Rep.Generic Status _

derive instance eqStatus :: Eq Status

derive instance ordStatus :: Ord Status

instance enumStatus :: Enum Status where
  succ = Data.Enum.Generic.genericSucc
  pred = Data.Enum.Generic.genericPred

instance boundedStatus :: Bounded Status where
  top = Data.Bounded.Generic.genericTop
  bottom = Data.Bounded.Generic.genericBottom

instance boundedEnumStatus :: BoundedEnum Status where
  cardinality = Data.Enum.Generic.genericCardinality
  toEnum = Data.Enum.Generic.genericToEnum
  fromEnum = Data.Enum.Generic.genericFromEnum

instance showStatus :: Show Status where
  show = Data.Show.Generic.genericShow

foreign import _create ::
  forall uploadedFile.
  Effect.Uncurried.EffectFn2
    (InternalConfig uploadedFile)
    Web.HTML.HTMLElement
    (FilePond uploadedFile)

-- | Initialize a FilePond container/component inside the specified
-- | `Web.HTML.HTMLElement`.
create ::
  forall uploadedFile.
  Config uploadedFile ->
  Web.HTML.HTMLElement ->
  Effect (FilePond uploadedFile)
create config element = do
  let
    internalConfig =
      { acceptedFileTypes: config.mediaTypes
      , disabled: config.disabled
      , fileId: Data.Nullable.toNullable (map config.getId config.file)
      , load: urlToString config.download
      , process: toForeignProcessFunction config
      }
  Effect.Uncurried.runEffectFn2 _create internalConfig element
  where
  urlToString :: URL -> String
  urlToString =
    URI.URI.print
      { printUserInfo: identity
      , printHosts: URI.HostPortPair.print identity identity
      , printPath: identity
      , printHierPath: identity
      , printQuery: identity
      , printFragment: identity
      }

fromForeignProgressFunction ::
  ForeignProgressFunction ->
  Progress ->
  Effect Unit
fromForeignProgressFunction onProgress progress =
  Effect.Uncurried.runEffectFn3
    onProgress
    progress.lengthComputable
    progress.loaded
    progress.total

foreign import onUploadResponse ::
  forall uploadedFile.
  FilePond uploadedFile ->
  uploadedFile ->
  Effect Unit

foreign import setDisabled ::
  forall uploadedFile.
  FilePond uploadedFile ->
  Boolean ->
  Effect Unit

toForeignProcessFunction ::
  forall uploadedFile.
  Config uploadedFile ->
  FilePond uploadedFile ->
  ForeignProcessFunction
toForeignProcessFunction config filepond =
  Effect.Uncurried.mkEffectFn7 \_ file _ onLoad onError onProgress onAbort -> do
    fiber <-
      Effect.Aff.launchAff do
        result <- config.upload (fromForeignProgressFunction onProgress) file
        liftEffect case result of
          Left error' -> Effect.Uncurried.runEffectFn1 onError error'
          Right uploadedFile -> do
            Effect.Uncurried.runEffectFn1 onLoad (config.getId uploadedFile)
            onUploadResponse filepond uploadedFile
    pure
      { abort:
          do
            Effect.Aff.launchAff_ (Effect.Aff.killFiber (Effect.Aff.error "request canceled") fiber)
            onAbort
      }
