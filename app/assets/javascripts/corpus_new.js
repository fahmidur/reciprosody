/*
 * This file is loaded by corpora/new.html.erb
 */
$(function() {
	$('#corpus_name').keyup(function(event) {
		var val = $(this).val();
		/*
		val = val.replace(/\s/g, '_');
		val = val.replace(/^[^a-zA-Z]+/, ''); 
		val = val.replace(/\_\_+/, '_'); 
		*/
		
		/*
		val = val.replace(/^\s/, ''); //cannot start with a space
		//cannot have more than one space between words
		val = val.replace(/\s\s+/, ' ');
		*/
		//$(this).val(val);
	});
});
