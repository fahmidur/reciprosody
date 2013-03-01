function uri_to_obj(uricomp) {
	var obj = {}, a,
		els = decodeURIComponent(uricomp.replace(/\+/g, ' ')).split('&');

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