var _keywords = {};
var _corpora = {};

$(function() {
	console.log("Tool Form 2");

	$('#new_tool').on('ajax:beforeSend', function(e, xhr, settings) {
		console.log("ORIGINAL = " + settings.data);

		var obj = uri_to_obj(settings.data);
		var keywords = "";
		var corpora = "";

		console.log(obj);
		console.log("changing settings.data");

		delete obj['tool[keyword]'];
		delete obj['tool[corpus]'];

		for(kw in _keywords) {
			keywords += kw + "\n";
		}
		
		for(corp in _corpora) {
			corpora += corp + "\n";
		}
		console.log(keywords);
		console.log(corpora);

		obj['tool[keywords]'] = keywords;
		obj['tool[corpora]'] = corpora;
		
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
});

function add_to_keywords(kw) {
	kw = kw.toLowerCase();
	if(!_keywords[kw]) {
		$('#keywords_holder').prepend("<span class='label label-info kw' id='kw--"+kw+"'>"+kw+"</span> &nbsp;");
		_keywords[kw] = kw;
	}
}
function add_to_corpora(cname, cid) {
	if(!_corpora[cid]) {
		$('#corpora_holder').prepend("<div class='corpi_item_small corp' id='corp--"+cid+"'>"+cname+"</div>");
		_corpora[cid] = cname;
	}
}
