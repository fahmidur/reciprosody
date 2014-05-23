var _keywords = {};
var _corpora = {};
var _publications = {};

$(function() {
	console.log("Tool Form 6");
	$('#error_box').hide();
	$('#error_box').click(function() {
		$(this).hide();
	});

	UIHelper.halfwayBind($('#tool_name'), $('#tool_header'), "New Tool");

	$('#new_tool').on('ajax:beforeSend', function(e, xhr, settings) {
		console.log("ORIGINAL = " + settings.data);

		// var obj = uri_to_obj(settings.data);
		var obj = uri_to_obj($(this));

		var keywords = "";
		var corpora = "";
		var publications = "";

		console.log(obj);
		console.log("changing settings.data");

		delete obj['tool[keyword]'];
		delete obj['tool[corpus]'];
		delete obj['tool[publication]'];

		for(kw in _keywords) {
			keywords += kw + "\n";
		}
		for(corp in _corpora) {
			corpora += corp + "\n";
		}
		for(pub in _publications) {
			publications += pub + "\n";
		}
		console.log(keywords);
		console.log(corpora);
		console.log(publications);

		obj['tool[keywords]'] = keywords;
		obj['tool[corpora]'] = corpora;
		obj['tool[publications]'] = publications;
		
		settings.data = obj_to_uri(obj);

		console.log(settings.data);
	});

	$('#new_tool').on('ajax:success', function(e, data) {
		console.log("success!");
		console.log(data);
		if(data.ok) {
			console.log("redirecting...");
			window.location.href = "/tools/" + data.res;
		} else {
			console.log("data not okay");

			$('#error_box').show();
			$('#errors').html(data.errors.join("<br/"));
			$('html, body').animate({scrollTop: 0}, 'fast');
			
			console.log(data);
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
			var v = $(this).val();
			if(v.match(/^\s*$/)) {
				return;
			}
			var kw = v.replace(/\s+/g, "-");
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
	
	$('.corp').live('click', function(e) {
		e.stopPropagation(); e.preventDefault();
		var cid = $(this).attr('id').split("--")[1];
		if(_corpora[cid]) {
			delete _corpora[cid];
			$('#corp--'+cid).remove();
		}
	});

	$('#uses_corpus_in').keydown(function(e) {
		if(e.keyCode == 13) {
			e.stopPropagation(); e.preventDefault();
		}
	});
	$('#uses_corpus_in').keyup(function(e) {
		if(e.keyCode == 13) {
			e.stopPropagation(); e.preventDefault();
			var v = $(this).val();
			$(this).val("");
			console.log(v);
			var regex = /(.+)\<(\d+)\>/;
			var matches = regex.exec(v);
			if(!matches)
				return;
			var cname = matches[1];
			var cid = matches[2];

			add_to_corpora(cname, cid);
		}
	});

	$('#pub_in').keydown(function(e) {
		if(e.keyCode == 13) {
			e.stopPropagation(); e.preventDefault();
		}
	});
	$('#pub_in').keyup(function(e) {
		if(e.keyCode == 13) {
			e.stopPropagation(); e.preventDefault();
			var v = $(this).data('value'); //$(this).val();
			$(this).val("");
			console.log(v);
			var regex = /(.+)\<(\d+)\>/;
			var matches = regex.exec(v);
			if(!matches)
				return;
			var name = matches[1];
			var id = matches[2];

			add_to_publications(name, id);
		}
	});

	$('.pub').live('click', function(e) {
		e.stopPropagation(); e.preventDefault();
		var id = $(this).attr('id').split("--")[1];
		if(_publications[id]) {
			delete _publications[id];
			$('#pub--'+id).remove();
		}
	});

});

function add_to_keywords(kw) {
	kw = kw.toLowerCase();
	if(!_keywords[kw]) {
		$('#keywords_holder').prepend("<span class='label label-info kw' id='kw--"+kw+"' data-value='"+kw+"'><i class='fa fa-fw fa-tag'></i>"+kw+"</span> &nbsp;");
		_keywords[kw] = kw;
	}
}
function add_to_corpora(cname, cid) {
	if(!_corpora[cid]) {
		$('#corpora_holder').prepend("<div class='corpi_item_small corp' id='corp--"+cid+"'><i class='fa fa-fw fa-book'></i>"+cname+"</div>");
		_corpora[cid] = cname;
	}
}
function add_to_publications(name, id) {
	if(!_publications[id]) {
		$('#publications_holder').prepend("<div class='corpi_item_small pub' id='pub--"+id+"'><i class='fa fa-fw fa-file'></i>"+name+"</div>");
		_publications[id] = name;
	}
}
