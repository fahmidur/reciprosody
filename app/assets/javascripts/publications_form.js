$(function() {
	console.log("publications form");
	dw();

	$(window).resize(dw);
});
function dw() {
	$('#help_sticker').width($('#primaryOwner').width()-10);
	$('#dropbox').width($('input').width()-16);
}
