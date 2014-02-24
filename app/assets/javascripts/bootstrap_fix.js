$(window).bind('resize', fixBootstrap);
$(window).bind('load', fixBootstrap);

function fixBootstrap() {
	if($(window).width() < 772) {
		$('body').css("padding-top", "0px");
	} else {
		$('body').css("padding-top", "60px");
	}
}