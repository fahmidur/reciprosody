var popOversEnabled = false;
var current_inputId = 0;
var inputIds = [];


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

		var percent = parseInt($('#dropbar').attr('data-percent'));
		if($('#dropbar').is(':visible') && percent != 100) {
			$('#upload-progress-warning').modal('show');
			return false;
		}
		$('#submit_btn').hide();
		$('#please-wait-warning').modal('show');
	});

	$('#new_corpus').on('ajax:success', function(e, data) {
		console.log("success!");
		console.log(data);

		if(data.ok) {
			window.location.href = "/corpora/"+ data.id;
		} else {
			$('#please-wait-warning').modal('hide');
			$('#submit_btn').show();

			$('#error_box').show();
			$('#errors').html(data.errors.join("<br>"));
			$('html, body').animate({ scrollTop: 0 }, 'fast');
		}

	});	
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

