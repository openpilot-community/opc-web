$(Trestle).on("init",function() {
  
  // var inlineAttachmentConfig = {
  //   uploadUrl: '/guide_images.json?guide_id=' + window.guide_id,
  //   uploadFieldName: 'guide_image[image_attributes][attachment]',
  //   allowedTypes: ['image/jpeg', 'image/png', 'image/jpg', 'image/gif'],
  //   extraHeaders: {
  //     'X-CSRF-Token': $.rails.csrfToken()
  //   },
  //   onFileUploadResponse(response) {
  //     console.log("SUCCESSFULLY UPLOADED:",response);
  //     $(".cm-tag").
  //     response.url
  //   }
  // }

  $('textarea.simplemde-inline').each(function (_, element) {
    var simplemde = new SimpleMDE({
        element: element,
        spellChecker: false
      });
      inlineAttachment.editors.codemirror4.attach(simplemde.codemirror, {
        onFileUploadResponse: function(xhr) {
            var result = JSON.parse(xhr.responseText),
            filename = result[this.settings.jsonFieldName];
            console.log(filename);
            console.log(this.filenameTag);
            if (result && filename) {
                var newValue;
                if (typeof this.settings.urlText === 'function') {
                    newValue = this.settings.urlText.call(this, filename, result);
                } else {
                    newValue = this.settings.urlText.replace(this.filenameTag, filename);
                }
                console.log(newValue);
                var text = this.editor.getValue().replace(this.lastValue, newValue);
                this.editor.setValue(text);
                this.settings.onFileUploaded.call(this, filename);
            }
            return false;
        },
        uploadUrl: '/' + window.model_name + '_images.json?' + window.model_name + '_id=' + window.model_id,
        jsonFieldName: 'url',
        allowedTypes: ['image/jpeg', 'image/png', 'image/jpg', 'image/gif'],
        uploadFieldName: window.model_name + '_image[image_attributes][attachment]',
        urlText: "![Image]({filename})",
        extraHeaders: {
          'X-CSRF-Token': $.rails.csrfToken()
        }
    });
    //   inlineAttachment.editors.codemirror4.attach(simplemde.codemirror,
    //     inlineAttachmentConfig);
    // })
  });
});