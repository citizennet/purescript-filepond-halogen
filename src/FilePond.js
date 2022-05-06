// This module drew inspiration from the React Wrapper for FilePond
// https://github.com/pqina/react-filepond/blob/master/lib/index.js

// module FilePond

var FilePond = require("filepond");
var FilePondPluginFileValidateType = require("filepond-plugin-file-validate-type");
var FilePondPluginGetFile = require("filepond-plugin-get-file");
var FilePondPluginImagePreview = require("filepond-plugin-image-preview");
var FilePondPluginMediaPreview = require("filepond-plugin-media-preview");

FilePond.registerPlugin(FilePondPluginFileValidateType);
FilePond.registerPlugin(FilePondPluginGetFile);
FilePond.registerPlugin(FilePondPluginImagePreview);
FilePond.registerPlugin(FilePondPluginMediaPreview);

exports._create = function _create(config, element) {
  var initialConfig = {
    acceptedFileTypes: config.acceptedFileTypes,
    disabled: config.disabled,
    files: config.fileId ? [{ source: config.fileId, options: { type: 'local' } }] : [],
    server: { process: null, load: config.load }
  };
  var filepond = FilePond.create(element, initialConfig);
  filepond.server.process = config.process(filepond);
  return filepond;
};

exports.onUploadResponse = function onUploadResponse(filepond) {
  return function(response) {
    return function() {
      if (typeof filepond.onuploadresponse === "function") {
        filepond.onuploadresponse(response);
      }
    };
  };
};

exports.setDisabled = function setDisabled(filepond) {
  return function(disabled) {
    return function() {
      filepond.disabled = disabled;
    };
  };
};
