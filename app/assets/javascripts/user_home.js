__app.modules.userhome = function() {
	var $profileAvatar = $('#profile_avatar');
	var $gravatarEmailWrapper = $('#gravatar-email-wrapper');
	var $gravatarEmail = $('#gravatar-email');
	var $sidemenu = $('#side_menu');
	var $inboxCount = $('#inbox-count');
	var $peopleSearch = $('#people-search');
	var $peopleResult = $('#people-result');
	var $profileAvatar = $('#profile_avatar');

	var _userID = __app.sharedVariables.userID;
	var _fayeClient = null;
	var _fayeSub = null;

	$profileAvatar.on('click', click_profileAvatar);
	$gravatarEmail.on('blur', statechange_gravatar_normal);
	$gravatarEmail.on('change', change_gravatarEmail);
	$gravatarEmail.on('keyup', keyup_gravatarEmail);

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

	function click_profileAvatar(e) {
		if($gravatarEmailWrapper.is(":visible")) {
			statechange_gravatar_normal();
		} else {
			statechange_normal_gravatar();
		}
	}

	function keyup_gravatarEmail(e) {
		if(e.keyCode == 13) { //enter
			$gravatarEmail.blur();
			return;
		}
		$profileAvatar.attr('src', "http://gravatar.com/avatar/"+md5($gravatarEmail.val())+"?s=200");
	}
	function change_gravatarEmail(e) {
		console.log('--gravatarEmailChanged--');
		$.get('/user/update_gravatar_email', {'email': $gravatarEmail.val()}, function(data) {
			// console.log(data);
		});
	}

	function statechange_gravatar_normal() {
		$gravatarEmailWrapper.slideUp();
		$sidemenu.slideDown();
		$peopleSearch.slideDown();
		$peopleResult.slideDown();
	}
	function statechange_normal_gravatar() {
		$gravatarEmailWrapper.slideDown(function() {
			$gravatarEmailWrapper.find('input:first').focus();
		});
		$sidemenu.slideUp();
		$peopleSearch.slideUp();
		$peopleResult.slideUp();
	}
};

$(function() {
	__app.modules.userhome();
});


