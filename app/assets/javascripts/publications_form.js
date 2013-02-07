var _keywords = {};

$(function() {
	console.log("publications form 8");
	dw();
	$(window).resize(dw);

	$('#new_publication').on('ajax:beforeSend', function(e, xhr, settings) {
		var obj = uri_to_obj(settings.data);
		var keywords = "";

		console.log(obj);
		console.log("changing settings.data");

		delete obj['publication[keyword]'];

		for(kw in _keywords) {
			keywords += kw + "\n";
		}

		console.log(keywords);
		obj['publication[keywords]'] = keywords;
		

		settings.data = obj_to_uri(obj);
		console.log(settings.data);


	});
	$('#new_publication').on('ajax:success', function(e, data) {
		console.log("success!");
		console.log(data);
		if(data.ok) {
			console.log("redirecting...");
			window.location.href = "/publications/" + data.res;
		} else {
			console.log("data not okay");
		}
	});

	$('#keyword_in').keydown(function(e) {
		if(e.keyCode == 13) {
			e.stopPropagation(); e.preventDefault();
		}
	});
	$('#keyword_in').keyup(function(e) {
		if(e.keyCode == 13) {
			e.stopPropagation(); e.preventDefault();
			var kw = $(this).val().replace(/\s+/g, "-");
			$(this).val("");

			add_to_keywords(kw);
		}
	});
	$('.kw').live('click', function(e) {
		e.stopPropagation(); e.preventDefault();
		var kw = $(this).text();
		if(_keywords[kw]) {
			delete _keywords[kw];
			$('#kw--'+kw).remove();
		}
	});
});
function dw() {
	$('#help_sticker').width($('#primaryOwner').width()-10);
	//$('#dropbox').width($('textarea').width()-16);
}
function uri_to_obj(uricomp) {
	var obj = {}, a,
		els = decodeURIComponent(uricomp).split('&');

	for(i in els) {
		a = els[i].split('=');
		obj[a[0]] = a[1];
	}
	return obj;
}
function obj_to_uri(obj) {
	var st;
	for(e in obj) {
		st += encodeURIComponent(e) + "=" + encodeURIComponent(obj[e]) + '&';
	}
	return st;
}
function add_to_keywords(kw) {
	if(!_keywords[kw]) {
		$('#keywords_holder').prepend("<span class='label label-info kw' id='kw--"+kw+"'>"+kw+"</span> &nbsp;");
		_keywords[kw] = kw;
	}
}
