$(function() {
  var $current_item = $('.corpi_item:first');
  $current_item.addClass('active');

  $(".corpi_item").hover(function() {
    if($('.modal').is(':visible')) { return; }
    $('.index-item-option-bar').removeClass('active');
    $('.corpi_item').removeClass('active');
    $(this).find('.index-item-option-bar').addClass('active');
    $(this).addClass('active');
    $current_item = $(this);
  }, function() {
    if($('.modal').is(':visible')) { return; }
    // $(this).find('.index-item-option-bar').removeClass('active');
  });

  $(document).keydown(function(e) {
    if(e.keyCode == 13) {
      if($current_item) {
        $current_item.click();
      }
    }
  });

  // $(document).keydown(function(e) {
  //   if(!(e.keyCode == 40 || e.keyCode == 38)) { return; }
  //   console.log(e.keyCode);
  //   var t = null;

  //   $('.corpi_item').removeClass('active');
  //   $('.index-item-option-bar').removeClass('active');

  //   if(e.keyCode == 38) { //up
  //     t = $current_item.prev('.corpi_item');
  //     if(t.length == 0) {
  //       $current_item = $('.corpi_item:last');
  //     } else {
  //       $current_item = t;
  //     }
  //   }
  //   else
  //   if(e.keyCode == 40) { //down
  //     t = $current_item.next('.corpi_item');
  //     if(t.length == 0) {
  //       $current_item = $('.corpi_item:first');
  //     } else {
  //       $current_item = t;
  //     }
  //   }
  //   $current_item.addClass('active');
  //   $current_item.find('.index-item-option-bar').addClass('active');
  // });

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
