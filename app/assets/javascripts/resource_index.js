$(function() {

  $(".corpi_item").hover(function() {
    if($('.modal').is(':visible')) { return; }
    // $(this).find('.hButton').animate({opacity:1.0}, 200);
    $(this).find('.index-item-option-bar').animate({opacity:1.0}, 200);

    // $(this).find('.index-item-option-bar').slideDown("fast");
    // $(this).find('.index-item-info-bar').slideUp("fast");
  }, function() {
    if($('.modal').is(':visible')) { return; }
    // $(this).find('.hButton').animate({opacity:0.3}, 200);
    $(this).find('.index-item-option-bar').animate({opacity:0.1}, 200);

    // $(this).find('.index-item-option-bar').slideUp("fast");
    // $(this).find('.index-item-info-bar').slideDown("fast");
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
  $('#roleToggleGroup .btn').click(function(e) {
    if($(this).is(".active")) {
      $(this).removeClass('active');
    } else {
      $(this).addClass('active');
    }
    $('#roleToggleGroup .btn').each(function() {
      roleFilter[$(this).data('name')] = $(this).is('.active')? true : false;
    });
    submitSearchForm(e);
  });
  $('#resourceSearchForm .orderButton').click(function(e) {
    updateSelectedOrder($(this));
    submitSearchForm(e);
  });

  updateRoleFilter();
  updateOrder();
  updateQuery();

  function submitSearchForm(e) {
    e.preventDefault();
    var query = $('#resourceSearchQuery').val();
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
    if(!match) { return; }
    var rolesString = match[1];

    if(!rolesString) {
      return;
    }
    var roles = rolesString.split(',');
    for(var i in roles) {
      $('#role-'+roles[i]).addClass('active');
      roleFilter[roles[i]] = true;
    }
  }
  function updateSelectedOrder($order) {
    var $selectedOrder = $('#selectedOrder');
    $selectedOrder.text($order.text());
    $selectedOrder.attr('data-name', $order.data('name'));
  }
  function updateOrder() {
    var url = document.URL;
    var match = url.match(/\&order\=([^\&]*)/);
    if(!match) { return; }
    var orderString = match[1];
    if(!orderString) {
      return;
    }
    updateSelectedOrder($('#order-'+orderString));
  }
  function updateQuery() {
    var url = document.URL;
    var match = url.match(/query\=([^\&]*)/);
    if(!match) { return; }
    var queryString = match[1];
    if(!queryString) {
      return;
    }
    $('#resourceSearchQuery').val(decodeURIComponent(queryString));
  }

});
