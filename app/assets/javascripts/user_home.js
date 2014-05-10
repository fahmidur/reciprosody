__app.modules.userhome = function() {
	var $profileAvatar = $('#profile_avatar');
	var $gravatarEmailWrapper = $('#gravatar-email-wrapper');
	var $gravatarEmail = $('#gravatar-email');
	var $inboxCount = $('#inbox-count');
	var $peopleSearch = $('#people-search');
	var $peopleResult = $('#people-result');
	var $profileAvatar = $('#profile_avatar');
	var $gravatarInfobox = $('#gravatar-infobox');

	var $sideMenuDiv = $('#side_menu');
	var $instSearchWrapper = $('#inst_search_wrapper');
	var $instSearch = $('#inst_search');
	var $instHolder = $('#inst_holder');
	var $instAddButton = $('#add-inst');
	var $fayeConnectionIndicator = $('#faye-connection-indicator');

	var _userID = __app.sharedVariables.userID;
	var _fayeClient = null;
	var _fayeSub = null;

	var _people_result = new Array();
	var _previous_search = "";

	var _snd = new Audio("/assets/sound1.mp3");

	var _userAction = function() {
		var actions = {};
		var $actionsHolder = $('#actionsHolder');

		var fayeMessageHandler = function(data) {
			console.log("FayeMessageHandler::Data::UserAction", data);
			_snd.play();
			$(data.html).prependTo($actionsHolder).hide().slideDown();
			actions[data.id] = $('#user-action-'+data.id);
		};

		$('.user-action').each(function() {
			var id = $(this).data('id');
			actions[id] = $(this);
		});

		return {
			'fayeMessageHandler': fayeMessageHandler
		};

	}();




	$profileAvatar.on('click', click_profileAvatar);
	$gravatarEmail.on('blur', statechange_gravatar_normal);
	$gravatarEmail.on('change', change_gravatarEmail);
	$gravatarEmail.on('keyup', keyup_gravatarEmail);

	$peopleSearch.on('keydown', keydown_peopleSearch);
	$peopleSearch.on('keyup', keyup_peopleSearch);
	$peopleSearch.on('blur', blur_peopleSearch);

	$instSearch.on('keyup', keyup_instSearch);
	$instSearch.on('keydown', keydown_instSearch);

	updatePeopleSearchResult();

	connectFaye();

	$('.presult').live('click', function(e) {
		var id = $(this).attr('data-id');
		window.location = "/users/"+id;
	});
	$('.presult').live('mouseenter', function() {
		$('.presult').removeClass('selected');
		$(this).addClass('selected');
	});
	$('.inst').live('mouseenter', function() {
		$(this).find('.x').show().animate({'opacity': '1'}, 200);
	});
	$('.inst').live('mouseleave', function() {
		$(this).find('.x').animate({'opacity': '0'}, 200, function() {$(this).hide("fast");});
	});
	$('.inst').live('click', function() {
		$(this).animate({'width':'0px'}, 300, function() {
			$(this).remove();
		});
		$.getJSON('/user/remove_inst_rel', {'inst_id': ($(this).attr('id').split("-")[1])}, function(data) {
			console.log(data);
		});
	});

	$instAddButton.click(show_instSearch);
	$instSearch.blur(hide_instSearch);

	function show_instSearch(e) {
		$instSearchWrapper.show();
		$instSearch.show().focus();
		$instAddButton.hide();
		$peopleSearch.hide();
		$sideMenuDiv.hide();
	}

	function hide_instSearch(e) {
		$instSearch.val("");
		$instSearchWrapper.slideUp();
		$instAddButton.show();
		$peopleSearch.show();
		$sideMenuDiv.show();
	}

	function keydown_instSearch(e) {
		if(($(this).val() == "" && e.keyCode == 8)|| e.keyCode == 27) {
			hide_instSearch();	
		}
	}
	function keyup_instSearch(e) {
		if(e.keyCode != 13) {return;}
		$.getJSON('/user/add_inst_rel', {'name':$(this).val()}, function(data) {
			console.log(data);
			if(data.ok) {
				if($('#inst-'+data.inst_id).length === 0) {
					$instHolder.prepend("&nbsp; <span class='badge badge-info inst' style='cursor:pointer' id='inst-"+data.inst_id+"'>"+data.inst_name+"<span class='x' style='display:none'>&nbsp;<i class='icon-remove-sign'></i></span></span>");
					// $instAddButton.html("<i class='icon-plus-sign'></i>");
				}
			}
			hide_instSearch();
		});
	}

	function hide_peopleSearch(e) {
		$peopleResult.hide();
		$sideMenuDiv.slideDown();
	}
	function blur_peopleSearch(e) {
		$peopleSearch.val("");
		setTimeout(hide_peopleSearch, 200);
	}
	function keydown_peopleSearch(e) {
		if(e.keyCode === 40) {
			var next = $('.presult.selected').next(".presult");
			$('.presult').removeClass('selected');
			if(next.length > 0) {
				next.addClass('selected');
			} else {
				$('.presult:first').addClass('selected');
			}
		}
		else
		if(e.keyCode === 38) {
			var prev = $('.presult.selected').prev(".presult");
			$('.presult').removeClass('selected');
			if(prev.length > 0) {
				prev.addClass('selected');
			} else {
				$('.presult:last').addClass('selected');
			}
		}
		else
		if(e.keyCode === 13) {
			$(".presult.selected").click();
		}
		else
		if(e.keyCode === 27) {
			blur_peopleSearch();
		}
	}

	function keyup_peopleSearch(e) {
		var v=$(this).val();
		if(v !== _previous_search) {
			$.getJSON("/users/mixed_search", {q:v}, function(data) {
				_people_result = data;
				updatePeopleSearchResult();
			});
			_previous_search = v;
		}
	}

	function connectFaye() {
		// console.log('Trying to connect...');
		if(typeof Faye === 'undefined') {
			return;
		}
		if(_fayeClient) {
			// console.log('Already connected [done]');
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
			// console.log('Connected!');
			_fayeSub_messages = _fayeClient.subscribe('/messages/'+_userID, fayeMessageHandler_messages);
			_fayeSub_userAction = _fayeClient.subscribe('/useraction/'+_userID, _userAction.fayeMessageHandler)
			$fayeConnectionIndicator.addClass('active');
		} else {
		}
	}

	function fayeMessageHandler_messages(data) {
		console.log("FayeMessageHandler::Data::Message ", data);
		$inboxCount.html( parseInt($inboxCount.text()) + 1 );
		_snd.play();
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
		$.get('/user/update_gravatar_email', {'email': $gravatarEmail.val()}, function(data) {
			// console.log(data);
		});
	}

	function statechange_gravatar_normal() {
		$gravatarEmailWrapper.slideUp();
		$sideMenuDiv.slideDown();
		$peopleSearch.slideDown();
		$peopleResult.slideUp();
		$gravatarInfobox.slideUp();
	}
	function statechange_normal_gravatar() {
		$gravatarEmailWrapper.slideDown(function() {
			$gravatarEmailWrapper.find('input:first').focus();
		});
		$sideMenuDiv.slideUp();
		$peopleSearch.slideUp();
		$peopleResult.slideUp();
		$gravatarInfobox.slideDown();
	}
	function updatePeopleSearchResult() {
		if(_people_result.length == 0) {
			hide_peopleSearch();
		} else {
			var html = "";
			var onclick = "";
			for(var i in _people_result) {
				html += "<div class='corpi_item_small presult' data-id='"+_people_result[i]['id']+"'>"+_people_result[i].name+"</div>";
			}
			$peopleResult.html(html);
			$('.presult:first').addClass("selected");
			$peopleResult.slideDown();
			$sideMenuDiv.slideUp();
		}
	}
};

$(function() {
	__app.modules.userhome();
});


