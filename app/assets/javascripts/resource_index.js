$(function() {
  $(".corpi_item").hover(function() {
    $(this).find('.hButton').animate({opacity:1.0}, 200);
  }, function() {
    $(this).find('.hButton').animate({opacity:0.3}, 200);
  });

  var _over_option_item = false;
  $('.corpi_item .index-item-option-bar a').mouseenter(function() {
  	_over_option_item = true;
  })
  .mouseleave(function() {
  	_over_option_item = false;
  });

  $('.corpi_item').click(function(e) {
  	if(_over_option_item) { return; }
  	e.preventDefault();
  	window.location = $(this).data('show');
  });


  var roleFilter = {member: false, owner: false, approver: false};
  $('#resourceSearchForm').on('submit', submitSearchForm);

  $('#roleToggleGroup .btn').click(function() {
    if($(this).is(".active")) {
      $(this).removeClass('active');
    } else {
      $(this).addClass('active');
    }
    $('#roleToggleGroup .btn').each(function() {
      roleFilter[$(this).data('name')] = $(this).is('.active')? true : false;
    });
    // console.log(roleFilter);
  });
  $('#resourceSearchForm .orderButton').click(function() {
    var $selectedOrder = $('#selectedOrder');
    $selectedOrder.text($(this).text());
    $selectedOrder.attr('data-name', $(this).data('name'));
  });

  updateRoleFilter();
  updateOrder();
  updateQuery();
  function submitSearchForm(e) {
    e.preventDefault();
    var query = $(this).find('input[name=query]').val();
    var order = $('#selectedOrder').data('name');
    var q="?query="+query;
    var roles = [];
    for(var i in roleFilter) {
      if(roleFilter[i]) {
        roles.push(i);
      }
    }
    q +="&roles="+roles.join(",")+"&order="+order;
    window.location = q;
    e.preventDefault();
    return false;
  }

  function updateRoleFilter() {
    var url = document.URL;
    var match = url.match(/\&roles\=([^\&]*)/);
    var rolesString = match[1];

    if(!rolesString) {
      return;
    }
    var roles = rolesString.split(',');
    for(var i in roles) {
      $('#role-'+roles[i]).click();
    }
  }
  function updateOrder() {
    var url = document.URL;
    var match = url.match(/\&order\=([^\&]*)/);
    var orderString = match[1];
    if(!orderString) {
      return;
    }
    $('#order-'+orderString).click();
  }
  function updateQuery() {
    var url = document.URL;
    var match = url.match(/query\=([^\&]*)/);
    var queryString = match[1];
    if(!queryString) {
      return;
    }
    $('#resourceSearchQuery').val(queryString);
  }

});
