$(function() {
    $("#memberList").hover(function() {
    $(this).find('.hButton').animate({opacity:1.0}, 500);
  }, function() {
    $(this).find('.hButton').animate({opacity:0.3}, 500);
  });

  $('.delete-confirm').click(function(e) {
    var memId = $(this).attr('data-id');
    var corId = $(this).attr('data-cid');
    
    var memName = $(this).attr('data-name');
    var memRole = $('#member_role_id-'+memId).val(); //get live
    
    $('#memName').html(memName);
    $('#memRole').html(memRole);
    
    $('#yesDelete').attr('href', '/corpus/'+corId+'/remove_member?member_id='+memId);
  });
});
