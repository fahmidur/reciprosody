(function($) {
    $.fn.goTo = function() {
        $('html, body').animate({
            scrollTop: $(this).offset().top + 'px'
        }, 'fast');
        return this;
    }
})(jQuery);

function uri_to_obj($form) {
	if(typeof $form === 'string') {
		return strUri_to_obj($form);
	}
	var dataArray = $form.serializeArray();
	var obj = {};
	for(var i in dataArray) {
		obj[dataArray[i].name] = dataArray[i].value;
	}
	console.log(obj);
	return obj;
}
function strUri_to_obj(uricomp) {
	var obj = {}, a,
		els = decodeURIComponent(uricomp.replace(/\+/g, ' ')).split('&'),
		p;

	for(i in els) {
		p = els[i].indexOf('=');
		if(p === -1) {
			obj[els[i]] = "";
			continue;
		}
		obj[els[i].substring(0, p)] = els[i].substring(p+1);
	}
	return obj;
}

function fixedEncodeURIComponent (str) {
  return encodeURIComponent(str).replace(/[!'()]/g, escape).replace(/\*/g, "%2A");
}
function obj_to_uri(obj) {
	var st;
	for(e in obj) {
		st += fixedEncodeURIComponent(e) + "=" + fixedEncodeURIComponent(obj[e]) + '&';
	}
	return st;
}
var UIHelper = {
	// onewayBind expects source to be a form element
	// or else it will crash without warning! SFR
	halfwayBind: function($source, $target, defaultStr) {
		var blankregex = /^\s*$/; //arguably more efficient to store this
		var tagregex = /\s*\<.*\>\s*/g; //no tags
		var v;
		if($target.text() !== $source.val()) {
			$target.text($source.val());
		}
		$source.keyup(function() {
			v = $(this).val();
			v = v.replace(tagregex, "");
			if(v.length === 0 || v.match(blankregex)) {
				v = defaultStr;
			}
			$target.text(v);
		});
		$source.blur(function() {
			console.log('blur called');
			$source.val($target.text());
		});
	},
	handleToggleableBoxheaders: function() {
		// console.log('handling toggleable box headers');
		var $toggleables = $('.boxheader.toggleable');
		$toggleables.each(function() {
			$(this).prepend('<span class="toggleable-icon"><i class="icon-chevron-up"></i></span>');
			$(this).attr('data-collapsed', 'false');
		});
		$toggleables.hover(function() {
			$(this).find('.toggleable-icon').addClass('active');
		}, function() {
			$(this).find('.toggleable-icon').removeClass('active');
		});
		$toggleables.click(function() {
			var self = $(this);
			var collapsed = self.data('collapsed');
			var contents = self.parent().find('.boxcontent');
			console.log("collapsed = ", collapsed);
			if(collapsed) {
				contents.slideDown();
				self.data('collapsed', false);
				self.find('.toggleable-icon i').attr('class', 'icon-chevron-up');
				self.find('.toggleable-icon').removeClass('collapsed');

			} else {
				contents.slideUp();
				console.log('setting data-collapsed to true');
				self.data('collapsed', true);
				self.find('.toggleable-icon i').attr('class', 'icon-chevron-down')
				self.find('.toggleable-icon').addClass('collapsed');
			}
		});
	},
	autoCollapseToggleableBoxes: function() {
		toggleSmartDW();
		$(window).on('resize', toggleSmartDW);
		function toggleSmartDW() {
			if($(window).width() < 760) {
				$('.boxheader.toggleable').each(function() {
					if(!$(this).data('collapsed')) {
						$(this).click();
					}
				});
			} else {
				$('.boxheader.toggleable').each(function() {
					if($(this).data('collapsed')) {
						$(this).click();
					}
				});
			}
		}
	},
};
