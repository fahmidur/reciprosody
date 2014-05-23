var __app = {
	sharedVariables: {
		ajax: {
			'csrf': $('meta[name="csrf-token"]').attr('content')
		},
		icons: {
			'tag': '<i class="fa fa-fw fa-tag"></i>',
			'corpus': '<i class="fa fa-fw fa-book"></i>',
			'publication': '<i class="fa fa-fw fa-file-text"></i>',
			'tool': '<i class="fa fa-fw fa-wrench"></i>'
		}
	},
	sharedFunctions: {},
	modules: {},
	init: function () {
		console.log("__Main Loaded__");
		__app.sharedFunctions.extractSharedVariables();
		__app.sharedFunctions.printSharedVariables();

		console.log('__Preparing CSRF__');
		$.ajaxSetup({
			headers: {
			'X-CSRF-Token': $('meta[name="csrf-token"]').attr('content')
			}
		});
	},
};

__app.sharedFunctions.extractSharedVariables = function() {
	$('.hf').each(function() {
		__app.sharedVariables[$(this).data('name')] = $(this).val();
	});
};
__app.sharedFunctions.printSharedVariables = function() {
	console.log('__Printing Shared Variables__');
	for(var i in __app.sharedVariables) {
		console.log("-> ", i, ": ", __app.sharedVariables[i]);
	}
}
$(document).ready(__app.init); //explicit for clarity