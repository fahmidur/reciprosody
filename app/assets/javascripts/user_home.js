$(function() {
	$('#delete_corpus').live('ajax:complete', function() {
		var id = $(this).attr('data-id');
		console.log("completed " + id);
		$('#corpi-' + id).remove();
		$('#delete-confirm-' + id).modal('hide');
	});

	$('#delete_pub').live('ajax:complete', function() {
		var id = $(this).attr('data-id');
		console.log("completed " + id);
		$('#pubi-' + id).remove();
		$('#delete-confirm-pub-' + id).modal('hide');
	});
});