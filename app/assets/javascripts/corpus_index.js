$(function() {
  $(".corpi_item").hover(function() {
    $(this).children('.hButton').first().animate({opacity:1.0}, 500);
  }, function() {
    $(this).children('.hButton').first().animate({opacity:0.3}, 500);
  });
});
