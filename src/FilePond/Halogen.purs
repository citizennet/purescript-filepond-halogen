module FilePond.Halogen
  ( create
  , subscribe
  ) where

import Pre

import FilePond as FilePond
import FilePond.Callback as FilePond.Callback
import Halogen as Halogen
import Halogen.Query as Halogen.Query
import Halogen.Subscription as Halogen.Subscription
import Web.HTML as Web.HTML

create ::
  forall action output m slots state uploadedFile.
  MonadAff m =>
  FilePond.Config uploadedFile ->
  Web.HTML.HTMLElement ->
  (FilePond.Event uploadedFile -> action) ->
  Halogen.HalogenM state action slots output m (FilePond.FilePond uploadedFile)
create config elem f = do
  filepond <- Halogen.Query.liftEffect $ FilePond.create config elem
  _ <- subscribe filepond f
  pure filepond

subscribe ::
  forall action output m slots state uploadedFile.
  MonadAff m =>
  FilePond.FilePond uploadedFile ->
  (FilePond.Event uploadedFile -> action) ->
  Halogen.HalogenM state action slots output m Unit
subscribe filepond action = do
  ({ emitter, listener }) <- Halogen.liftEffect Halogen.Subscription.create
  void $ Halogen.subscribe emitter
  Halogen.liftEffect do
    addFileProgressed listener
    addFileStarted listener
    allFilesProcessed listener
    errorReceived listener
    fileActivated listener
    fileAdded listener
    filePrepared listener
    fileProcessed listener
    fileRemoved listener
    filesReordered listener
    filesUpdated listener
    initialized listener
    processFileAborted listener
    processFileProgressed listener
    processFileReverted listener
    processFileStarted listener
    uploadResponse listener
    warningReceived listener
  where
  addFileProgressed ::
    Halogen.Subscription.Listener action ->
    Effect Unit
  addFileProgressed listener =
    FilePond.Callback.onAddFileProgress filepond \x -> do
      Halogen.Subscription.notify listener
        (action $ FilePond.AddFileProgressed x)

  addFileStarted ::
    Halogen.Subscription.Listener action ->
    Effect Unit
  addFileStarted listener =
    FilePond.Callback.onAddFileStart filepond \x -> do
      Halogen.Subscription.notify listener
        (action $ FilePond.AddFileStarted x)

  allFilesProcessed ::
    Halogen.Subscription.Listener action ->
    Effect Unit
  allFilesProcessed listener =
    FilePond.Callback.onProcessAllFilesDone filepond \_ -> do
      Halogen.Subscription.notify listener
        (action FilePond.AllFilesProcessed)

  errorReceived ::
    Halogen.Subscription.Listener action ->
    Effect Unit
  errorReceived listener =
    FilePond.Callback.onError filepond \x -> do
      Halogen.Subscription.notify listener
        (action $ FilePond.ErrorReceived x)

  fileActivated ::
    Halogen.Subscription.Listener action ->
    Effect Unit
  fileActivated listener =
    FilePond.Callback.onActivateFile filepond \x -> do
      Halogen.Subscription.notify listener
        (action $ FilePond.FileActivated x)

  fileAdded ::
    Halogen.Subscription.Listener action ->
    Effect Unit
  fileAdded listener =
    FilePond.Callback.onAddFileDone filepond \x -> do
      Halogen.Subscription.notify listener
        (action $ FilePond.FileAdded x)

  filePrepared ::
    Halogen.Subscription.Listener action ->
    Effect Unit
  filePrepared listener =
    FilePond.Callback.onPrepareFile filepond \x -> do
      Halogen.Subscription.notify listener
        (action $ FilePond.FilePrepared x)

  fileProcessed ::
    Halogen.Subscription.Listener action ->
    Effect Unit
  fileProcessed listener =
    FilePond.Callback.onProcessFileDone filepond \x -> do
      Halogen.Subscription.notify listener
        (action $ FilePond.FileProcessed x)

  fileRemoved ::
    Halogen.Subscription.Listener action ->
    Effect Unit
  fileRemoved listener =
    FilePond.Callback.onRemoveFile filepond \x -> do
      Halogen.Subscription.notify listener
        (action $ FilePond.FileRemoved x)

  filesReordered ::
    Halogen.Subscription.Listener action ->
    Effect Unit
  filesReordered listener =
    FilePond.Callback.onReorderFiles filepond \x -> do
      Halogen.Subscription.notify listener
        (action $ FilePond.FilesReordered x)

  filesUpdated ::
    Halogen.Subscription.Listener action ->
    Effect Unit
  filesUpdated listener =
    FilePond.Callback.onUpdateFiles filepond \x -> do
      Halogen.Subscription.notify listener
        (action $ FilePond.FilesUpdated x)

  initialized ::
    Halogen.Subscription.Listener action ->
    Effect Unit
  initialized listener =
    FilePond.Callback.onInit filepond \_ -> do
      Halogen.Subscription.notify listener
        (action FilePond.Initialized)

  processFileAborted ::
    Halogen.Subscription.Listener action ->
    Effect Unit
  processFileAborted listener =
    FilePond.Callback.onProcessFileAbort filepond \x -> do
      Halogen.Subscription.notify listener
        (action $ FilePond.ProcessFileAborted x)

  processFileProgressed ::
    Halogen.Subscription.Listener action ->
    Effect Unit
  processFileProgressed listener =
    FilePond.Callback.onProcessFileProgress filepond \x -> do
      Halogen.Subscription.notify listener
        (action $ FilePond.ProcessFileProgressed x)

  processFileReverted ::
    Halogen.Subscription.Listener action ->
    Effect Unit
  processFileReverted listener =
    FilePond.Callback.onProcessFileRevert filepond \x -> do
      Halogen.Subscription.notify listener
        (action $ FilePond.ProcessFileReverted x)

  processFileStarted ::
    Halogen.Subscription.Listener action ->
    Effect Unit
  processFileStarted listener =
    FilePond.Callback.onProcessFileStart filepond \x -> do
      Halogen.Subscription.notify listener
        (action $ FilePond.ProcessFileStarted x)

  uploadResponse ::
    Halogen.Subscription.Listener action ->
    Effect Unit
  uploadResponse listener =
    FilePond.Callback.onUploadResponse filepond \x -> do
      Halogen.Subscription.notify listener
        (action $ FilePond.UploadResponse x)

  warningReceived ::
    Halogen.Subscription.Listener action ->
    Effect Unit
  warningReceived listener =
    FilePond.Callback.onWarning filepond \x -> do
      Halogen.Subscription.notify listener
        (action $ FilePond.WarningReceived x)
