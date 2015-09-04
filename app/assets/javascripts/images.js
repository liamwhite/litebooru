$(function() {
  function bind() {
    $('#edit-tags').click(function() {
      $('#image-actions, #image-tags, #image-source').hide();
      $('#update-metadata').show();
      return false;
    });
    $('#image_metadata_form').on('ajax:complete', function(event, xhr) {
      $('#image-metadata').html(xhr.responseText);
      $('#image-actions').show();
      $('.fancy-tags').tagsInput();
      bind();
    });
  }
  bind();
});
