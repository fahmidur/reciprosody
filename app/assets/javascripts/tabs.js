$(function() {
	fixTabs();
	$(window).bind('resize', fixTabs);
	tabsCrowded();
});

function fixTabs() {
	//if($(window).width() < 1000) {
	if(tabsCrowded()) {
		$('ul.nav.nav-tabs:first li').addClass('span12');
	} else {
		$('ul.nav.nav-tabs:first li').removeClass('span12');
	}
}
function tabsCrowded() {
	var width = $('ul.nav.nav-tabs:first li.corpus_name').html().length * 14;

	$('ul.nav.nav-tabs:first li a').each(function(el) {
		var l = ($(this).html() + "").length;
		console.log($(this).html() + " width = " + width);

		width += l*10 + 25;	
	});
	console.log("width = " + width);

	if(width > $(window).width()-100 )
		return true;
	return false;
}