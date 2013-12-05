function uri_to_obj(uricomp) {
	var obj = {}, a,
		els = decodeURIComponent(uricomp.replace(/\+/g, ' ')).split('&'),
		p;

	for(i in els) {
		p = els[i].indexOf('=');
		if(p === -1) {
			obj[els[i]] = "";
			continue;
		}
		obj[els[i].substring(0, p)] = els[i].substring(p+1);
	}
	return obj;
}
function fixedEncodeURIComponent (str) {
  return encodeURIComponent(str).replace(/[!'()]/g, escape).replace(/\*/g, "%2A");
}
function obj_to_uri(obj) {
	var st;
	for(e in obj) {
		st += fixedEncodeURIComponent(e) + "=" + fixedEncodeURIComponent(obj[e]) + '&';
	}
	return st;
}
