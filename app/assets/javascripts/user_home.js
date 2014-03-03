__app.modules.userhome = function() {
	var $profileAvatar = $('#profile_avatar');
	var $gravatarEmailWrapper = $('#gravatar-email-wrapper');
	var $gravatarEmail = $('#gravatar-email');
	var $sidemenu = $('#side_menu');
	var $inboxCount = $('#inbox-count');
	var $peopleSearch = $('#people-search');
	var $peopleResult = $('#people-result');

	var _userID = __app.sharedVariables.userID;
	var _fayeClient = null;
	var _fayeSub = null;

	$profileAvatar.click(click_profileAvatar);
	$gravatarEmail.blur(blur_gravatarEmail);

	connectFaye();

	function connectFaye() {
		if(typeof Faye === 'undefined') {
			return;
		}
		try {
			_fayeClient = new Faye.Client(__app.sharedVariables.fayeURL);
		} catch(err) {
			console.log("FAYE NOT FOUND");
			console.log(err);
			_fayeClient = null;
		}
		if(_fayeClient) {
			_fayeSub = _fayeClient.subscribe('/messages/'+_userID, fayeMessageHandler_messages);
		}
	}
	function fayeMessageHandler_messages(data) {
		console.log("FayeMessageHandler::Data: ", data);
		$inboxCount.html( parseInt($inboxCount.text()) + 1 );
		$inboxCount.css("background-color", "orange");
	}
	function blur_gravatarEmail() {
		$gravatarEmailWrapper.slideUp();
	}
	function click_profileAvatar() {
		if($gravatarEmailWrapper.is(":visible")) {
			statechange_normal_gravatar();		
		} else {
			statechange_gravatar_normal();
		}
	}
	function statechange_normal_gravatar() {
		$gravatarEmailWrapper.slideUp();
		$sidemenu.slideDown();
		$peopleSearch.slideDown();
		$peopleResult.slideDown();
	}
	function statechange_gravatar_normal() {
		$gravatarEmailWrapper.slideDown(function() {
			$gravatarEmailWrapper.find('input:first').focus();
		});
		$sidemenu.slideUp();
		$peopleSearch.slideUp();
		$peopleResult.slideUp();
	}

	// These were used at a time
	// when you could delete
	// resources like publication and copora
	// directly from your home

	// $('#delete_corpus').live('ajax:complete', ajaxComplete_deleteCorpus);
	// $('#delete_pub').live('ajax:complete', ajaxComplete_deletePublication);

	// function ajaxComplete_deletePublication() {
	// 	var id = $(this).attr('data-id');
	// 	console.log("completed " + id);
	// 	$('#pubi-' + id).remove();
	// 	$('#delete-confirm-pub-' + id).modal('hide');
	// }
	// function ajaxComplete_deleteCorpus() { 
	// 	var id = $(this).attr('data-id');
	// 	console.log("completed " + id);
	// 	$('#corpi-' + id).remove();
	// 	$('#delete-confirm-' + id).modal('hide');
	// }
};

$(function() {
	__app.modules.userhome();
});


