$(function() {

  $('textarea.wysiwyg').each(function() {
    var textarea = this;
    var summernote = $('<div class="summernote"></div>');
    $(summernote).insertAfter(this);
    $(summernote).summernote({
      height: 500,
      onImageUpload: function(files, editor, welEditable) {
        sendFile(files[0], editor, welEditable);
      }
    });
    $(summernote).code($(textarea).val());
    $('.note-fontname, .note-help', summernote.next()).hide();
    $('button[data-event=codeview]', summernote.next()).click();
    $(textarea).hide();
    $(textarea.form).submit(function() {
      $(textarea).val($(summernote).code());
    });
  });

  $('input[type=text].slug').each(function() {
    var slug = $(this);
    var start_length = slug.val().length;
    var pos = $.inArray(this, $('input', this.form)) - 1;
    var title = $($('input', this.form).get(pos));
    slug.focus(function() {
      slug.data('focus', true);
    });
    title.keyup(function() {
      if (start_length == 0 && slug.data('focus') != true)
        slug.val(title.val().toLowerCase().replace(/ /g, '-').replace(/[^a-z0-9\-]/g, ''));
    });
  });

  $(document).on('click', 'a[data-confirm]', function(e) {
    var message = $(this).data('confirm');
    if (!confirm(message)) {
      e.preventDefault();
      e.stopped = true;
    }
  });

  $(document).on('click', 'a.popup', function(e) {
    window.open(this.href, null, 'scrollbars=yes,width=600,height=600,left=150,top=150').focus();
    return false;
  });

  function sendFile(file, editor, welEditable) {
    var formData = new FormData();
    formData.append('upload[file]', file);

    $.ajax({
      data: formData,
      type: "POST",
      url: "/admin/new/Upload",
      cache: false,
      dataType: 'json',
      processData: false, // Don't process the files
      contentType: false, // Set content type to false as jQuery will tell the server its a query string request      
      success: function(data) {
        editor.insertImage(welEditable, data.url);
      }
    });
  }

});