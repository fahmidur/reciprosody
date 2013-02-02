var _keywords = {};

$(function() {
	console.log("publications form 8");
	dw();
	$(window).resize(dw);
	$('#keyword_in').keydown(function(e) {
		if(e.keyCode == 13) {
			e.stopPropagation(); e.preventDefault();
			var kw = $(this).val().replace(/\s+/g, "-");
			$(this).val("");
			if(!_keywords[kw]) {
				$('#keywords_holder').prepend("<span class='label label-info kw' id='kw--"+kw+"'>"+kw+"</span> &nbsp;");
				_keywords[kw] = kw;
			}
		}
	});
	$('.kw').live('click', function(e) {
		e.stopPropagation(); e.preventDefault();
		var kw = $(this).text();
		if(_keywords[kw]) {
			delete _keywords[kw];
			$('#kw--'+kw).remove();
		}
	});
});
function dw() {
	$('#help_sticker').width($('#primaryOwner').width()-10);
	//$('#dropbox').width($('textarea').width()-16);
}
