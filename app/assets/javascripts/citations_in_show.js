$('.citation-style').hide();
$('#citation-style-raw').show();

$('#citation-style-select .btn').click(function() {
	$('#citation-style-select .btn').removeClass('active');
	$(this).addClass('active');
	var target = '#citation-style-' + $(this).html().toLowerCase();
	$('.citation-style').hide();
	$(target).show();
});