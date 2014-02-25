$(function() {
  $(".corpi_item").hover(function() {
    $(this).find('.hButton').animate({opacity:1.0}, 200);
  }, function() {
    $(this).find('.hButton').animate({opacity:0.3}, 200);
  });

  var _over_option_item = false;
  $('.corpi_item .index-item-option-bar a').mouseenter(function() {
  	_over_option_item = true;
  	// console.log(_over_option_item);
  })
  .mouseleave(function() {
  	_over_option_item = false;
  	// console.log(_over_option_item);
  });

  $('.corpi_item').click(function(e) {
  	if(_over_option_item) { return; }
  	e.preventDefault();
  	window.location = $(this).data('show');
  });

});
