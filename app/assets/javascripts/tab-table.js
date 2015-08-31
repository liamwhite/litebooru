$(function() {
  $('.notebook .tabs a').click(function(){
    $('.notebook .tabs a').removeClass('selected');
    $(this).addClass('selected');
    $('.notebook .tab').hide();
    $('#'+$(this).data('tab')).show();
    return false;
  });
});
