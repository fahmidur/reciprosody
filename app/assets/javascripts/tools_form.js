$(function() {
	console.log("Tool Form 6");
	$('#error_box').click(function() {
		$(this).hide();
	});

	// halfway binder
	UIHelper.halfwayBind($('#tool_name'), $('#tool_header'), "New Tool");

	//handle beforeSend
	$('#new_tool').on('ajax:beforeSend', function(e, xhr, settings) {
		// console.log("ORIGINAL = " + settings.data);

		var obj = uri_to_obj($(this));

		var keywords = "";
		var corpora = "";
		var publications = "";

		// console.log(obj);
		// console.log("changing settings.data");

		delete obj['tool[keyword]'];
		delete obj['tool[corpus]'];
		delete obj['tool[publication]'];

		var _keywords		= __app.modules.form_holder.get_keywords();
		var _corpora		= __app.modules.form_holder.get_corpora();
		var _publications	= __app.modules.form_holder.get_publications();

		for(kw in _keywords) {
			keywords += kw + "\n";
		}
		for(corp in _corpora) {
			corpora += corp + "\n";
		}
		for(pub in _publications) {
			publications += pub + "\n";
		}
		// console.log(keywords);
		// console.log(corpora);
		// console.log(publications);

		obj['tool[keywords]'] = keywords;
		obj['tool[corpora]'] = corpora;
		obj['tool[publications]'] = publications;
		
		settings.data = obj_to_uri(obj);
		// console.log(settings.data);
	});

	// handle success
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

});
