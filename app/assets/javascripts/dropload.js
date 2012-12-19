/**
 * Send_File_Rails
 * @author Syed Reza
 */
var dropbox = document.getElementById("dropbox");
var droplabel = document.getElementById("droplabel");
var dropbar = $('#dropbar');

const BYTES_PER_CHUNK = 1024 * 1024; // 1 MB

var uploadComplete = false;
var chunksUploaded = 0;
var numChunks = 0;
var fileSize = 0;
var fileName;

$(function() {
	document.addEventListener("dragenter", stopEvent, false);
	document.addEventListener("dragexit", stopEvent, false);
	document.addEventListener("dragOver", stopEvent, false);
	document.addEventListener("drop", drop, false);
	
	dropbox = document.getElementById("dropbox");
	droplabel = document.getElementById("droplabel");
	dropbar = $('#dropbar');
});

function stopEvent(e) {
	e.stopPropagation();
	e.preventDefault();
	
	console.log("Event Stopped");
}

function drop(e) {
	e.stopPropagation();
	e.preventDefault();
	
	var files = e.dataTransfer.files;
	
	var count = files.length;
	
	if(count > 0)
		handleFiles(files);
}

function handleFiles(files) {
	sendFile(files[0]);
}

function sendFile(file) {
	fileName = file.name; fileSize = file.size;
	
	droplabel.innerHTML = fileName + " is " + fileSize + " bytes";

	fileSize = file.size;	
	numChunks = Math.ceil(fileSize / BYTES_PER_CHUNK);
	
	var start = 0;
	var end = BYTES_PER_CHUNK;
	
	var chunkID = 0;
	
	$('#pbar_holder').html("");
	
	$('#pbar_holder').prepend(
		"<div class='progress progress-striped active'>" +
			"<div class='bar' style='width: 0%;' id='dropbar'></div>" +
		"</div>");
	dropbar = $('#dropbar');
	
	chunksUploaded = 0;
	while(start < fileSize) {
		upload(file.slice(start, end), chunkID);
		
		start = end;
		end = start + BYTES_PER_CHUNK;
		chunkID++;
	}
}

function upload(chunk, chunkID) {
	console.log("Uploading chunk "+ chunkID +": " + chunk);
	
	var formData = new FormData();
	
	formData.append('chunkID', chunkID);
	formData.append('fileChunk', chunk);
	
	formData.append('numChunks', numChunks);
	formData.append('fileName', fileName);
	formData.append('fileSize', fileSize);
	
	console.log(progressBar);
		
	var xhr = new XMLHttpRequest();
	
	
	xhr.open("POST", '/upload', true);
	
	xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'));
	
	xhr.onload = function(e) {
		data = JSON.parse(this.response);
		console.log(data);
		console.log("Upload Complete." + chunksUploaded);
		var percent = (++chunksUploaded / numChunks * 100);
		dropbar = dropbar.width(percent + '%');
	};
	
	/*
	$('#pbar_holder').append(
		"<div class='progress progress-striped active' title='Chunk "+chunkID+"'>" +
		"<div class='bar' style='width: 0%;' id='pbar-"+chunkID+"'></div>" +
		"</div>");
	*/
	
	var progressBar = $('#pbar-'+chunkID);
	
	xhr.upload.onprogress = function(e) {
		/*
		if(e.lengthComputable) {
			var percent = (e.loaded/e.total) * 100;
			progressBar.width(percent + '%');
		}
		*/
	};
	
	xhr.send(formData);
}
