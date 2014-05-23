__app.modules.form_holder = function() {
	var _keywords = {};
	var _corpora = {};
	var _publications = {};
	var _tools = {};

	$('.pub').live('click', function(e) {
		e.stopPropagation(); e.preventDefault();
		var id = $(this).attr('id').split("--")[1];
		if(_publications[id]) {
			delete _publications[id];
			$('#pub--'+id).remove();
		}
	});

	$('.kw').live('click', function(e) {
		e.stopPropagation(); e.preventDefault();
		var kw = $(this).data('value');
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

	$('#pub_in').keydown(function(e) {
		if(e.keyCode == 13) {
			e.stopPropagation(); e.preventDefault();
		}
	});
	$('#pub_in').keyup(function(e) {
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

			add_to_publications(name, id);
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

	function get_keywords() {
		return _keywords;
	}

	function get_corpora() {
		return _corpora;
	}

	function get_publications() {
		return _publications;
	}

	function add_to_keywords(kw) {
		kw = kw.toLowerCase();
		if(!_keywords[kw]) {
			$('#keywords_holder').prepend("<span class='label label-info kw' id='kw--"+kw+"' data-value='"+kw+"'><i class='fa fa-fw fa-tag'></i> "+kw+"</span> &nbsp;");
			_keywords[kw] = kw;
		}
	}

	function add_to_corpora(cname, cid) {
		if(!_corpora[cid]) {
			$('#corpora_holder').prepend("<div class='corpi_item_small corp' id='corp--"+cid+"'><i class='fa fa-fw fa-book'></i> "+cname+"</div>");
			_corpora[cid] = cname;
		}
	}

	function add_to_publications(name, id) {
		if(!_publications[id]) {
			$('#publications_holder').prepend("<div class='corpi_item_small pub' id='pub--"+id+"'><i class='fa fa-fw fa-file-text'></i> "+name+"</div>");
			_publications[id] = name;
		}
	}

	return {
		'get_keywords': get_keywords,
		'get_corpora': get_corpora,
		'get_publications': get_publications,
		'add_to_keywords': add_to_keywords,
		'add_to_corpora': add_to_corpora,
		'add_to_publications':  add_to_publications
	};
}();