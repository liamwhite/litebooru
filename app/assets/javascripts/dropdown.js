(function() {
  $.fn.setupDropdowns = function() {
    var self = $(this);
    var sw = self.hasClass('sw');
    // Hide the dropdown menu by default.
    self.find('.dropdown-menu').hide();
    self.find('.dropdown-icon').click(function() {
      toggleState(self, sw);
      return false;
    });
  }

  function toggleState(container, sw) {
    var $menu = $(container).find('.dropdown-menu');
    if ($menu.is(':visible')) {
      // Hide the menu.
      $menu.hide();
    } else {
      // Position the menu.
      var top = ($(container).offset().top+5+$(container).outerHeight())+"px";
      $menu.css({'top':top});
      if (sw) {
        $menu.css({'right':'5px'});
      }
      // Show the menu.
      $menu.show();
    }
  }
}());

$(function() {
  $('.dropdown-container').setupDropdowns();
});
