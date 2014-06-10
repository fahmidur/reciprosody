var _fclient = null;
$(function() {
	var cid = $('#input').attr('data-cid');
	var uid = parseInt($('#hf-userID').val());
	var numComments = 0;

	var replyNode = $('#replyNode').remove();
	var replyArea = replyNode.find('textarea:first');
	var replyCancel_bt = replyNode.find('#replyCancel_bt');
	var replyPost_bt = replyNode.find('#replyPost_bt');
	var replyParentID = null;

	console.log("Comments Page");
	console.log("faye url = ", _faye_url);

	numComments = $('.comment').length;

	$('.commentReply_bt').live('click', replyShow);

	replyCancel_bt.live('click', replyCancel);
	replyPost_bt.live('click', replyPost);

	replyArea.live('keyup', function(e) {
		if(e.keyCode === 27) {
			replyCancel();
		}
	});


	if($('#input').length !== 0) {
		updateInputSize($('#input'));
	}
	$('textarea.autosize').live('keyup', function(e) {
		if(e.keyCode === 13 || e.keyCode === 8 || e.keyCode === 46) {
			updateInputSize($(this));
		}
	});

	$('#newComment_form').on('ajax:success', function(event, data, status, xhr) {
		console.log("NewComment.Success");
		console.log(data);
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
		console.log(data);
		if(data != "ERROR") {
			deleteComment($(this).parents('.comment:first'));
		}
	});


	function deleteComment($comment) {
		console.log("Delete Comment Called");
		var children = $comment.find('.children:first').children();
		// children.css('border', '1px solid red');
		children.remove();
		$comment.before(children);
		setTimeout( function() {
			$comment.slideUp(300, function() {
				$(this).remove();
				numComments--;
			});
		}, 200);

		// $(this).parents('.comment:first').find('.commentBody')
		// .html("<p></p><div class='commentBodyDeleted'>Comment Deleted</div><p></p>");
	}

	setupFayeClient();

	function setupFayeClient() {
		//establish faye client
		try {
			_fclient = new Faye.Client(_faye_url);
			console.log("Faye connection successful");
		} catch(err) {
			console.log("FAYE NOT FOuND");
			console.log(err);
			_fclient = null;
		}

		if(!_fclient) {
			console.log('Faye not available, aborting Faye');
			return;
		}

		_fclient.subscribe('/corpora/'+cid+'/comments/new', function(data) {
			// console.log(data);
			if(data.user_id === uid) {
				return;
			}
			if(data.parent_id) {
				replyInject(data.comment_html, data.parent_id);
			} else {
				$('.comment:first').before(data.comment_html);
			}
			var comment = $('#comment-'+data.comment_id);
			comment.find('.removable:first').remove();
			// comment.animate({backgroundColor: '#FFA200'}, 200, function() {
			// 	comment.animate({backgroundColor: 'transparent'}, 800);
			// });
		});

		_fclient.subscribe('/corpora/'+cid+'/comments/delete', function(data) {
			console.log(data);
			if(!(data && data.comment_id && data.user_id)) {
				console.log('invalid data');
				return;
			}
			if(data.user_id === uid) {
				return;
			}
			var comment = $('#comment-'+data.comment_id);
			if(!comment) {
				console.log('comment not found');
				return;
			}
			deleteComment(comment);
		});
	}
	
	function replyPost() {
		console.log('Posting reply...');
		console.log("replyParentID = ", replyParentID);
		var msg = replyArea.val();
		if(msg.match(/^\s*$/)) {
			console.log('No point in posting blank message');
			return;
		}
		console.log("msg = ", msg);
		$.getJSON('/corpora/' + cid + '/add_comment', {'msg': msg, 'parentid': replyParentID}, function(data) {
			console.log(data);
			if(data && data.ok) {
				replyInject(data.resp, replyParentID);
				replyCancel();
			}
		});
	}
	function replyInject(html, parentID) {
		var parentComment = $('#comment-'+parentID);
		// parentComment.find('.commentBody:first').after(html);
		parentComment.find('.children:first').prepend(html);
	}
	function replyShow() {
		replyNode.remove();
		replyArea.val('');
		var parentComment = $(this).parents('.comment').first();
		replyParentID = parentComment.data('id');
		console.log(replyParentID);
		parentComment.find('.commentBody:first').after(replyNode);
		replyArea.focus();
		if($(window).width() < 760) {
			parentComment.goTo();
		}
	}
	function replyCancel() {
		replyParentID = null;
		replyNode.remove();
	}
	function addComment(resp) {
		$(resp).prependTo('#comments_holder').hide().slideDown();
		numComments++;
	}
	function updateInputSize(container) {
		var rows = container.val().split("\n").length+1;
		// console.log("rows = " + rows);
		container.attr('rows', rows);
	}

});