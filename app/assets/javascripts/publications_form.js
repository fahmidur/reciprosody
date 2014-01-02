var _keywords = {};
var _corpora = {};
var _tools = {};

$(function() {
	console.log("publications form 8");
	dw();
	$(window).resize(dw);

	$('#error_box').hide();
	$('#error_box').click(function() {
		$(this).hide();
	});

	$('#new_publication').on('ajax:beforeSend', function(e, xhr, settings) {
		console.log("ORIGINAL = " + settings.data);

		// var obj = uri_to_obj(settings.data);
		var obj = uri_to_obj($(this));

		var keywords = "";
		var corpora = "";
		var tools = "";


		console.log(obj);
		console.log("changing settings.data");

		delete obj['publication[keyword]'];
		delete obj['publication[corpus]'];
		delete obj['publication[tool]'];


		for(kw in _keywords) {
			keywords += kw + "\n";
		}
		for(corp in _corpora) {
			corpora += corp + "\n";
		}
		for(tool in _tools) {
			tools += tool + "\n";
		}

		console.log(keywords);
		console.log(corpora);
		console.log(tools);

		obj['publication[keywords]'] = keywords;
		obj['publication[corpora]'] = corpora;
		obj['publication[tools]'] = tools;


		console.log("final obj = ", obj);
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

	$('#tool_in').keydown(function(e) {
		if(e.keyCode == 13) {
			e.stopPropagation(); e.preventDefault();
		}
	});
	$('#tool_in').keyup(function(e) {
		if(e.keyCode == 13) {
			e.stopPropagation(); e.preventDefault();
			var v = $(this).val();
			$(this).val("");
			console.log(v);
			var regex = /(.+)\<(\d+)\>/;
			var matches = regex.exec(v);
			if(!matches)
				return;
			var name = matches[1];
			var id = matches[2];

			add_to_tools(name, id);
		}
	});

	$('.tool').live('click', function(e) {
		e.stopPropagation(); e.preventDefault();
		var id = $(this).attr('id').split("--")[1];
		if(_tools[id]) {
			delete _tools[id];
			$('#tool--'+id).remove();
		}
	});

	$('#publication_name').change(function() {
		var val = $('#publication_citation').val();
		console.log(val);
	});

});
function dw() {
	$('#help_sticker').width($('#primaryOwner').width()-10);
	//$('#dropbox').width($('textarea').width()-16);
}
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
function add_to_tools(name, id) {
	if(!_tools[id]) {
		$('#tools_holder').prepend("<div class='corpi_item_small tool' id='tool--"+id+"'>"+name+"</div>");
		_tools[id] = name;
	}
}
