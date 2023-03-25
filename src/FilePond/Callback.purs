module FilePond.Callback
  ( onActivateFile
  , onAddFileDone
  , onAddFileProgress
  , onAddFileStart
  , onError
  , onInit
  , onPrepareFile
  , onProcessAllFilesDone
  , onProcessFileAbort
  , onProcessFileDone
  , onProcessFileProgress
  , onProcessFileRevert
  , onProcessFileStart
  , onRemoveFile
  , onReorderFiles
  , onUpdateFiles
  , onUploadResponse
  , onWarning
  ) where

import CitizenNet.Prelude

import Data.Enum as Data.Enum
import Data.Nullable as Data.Nullable
import Effect.Uncurried as Effect.Uncurried
import FilePond as FilePond
import Foreign as Foreign
import Web.File.File as Web.File.File

-- Called when a file is clicked or tapped.
onActivateFile ::
  forall uploadedFile.
  FilePond.FilePond uploadedFile ->
  (Web.File.File.File -> Effect Unit) ->
  Effect Unit
onActivateFile filepond callback = Effect.Uncurried.runEffectFn2 _onActivateFile filepond (Effect.Uncurried.mkEffectFn1 callback)

foreign import _onActivateFile ::
  forall uploadedFile.
  Effect.Uncurried.EffectFn2
    (FilePond.FilePond uploadedFile)
    (Effect.Uncurried.EffectFn1 Web.File.File.File Unit)
    Unit

-- If no error, file has been successfully loaded.
onAddFileDone ::
  forall uploadedFile.
  FilePond.FilePond uploadedFile ->
  ({ error :: Maybe FilePond.ErrorDescription, file :: Web.File.File.File } -> Effect Unit) ->
  Effect Unit
onAddFileDone filepond callback =
  Effect.Uncurried.runEffectFn2 _onAddFileDone filepond
    ( Effect.Uncurried.mkEffectFn2 \nError file ->
        callback { error: (Data.Nullable.toMaybe nError), file }
    )

foreign import _onAddFileDone ::
  forall uploadedFile.
  Effect.Uncurried.EffectFn2
    (FilePond.FilePond uploadedFile)
    (Effect.Uncurried.EffectFn2 (Data.Nullable.Nullable FilePond.ErrorDescription) Web.File.File.File Unit)
    Unit

-- Made progress loading a file.
onAddFileProgress ::
  forall uploadedFile.
  FilePond.FilePond uploadedFile ->
  ({ file :: Web.File.File.File, progress :: Number } -> Effect Unit) ->
  Effect Unit
onAddFileProgress filepond callback =
  Effect.Uncurried.runEffectFn2 _onAddFileProgress filepond
    (Effect.Uncurried.mkEffectFn2 \file progress -> callback { file, progress })

foreign import _onAddFileProgress ::
  forall uploadedFile.
  Effect.Uncurried.EffectFn2
    (FilePond.FilePond uploadedFile)
    (Effect.Uncurried.EffectFn2 Web.File.File.File Number Unit)
    Unit

-- Started file load.
onAddFileStart ::
  forall uploadedFile.
  FilePond.FilePond uploadedFile ->
  (Web.File.File.File -> Effect Unit) ->
  Effect Unit
onAddFileStart filepond callback = Effect.Uncurried.runEffectFn2 _onAddFileStart filepond (Effect.Uncurried.mkEffectFn1 callback)

foreign import _onAddFileStart ::
  forall uploadedFile.
  Effect.Uncurried.EffectFn2
    (FilePond.FilePond uploadedFile)
    (Effect.Uncurried.EffectFn1 Web.File.File.File Unit)
    Unit

{- FilePond instance throws an error. Optionally receives
file if error is related to a file object. -}
onError ::
  forall uploadedFile.
  FilePond.FilePond uploadedFile ->
  ({ error :: FilePond.ErrorDescription, file :: Maybe Web.File.File.File, status :: FilePond.Status } -> Effect Unit) ->
  Effect Unit
onError filepond callback =
  Effect.Uncurried.runEffectFn2 _onError filepond
    ( Effect.Uncurried.mkEffectFn3 \error nFile int -> case Data.Enum.toEnum int of
        Nothing -> pure unit
        Just (status :: FilePond.Status) ->
          callback
            { error
            , file: Data.Nullable.toMaybe nFile
            , status
            }
    )

foreign import _onError ::
  forall uploadedFile.
  Effect.Uncurried.EffectFn2
    (FilePond.FilePond uploadedFile)
    (Effect.Uncurried.EffectFn3 FilePond.ErrorDescription (Data.Nullable.Nullable Web.File.File.File) Int Unit)
    Unit

-- FilePond instance has been created and is ready.
onInit ::
  forall uploadedFile.
  FilePond.FilePond uploadedFile ->
  (Unit -> Effect Unit) ->
  Effect Unit
onInit filepond callback = Effect.Uncurried.runEffectFn2 _onInit filepond (Effect.Uncurried.mkEffectFn1 callback)

foreign import _onInit ::
  forall uploadedFile.
  Effect.Uncurried.EffectFn2
    (FilePond.FilePond uploadedFile)
    (Effect.Uncurried.EffectFn1 Unit Unit)
    Unit

{- File has been transformed by the transform plugin or
another plugin subscribing to the prepare_output filter.
It receives the file item and the output data. -}
onPrepareFile ::
  forall uploadedFile.
  FilePond.FilePond uploadedFile ->
  ({ file :: Web.File.File.File, output :: Foreign.Foreign } -> Effect Unit) ->
  Effect Unit
onPrepareFile filepond callback =
  Effect.Uncurried.runEffectFn2 _onPrepareFile filepond
    (Effect.Uncurried.mkEffectFn2 \file output -> callback { file, output })

foreign import _onPrepareFile ::
  forall uploadedFile.
  Effect.Uncurried.EffectFn2
    (FilePond.FilePond uploadedFile)
    (Effect.Uncurried.EffectFn2 Web.File.File.File Foreign.Foreign Unit)
    Unit

-- Called when all files in the list have been processed.
onProcessAllFilesDone ::
  forall uploadedFile.
  FilePond.FilePond uploadedFile ->
  (Unit -> Effect Unit) ->
  Effect Unit
onProcessAllFilesDone filepond callback = Effect.Uncurried.runEffectFn2 _onProcessAllFilesDone filepond (Effect.Uncurried.mkEffectFn1 callback)

foreign import _onProcessAllFilesDone ::
  forall uploadedFile.
  Effect.Uncurried.EffectFn2
    (FilePond.FilePond uploadedFile)
    (Effect.Uncurried.EffectFn1 Unit Unit)
    Unit

-- Aborted processing of a file.
onProcessFileAbort ::
  forall uploadedFile.
  FilePond.FilePond uploadedFile ->
  (Web.File.File.File -> Effect Unit) ->
  Effect Unit
onProcessFileAbort filepond callback = Effect.Uncurried.runEffectFn2 _onProcessFileAbort filepond (Effect.Uncurried.mkEffectFn1 callback)

foreign import _onProcessFileAbort ::
  forall uploadedFile.
  Effect.Uncurried.EffectFn2
    (FilePond.FilePond uploadedFile)
    (Effect.Uncurried.EffectFn1 Web.File.File.File Unit)
    Unit

-- If no error, Processing of a file has been completed.
onProcessFileDone ::
  forall uploadedFile.
  FilePond.FilePond uploadedFile ->
  ({ error :: Maybe FilePond.ErrorDescription, file :: Web.File.File.File } -> Effect Unit) ->
  Effect Unit
onProcessFileDone filepond callback =
  Effect.Uncurried.runEffectFn2 _onProcessFileDone filepond
    ( Effect.Uncurried.mkEffectFn2 \nError file ->
        callback { error: (Data.Nullable.toMaybe nError), file }
    )

foreign import _onProcessFileDone ::
  forall uploadedFile.
  Effect.Uncurried.EffectFn2
    (FilePond.FilePond uploadedFile)
    (Effect.Uncurried.EffectFn2 (Data.Nullable.Nullable FilePond.ErrorDescription) Web.File.File.File Unit)
    Unit

-- Made progress processing a file.
onProcessFileProgress ::
  forall uploadedFile.
  FilePond.FilePond uploadedFile ->
  ({ file :: Web.File.File.File, progress :: Number } -> Effect Unit) ->
  Effect Unit
onProcessFileProgress filepond callback =
  Effect.Uncurried.runEffectFn2 _onProcessFileProgress filepond
    (Effect.Uncurried.mkEffectFn2 \file progress -> callback { file, progress })

foreign import _onProcessFileProgress ::
  forall uploadedFile.
  Effect.Uncurried.EffectFn2
    (FilePond.FilePond uploadedFile)
    (Effect.Uncurried.EffectFn2 Web.File.File.File Number Unit)
    Unit

-- Processing of a file has been reverted.
onProcessFileRevert ::
  forall uploadedFile.
  FilePond.FilePond uploadedFile ->
  (Web.File.File.File -> Effect Unit) ->
  Effect Unit
onProcessFileRevert filepond callback = Effect.Uncurried.runEffectFn2 _onProcessFileRevert filepond (Effect.Uncurried.mkEffectFn1 callback)

foreign import _onProcessFileRevert ::
  forall uploadedFile.
  Effect.Uncurried.EffectFn2
    (FilePond.FilePond uploadedFile)
    (Effect.Uncurried.EffectFn1 Web.File.File.File Unit)
    Unit

-- Started processing a file.
onProcessFileStart ::
  forall uploadedFile.
  FilePond.FilePond uploadedFile ->
  (Web.File.File.File -> Effect Unit) ->
  Effect Unit
onProcessFileStart filepond callback = Effect.Uncurried.runEffectFn2 _onProcessFileStart filepond (Effect.Uncurried.mkEffectFn1 callback)

foreign import _onProcessFileStart ::
  forall uploadedFile.
  Effect.Uncurried.EffectFn2
    (FilePond.FilePond uploadedFile)
    (Effect.Uncurried.EffectFn1 Web.File.File.File Unit)
    Unit

-- File has been removed.
onRemoveFile ::
  forall uploadedFile.
  FilePond.FilePond uploadedFile ->
  ({ error :: Maybe FilePond.ErrorDescription, file :: Web.File.File.File } -> Effect Unit) ->
  Effect Unit
onRemoveFile filepond callback =
  Effect.Uncurried.runEffectFn2 _onRemoveFile filepond
    ( Effect.Uncurried.mkEffectFn2 \nError file ->
        callback { error: (Data.Nullable.toMaybe nError), file }
    )

foreign import _onRemoveFile ::
  forall uploadedFile.
  Effect.Uncurried.EffectFn2
    (FilePond.FilePond uploadedFile)
    (Effect.Uncurried.EffectFn2 (Data.Nullable.Nullable FilePond.ErrorDescription) Web.File.File.File Unit)
    Unit

-- Called when the files have been reordered
onReorderFiles ::
  forall uploadedFile.
  FilePond.FilePond uploadedFile ->
  (Array Web.File.File.File -> Effect Unit) ->
  Effect Unit
onReorderFiles filepond callback = Effect.Uncurried.runEffectFn2 _onReorderFiles filepond (Effect.Uncurried.mkEffectFn1 callback)

foreign import _onReorderFiles ::
  forall uploadedFile.
  Effect.Uncurried.EffectFn2
    (FilePond.FilePond uploadedFile)
    (Effect.Uncurried.EffectFn1 (Array Web.File.File.File) Unit)
    Unit

-- A file has been added or removed, receives a list of file items.
onUpdateFiles ::
  forall uploadedFile.
  FilePond.FilePond uploadedFile ->
  (Array Web.File.File.File -> Effect Unit) ->
  Effect Unit
onUpdateFiles filepond callback = Effect.Uncurried.runEffectFn2 _onUpdateFiles filepond (Effect.Uncurried.mkEffectFn1 callback)

foreign import _onUpdateFiles ::
  forall uploadedFile.
  Effect.Uncurried.EffectFn2
    (FilePond.FilePond uploadedFile)
    (Effect.Uncurried.EffectFn1 (Array Web.File.File.File) Unit)
    Unit

-- Called when the upload server sends a final response
onUploadResponse ::
  forall a uploadedFile.
  FilePond.FilePond uploadedFile ->
  (a -> Effect Unit) ->
  Effect Unit
onUploadResponse filepond callback = Effect.Uncurried.runEffectFn2 _onUploadResponse filepond (Effect.Uncurried.mkEffectFn1 callback)

foreign import _onUploadResponse ::
  forall a uploadedFile.
  Effect.Uncurried.EffectFn2
    (FilePond.FilePond uploadedFile)
    (Effect.Uncurried.EffectFn1 a Unit)
    Unit

{- FilePond instance throws a warning. For instance
when the maximum amount of files has been reached.
Optionally receives file if error is related to a
file object. -}
onWarning ::
  forall uploadedFile.
  FilePond.FilePond uploadedFile ->
  ({ warning :: FilePond.ErrorDescription, file :: Maybe Web.File.File.File, status :: FilePond.Status } -> Effect Unit) ->
  Effect Unit
onWarning filepond callback =
  Effect.Uncurried.runEffectFn2 _onWarning filepond
    ( Effect.Uncurried.mkEffectFn3 \warning nFile int -> case Data.Enum.toEnum int of
        Nothing -> pure unit
        Just (status :: FilePond.Status) ->
          callback
            { warning
            , file: Data.Nullable.toMaybe nFile
            , status
            }
    )

foreign import _onWarning ::
  forall uploadedFile.
  Effect.Uncurried.EffectFn2
    (FilePond.FilePond uploadedFile)
    (Effect.Uncurried.EffectFn3 FilePond.ErrorDescription (Data.Nullable.Nullable Web.File.File.File) Int Unit)
    Unit
