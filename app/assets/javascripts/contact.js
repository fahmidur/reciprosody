$(function() {
	$('#sug_wrapper').hide();
	$('#sug_toggle').click(function() {
		$('#sug_wrapper').toggle("fast");
	});
	//----Handle beforSend for client-side validation---
	$('#sug_form').on('ajax:beforeSend', function(xhr, opts) {
		var name = $('#sug_name').val();
		var email = $('#sug_email').val();
		var text = $('#sug_text').val();
		var cap = $('#recaptcha_response_field').val();
		
		if(name == "") {
			//flash($('#sug_name'))
			//xhr.abort();
			/* Note to Self: 
				Nevermind, apparently this doesn't work
				when xhr gets aborted, the form gets treated as a regular form
				and the entire page is refreshed with the json response.
				Hooray UJS.
				To-Do: I must find rails compatible way of stopping the ajax call
				or just forget about forgery protection, and code the ajax
				normally.
				*/
		}
		
		
	});
	
	//----Handle Success---
	$('#sug_form').on('ajax:success', function(event, data, status, xhr) {
		if(data.okay) {
			$('#sug_form').slideUp().delay(3000).slideDown();
			$('#response').prepend(
					"<div class='alert alert-success'>" +
					"<button type='button' class='close' data-dismiss='alert'>×</button>" +
					"<strong>Thanks for writing!</strong></div>");
		} else {
			var errors = "Invalid:";
					
			if(data.errors.name) {
				errors += " Name";
				flash($('#sug_name'));
			}
			if(data.errors.email) {
				errors += " Email"
				flash($('#sug_email'));
			}
			if(data.errors.text) {
				errors += " Text"
				flash($('#sug_text'));
			}
			if(data.errors.cap) {
				errors += " Captcha"
				flash($('#dynamic_recaptcha'));
			}
			
			$('#response').prepend(
					"<div class='alert alert-error'>" +
					"<button type='button' class='close' data-dismiss='alert'>×</button>" +
					"<strong>Sorry! "+errors+"</strong></div>");
		}
		
		Recaptcha.reload();
		console.log(data);
	});
});
	
	function flash(item) {
		item.animate({opacity: 0.2}, 200).delay(100).animate({opacity: 1.0}, 200).delay(100).animate({opacity: 0.2}, 200).delay(100).animate({opacity: 1.0}, 200);
	}
