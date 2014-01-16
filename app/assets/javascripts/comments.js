var numComments = 0;
$(function() {
	console.log("Comments Page");
	numComments = $('.comment').length;
	if($('#input').length !== 0) {
		updateInputSize($('#input'));
	}


	var replyNode = $('#replyNode').remove();
	$('.commentReply_bt').click(function() {
		replyNode.remove();
		$(this).closest('.comment').find('.commentBody').after(replyNode);
		replyNode.find('textarea:first').focus();
	});

	$('#replyCancel_bt').live('click', function() {
		replyNode.remove();
	});

	$('textarea.autosize').live('keyup', function(e) {
		if(e.keyCode == 13 || e.keyCode == 8 || e.keyCode == 46) {
			updateInputSize($(this));
		}
	});

	$('#newComment_form').on('ajax:success', function(event, data, status, xhr) {
		console.log("NewComment.Success");
		console.log(data)
		if(data && data.ok) {
			$('#input').val("");
			addComment(data.resp);		
		}
		else {
			console.log("Invalid Input");
		}
	});

	$('.deletable').live('ajax:success', function(event, data, status, xhr) {
		console.log("delete success");
		if(data != "ERROR") {
			$('#comment-'+data).slideUp(300, function() {
				$(this).remove();
				numComments--;
			});
		}
	});
	var cid = $('#input').attr('data-cid');
	if(cid) {
		window.setInterval(refreshComments, 500);
	}
});
function addComment(resp) {
	$(resp).prependTo('#comments_holder').hide().slideDown();
	numComments++;
}
function updateInputSize(container) {
	var rows = container.val().split("\n").length+1;
	console.log("rows = " + rows);
	container.attr('rows', rows);
}
function refreshComments() {
	var cid = $('#input').attr('data-cid');
	// console.log("polling..."+numComments);
	$.getJSON("/corpora/"+cid+"/refresh_comments", {num_comments: numComments, data_type: 'json' }, 
		function(data) {
			// console.log(data);
			if(data && data.ok) {
				if(data.add) {
					for(var i = 0; i < data.comms.length; i++) {
						addComment(data.comms[i]);
					}
				} else {

				}

			}
		}
	);
}