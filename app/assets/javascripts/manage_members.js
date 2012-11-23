$(function() {
	
	$(".memberListItem").live('mouseenter', function() {
		$(this).find('.hButton').animate({opacity:1.0}, 500);
	});
	
	$(".memberListItem").live('mouseleave', function() {
		$(this).find('.hButton').animate({opacity:0.3}, 500);
	});
  
  $(window).resize(dw);
  dw();
  
  /*
	$('.delete-confirm').live('click', function(e) {
	  var memId = $(this).attr('data-id');
	  var corId = $(this).attr('data-cid');
	  
		alert('memId = ' + memId + "\ncorId = " + corId);
		$.post("/corpora/"+corId+"/remove_member", {_method: 'delete', mem_id: memId}, function(data) {
			alert(data.ok);
		}); 
	});
	*/
  
	
  $('.delete-confirm').live('click', function(e) {
    var memId = $(this).attr('data-id');
    var corId = $(this).attr('data-cid');
    
    var memName = $(this).attr('data-name');
    var memRole = $('#member_role_id-'+memId).val(); //get live
    
    $('#memName').html(memName);
    $('#memRole').html(memRole);
    
    //$('#yesDelete').attr('href', '/corpora/'+corId+'/remove_member?member_id='+memId);
    $('#yesDelete').val(memId);
    
    $('#newMem').val("");
  });
  
  
  //Zebra-Stripping
  $('.memberListItem:even').css('backgroundColor', '#f5f5f5');
  
  
  $('#addMem_form').on('ajax:success', function(event, data, status, xhr) {
		if(data.ok) {

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
		if(data.ok)  {
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
