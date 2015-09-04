$(function() {
  $('#new_comment').on('ajax:complete', function(event, xhr) {
    $('#image-comments').html(xhr.responseText);
    $('time').timeago();
  });
});
