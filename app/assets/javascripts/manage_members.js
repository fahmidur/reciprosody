$(function() {
	
	$(".memberListItem").live('mouseenter', function() {
		$(this).find('.hButton').animate({opacity:1.0}, 500);
	});

	$(".memberListItem").live('mouseleave', function() {
		$(this).find('.hButton').animate({opacity:0.3}, 500);
	});

	$(window).resize(dw);
	dw();
  
	
	$('.delete-confirm').live('click', function(e) {
		var memId = $(this).attr('data-id');
		var corId = $(this).attr('data-cid');

		var memName = $(this).attr('data-name');
		var memRole = $('#member_role_id-'+memId).val(); //get live

		$('#memName').html(memName);
		$('#memRole').html(memRole);

		$('#yesDelete').val(memId);

		$('#newMem').val("");
	})
;  
	$('.mem_role').live('change', function() {
		var role = $(this).val();
		var memId = $(this).attr('data-id');
		var corId = $(this).attr('data-cid');
		
		//alert("corId = " + corId + " memId = " + memId + " val = " + val);
		$.get("/corpora/"+corId+"/update_member", {mem_id: memId, role: role}, function(data) {
			if(data && data.ok) {
				$('#response').prepend(
					"<div class='alert alert-success'>" +
					"<button type='button' class='close' data-dismiss='alert'>×</button>" +
					"<strong>User role updated</strong></div>");
			}
			else {
				$('#response').prepend(
					"<div class='alert alert-success'>" +
					"<button type='button' class='close' data-dismiss='alert'>×</button>" +
					"<strong>Error updating role</strong></div>");
				if(data.role) {
					$(this).val(data.role);
				}
			}
		});
		
	});

	//Zebra-Stripping
	$('.memberListItem:even').css('backgroundColor', '#f5f5f5');
  
  
	$('#addMem_form').on('ajax:success', function(event, data, status, xhr) {
		if(data && data.ok) {
			$('#newMem').val("");
			$('#memberList').prepend(data.resp);
		}
		else {
			$('#response').prepend(
					"<div class='alert alert-error'>" +
					"<button type='button' class='close' data-dismiss='alert'>×</button>" +
					"<strong>"+data.resp+"</strong></div>");
		}
	});

	
	$('#remMem_form').on('ajax:success', function(event, data, status, xhr) {
		if(data && data.ok)  {
			$('#memberListItem-'+data.id).remove();
		}
		else {
			$('#response').prepend(
					"<div class='alert alert-error'>" +
					"<button type='button' class='close' data-dismiss='alert'>×</button>" +
					"<strong>Could not delete id: "+data.id+"</strong></div>");
		}
		$('#delete-confirm').modal('hide');
	});
	

});

function dw() {
	 $('select').width($('#newMem').width());
}
