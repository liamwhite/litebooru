// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery.turbolinks
//= require jquery_ujs
//= require turbolinks
//= require_tree .

$(function() {
  $('.fancy-tags').tagsInput();

  $('#expand-tags').click(function() {
    path = $(this).data('tag-path');
    $('#image-tags').load(path);
    return false;
  });
});

// fancy thumbscaling
$(function() {
    var $window = $(window);
    var $style = null;

    function setThumbSizes(width) {
        // create an inline style element
        if (!$style) {
            $style = document.createElement("style");
            $style.type = "text/css";
            document.head.appendChild($style);
        }
        if (width) {
          $style.innerHTML = ".thumb{max-width:"+width+"px!important;max-height:"+width+"px!important}";
        } else {
          $style.innerHTML= "";
        }
    }

    function checkWidth() {
        var width = $(document).width();
        if (width < 800) {
            var t_size = Math.round((width-10)/(Math.round(((Math.floor((width-10)/250))+(Math.ceil((width-10)/150)))/2)));
            setThumbSizes(t_size-12);
        } else {
          setThumbSizes(null);
        }
    }
    
    // run on load
    checkWidth();
    
    // bind to resize
    $window.resize(checkWidth);
});
