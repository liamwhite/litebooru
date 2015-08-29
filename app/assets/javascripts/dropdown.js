(function() {
  $.fn.setupDropdowns = function() {
    var self = $(this);
    // Hide the dropdown menu by default.
    self.find('.dropdown-menu').hide();
    self.find('.dropdown-icon').click(function() {
      toggleState(self);
      return false;
    });
  }

  function toggleState(container) {
    var $menu = $(container).find('.dropdown-menu');
    if ($menu.is(':visible')) {
      // Hide the menu.
      $menu.hide();
    } else {
      // Determine the necessary width for the dropdown.
      var width = Math.max.apply(Math, $menu.find('a').map(function(){ return $(this).width(); }).get());
      // Position the menu.
      var top = ($(container).offset().top+5+$(container).outerHeight())+"px";
      $menu.css({'top':top, 'min-width':width});
      // Show the menu.
      $menu.show();
    }
  }
}());

$(function() {
  $('.dropdown-container').setupDropdowns();
});
