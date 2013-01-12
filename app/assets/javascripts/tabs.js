$(function() {
	fixTabs();
	$(window).bind('resize', fixTabs);
});

function fixTabs() {
	console.log('fixing tabs');

	if($(window).width() < 1000) {
		$('ul.nav.nav-tabs:first li').addClass('span12');
	} else {
		$('ul.nav.nav-tabs:first li').removeClass('span12');
	}
}