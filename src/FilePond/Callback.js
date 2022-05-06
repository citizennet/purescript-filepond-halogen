"use strict";

exports._onInit = function _onInit(FilePond, cb) {
  return FilePond.oninit = cb
}

exports._onWarning = function _onWarning(FilePond, cb) {
  return FilePond.onwarning = cb
}

exports._onError = function _onError(FilePond, cb) {
  return FilePond.onerror = cb
}

exports._onAddFileStart = function _onAddFileStart(FilePond, cb) {
  return FilePond.onaddfilestart = cb
}

exports._onAddFileProgress = function _onAddFileProgress(FilePond, cb) {
  return FilePond.onaddfileprogress = cb
}

exports._onAddFileDone = function _onAddFileDone(FilePond, cb) {
  return FilePond.onaddfile = cb
}

exports._onProcessFileStart = function _onProcessFileStart(FilePond, cb) {
  return FilePond.onprocessfilestart = cb
}

exports._onProcessFileProgress = function _onProcessFileProgress(FilePond, cb) {
  return FilePond.onprocessfileprogress = cb
}

exports._onProcessFileAbort = function _onProcessFileAbort(FilePond, cb) {
  return FilePond.onprocessfileabort = cb
}

exports._onProcessFileRevert = function _onProcessFileRevert(FilePond, cb) {
  return FilePond.onprocessfilerevert = cb
}

exports._onProcessFileDone = function _onProcessFileDone(FilePond, cb) {
  return FilePond.onprocessfile = cb
}

exports._onProcessAllFilesDone = function _onProcessAllFilesDone(FilePond, cb) {
  return FilePond.onprocessfiles = cb
}

exports._onRemoveFile = function _onRemoveFile(FilePond, cb) {
  return FilePond.onremovefile = cb
}

exports._onPrepareFile = function _onPrepareFile(FilePond, cb) {
  return FilePond.onpreparefile = cb
}

exports._onUpdateFiles = function _onUpdateFiles(FilePond, cb) {
  return FilePond.onupdatefiles = cb
}

exports._onActivateFile = function _onActivateFile(FilePond, cb) {
  return FilePond.onactivatefile = cb
}

exports._onReorderFiles = function _onReorderFiles(FilePond, cb) {
  return FilePond.onreorderfiles = cb
}

exports._onUploadResponse = function _onUploadResponse(FilePond, cb) {
  return FilePond.onuploadresponse = cb
}
