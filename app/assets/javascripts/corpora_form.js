var popOversEnabled = false;
var current_inputId = 0;
var inputIds = [];

var _fcheck_interval;
var _original_formdata = "";

$(function() {
	dw();
	
	$('#corpus_name').live('keyup', function(e) {
		var val = $(this).val();
		if(val == "" || val.match(/^\s+$/))
			val = "New Corpus";
		$('#corpus_header').html(val);	
	});
	
	$(window).resize(dw);
	
	$('#error_box').hide();
	
	$('input, textarea').focus(function() {
		current_inputId = inputIds.indexOf($(this).attr('id'));
	});
	
	$('input, textarea').each(function() { 
		if($(this).attr('type') != "hidden") {
			inputIds.push($(this).attr('id'));
		}
	});
	
	$(window).bind('keydown', function(e) {
		if(e.keyCode == 9) {
			setTimeout('$("#'+inputIds[++current_inputId % inputIds.length]+'").focus()', 300);
		}
	});
		
	$('#error_box').click(function() {
		$(this).slideUp("fast");
	});

	
	$('#new_corpus').on('ajax:beforeSend', function(e) {
		console.log("beforeSend!");
		if(r.files[0] !== undefined && r.files[0].progress() > 0 && r.files[0].progress() < 1) {
			$('#upload-progress-warning').modal('show');
			return false;
		}

		if(r.files.length > 0 && _resumable_upload_done && !_resumable_upload_ready) {
			$('#submit_btn').slideUp();
			$('#please-wait-warning').modal('show');
			console.log("setting timeout");
			_fcheck_interval = setInterval(check_if_serverside_ready, 500);
			return false;
		}
	});

	function check_if_serverside_ready() {
		$.getJSON('/resumable_upload_ready', {
			filename: r.files[0].fileName, 
			identifier: r.files[0].uniqueIdentifier,
			size: r.files[0].size,
			'X-CSRF-Token' : $('meta[name="csrf-token"]').attr('content')
		}, function(data) {
			console.log(data);
			if(data && data.ok) {
				_resumable_upload_ready = true;
				clearInterval(_fcheck_interval);
				$('#submit_btn').slideDown();
				$('#please-wait-warning').modal('hide');
				$('#upload-ready').modal('show');
				resumableClean();
			}
		});
	}

	$('#new_corpus').on('ajax:success', function(e, data) {
		console.log("success!");
		console.log(data);

		if(data.ok) {
			console.log("success data.ok");
			window.location.href = "/corpora/"+ data.id;
		} else {
			$('#please-wait-warning').modal('hide');
			$('#submit_btn').show();

			$('#error_box').show();
			$('#errors').html(data.errors.join("<br>"));
			$('html, body').animate({ scrollTop: 0 }, 'fast');
		}

	});

	window.onbeforeunload = function() {
		console.log("Corpus Form Unloading...");
		var progress = (r.files[0] !== undefined && r.files[0].progress() > 0 && r.files[0].progress() < 1);
		var completed_not_sent = (!_resumable_upload_ready && _resumable_upload_used);

		if($("#new_corpus").serialize() !== _original_formdata || progress || completed_not_sent) {
			resumableBeforeUnload('new_corpus');
			return "Your form will be here for you when you get back.";
		}
	}

	_original_formdata = $('#new_corpus').serialize();
	console.log(_original_formdata);

});



function dw() {
	$('#help_sticker').width($('#primaryOwner').width()-10);
	$('#dropbox').width($('input').width()-16);
	
	if(isMobile() && popOversEnabled) {
	
		$('input, textarea').popover('destroy');
		popOversEnabled = false;
		return;
		
	}
	if(!isMobile() && !popOversEnabled) {

		$('input, textarea').popover({trigger:'focus', placement: 'right', html: true});
		popOversEnabled = true;
		return;
	}
}

function isMobile() {
	if($('div.btn.btn-navbar').is(":visible") && $(window).width() < 520) {
		return true;
	}
	return false;
}

function submitCorpusForm() {
	console.log("Submitting Form");
	$('#submit_btn').click();
}

