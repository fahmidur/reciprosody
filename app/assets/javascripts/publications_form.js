$(function() {
	console.log("publications form 8");

	$('#error_box').hide();
	$('#error_box').click(function() {
		$(this).hide();
	});

	UIHelper.halfwayBind($('#publication_name'), $('#publication_header'), "New Publication");

	$('#new_publication').on('ajax:beforeSend', function(e, xhr, settings) {
		// console.log("ORIGINAL = " + settings.data);

		var obj = uri_to_obj($(this));

		var keywords = "";
		var corpora = "";
		var tools = "";


		// console.log(obj);
		// console.log("changing settings.data");

		delete obj['publication[keyword]'];
		delete obj['publication[corpus]'];
		delete obj['publication[tool]'];

		var _keywords		= __app.modules.form_holder.get_keywords();
		var _corpora		= __app.modules.form_holder.get_corpora();
		var _tools			= __app.modules.form_holder.get_tools();

		for(kw in _keywords) {
			keywords += kw + "\n";
		}
		for(corp in _corpora) {
			corpora += corp + "\n";
		}
		for(tool in _tools) {
			tools += tool + "\n";
		}

		// console.log(keywords);
		// console.log(corpora);
		// console.log(tools);

		obj['publication[keywords]'] = keywords;
		obj['publication[corpora]'] = corpora;
		obj['publication[tools]'] = tools;


		settings.data = obj_to_uri(obj);
		// console.log(settings.data);
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
});

