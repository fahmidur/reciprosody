$(function() {
  $(".corpi_item").hover(function() {
    $(this).children('.hButton').first().animate({opacity:1.0}, 200);
  }, function() {
    $(this).children('.hButton').first().animate({opacity:0.3}, 200);
  });
});
