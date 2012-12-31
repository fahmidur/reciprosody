$(function() {
	$(window).resize(dw);
	dw();
});
function dw() {
	fixEmailSize();
	fixBoxHeight();
}
function fixBoxHeight() {
	if($(window).width() - $('.r1-box:first').width() < 100) {
		unsetMaxHeight($('.r1-box'));
		unsetMaxHeight($('.r2-box'));
	} else {
		setMaxHeight($('.r1-box'));
		setMaxHeight($('.r2-box'));
	}	
}
function fixEmailSize() {
	setMaxWidth($('.mem-email'));
}
function setMaxWidth(set) {
	var max = 0;
	if($(window).width() - set.first().width() < 100) {
		return;
	}
	set.each(function(el) {
		if($(this).width() > max) {
			max = $(this).width();
		}
	});
	set.each(function(el) {
		$(this).width(max);
	});
}
function setMaxHeight(set) {
	var max = 0;
	set.each(function(el) {
		if($(this).height() > max) {
			max = $(this).height();
		}
	});
	set.each(function(el) {
		console.log($(this));
		$(this).height(max);
	});
}
function unsetMaxHeight(set) {
	set.each(function(el) {
		$(this).height("auto");
	});
}