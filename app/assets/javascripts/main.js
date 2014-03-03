var __app = {
	sharedVariables: {},
	sharedFunctions: {},
	modules: {},
	init: function () {
		console.log("__Main Loaded__");
		__app.sharedFunctions.extractSharedVariables();
		// __app.sharedFunctions.printSharedVariables();
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