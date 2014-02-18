$(function() {
  $(".corpi_item").hover(function() {
    $(this).find('.hButton').animate({opacity:1.0}, 200);
  }, function() {
    $(this).find('.hButton').animate({opacity:0.3}, 200);
  });
});
