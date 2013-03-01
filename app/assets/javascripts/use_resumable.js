var r = new Resumable({
          target:'/resumable_upload',
          chunkSize:1*1024*1024,
          simultaneousUploads:4,
          testChunks:true,
          throttleProgressCallbacks:1,
          generateUniqueIdentifier: function(file) {
            var relativePath = file.webkitRelativePath||file.fileName||file.name;
            var size = file.size;
            return($('#hf-userID').val() + "-" + size + '-' + relativePath.replace(/[^0-9a-zA-Z_-]/img, ''));
          },
          headers: {
            'X-CSRF-Token' : $('meta[name="csrf-token"]').attr('content'),
          }
        });

var _resumable_upload_done = false;
var _resumable_upload_ready = false;
var _resumable_upload_used = false;

if(!r.support) {
	$('.resumable-error').show();
} else {
  console.log("Resumable is supported");  

  $('.resumable-drop').show();
  r.assignDrop($('.resumable-drop')[0]);
  r.assignBrowse($('.resumable-browse')[0]);
}
r.on('fileAdded', function(file){
  _resumable_upload_ready = false;
  _resumable_upload_done = false;

  console.log(r.files);
  // Remove all old files from list
  for(var i = 0; i < r.files.length-1; i++) {
    resumableAbort(r.files[i]);
  }
  console.log(r.files);

  // Show progress bar
  $('.resumable-progress, .resumable-list').show();
  // Reset progress bar
  $('.progress-bar').css({width: '0%'});

  $('.resumable-progress .progress-resume-link').show();
  $('.resumable-progress .progress-pause-link').hide();

  // Add the file to the list
  $('.resumable-list').append('<li class="resumable-file-'+file.uniqueIdentifier+'"><span class="resumable-file-name btn btn-mini" title="remove" data-iden="'+file.uniqueIdentifier+'"></span> <span class="resumable-file-progress"></span>');

  $('.resumable-file-'+file.uniqueIdentifier+' .resumable-file-name').html(file.fileName);

  // Actually start the upload
  //r.upload();
});

r.on('pause', function(){
  // Show resume, hide pause
  $('.resumable-progress .progress-resume-link').show();
  $('.resumable-progress .progress-pause-link').hide();
});

r.on('complete', function(){
  _resumable_upload_done = true;
  console.log("Combining...");

  $.getJSON('/resumable_upload_combine', {
    identifier: r.files[0].uniqueIdentifier, 
    filename: r.files[0].fileName,
    numChunks: r.files[0].chunks.length,
    'X-CSRF-Token' : $('meta[name="csrf-token"]').attr('content')
  }, function(data) {
    console.log(data);
  });

  // User must now wait for file to put together by server
  // Handled by corpora_form.js

  // Hide pause/resume when the upload has completed
  $('.resumable-progress .progress-resume-link, .resumable-progress .progress-pause-link').hide();
});

r.on('fileSuccess', function(file,message){
  // Reflect that the file upload has completed
  $('.resumable-file-'+file.uniqueIdentifier+' .resumable-file-progress').html('(completed)');
});

r.on('fileError', function(file, message){
  // Reflect that the file upload has resulted in error
  $('.resumable-file-'+file.uniqueIdentifier+' .resumable-file-progress').html('(file could not be uploaded: '+message+')');
});
r.on('fileProgress', function(file){
  _resumable_upload_used = true;
  // Handle progress for both the file and the overall upload
  $('.resumable-file-'+file.uniqueIdentifier+' .resumable-file-progress').html(Math.floor(file.progress()*100) + '%');
  $('.progress-bar').css({width:Math.floor(r.progress()*100) + '%'});
});

$('.resumable-file-name').live('click', function() {
  var uid = $(this).attr('data-iden');
  console.log(uid);
  var file = r.getFromUniqueIdentifier(uid);
  resumableAbort(file);
});

function resumeCallback() {
  // Show pause, hide resume
  $('.resumable-progress .progress-resume-link').hide();
  $('.resumable-progress .progress-pause-link').show();
}

function resumableClean(f) {
  console.log("Running Resumable Clean: ");
  var file = (f === undefined) ? r.files[0] : f;
  if(file === undefined) {
    console.log("File undefined");
    return;
  }

  $.getJSON('/resumable_upload_clean', {
    identifier: file.uniqueIdentifier, 
    filename: file.fileName,
    'X-CSRF-Token' : $('meta[name="csrf-token"]').attr('content')
  }, function(data) {
    console.log(data);
  });
}

function resumableAbort(f) {
  console.log("Running Resumable Abort: ");
  var file = (f === undefined) ? r.files[0] : f;
  if(file === undefined) {
    console.log("File undefined");
    return;
  }

  $(".resumable-file-" + file.uniqueIdentifier).remove();
  $.getJSON('/resumable_upload_abort', {
    identifier: file.uniqueIdentifier, 
    filename: file.fileName,
    'X-CSRF-Token' : $('meta[name="csrf-token"]').attr('content')
  }, function(data) {
    console.log(data);
  });

  file.cancel();

   // Reset progress bar
  $('.progress-bar').css({width: '0%'});

  _resumable_upload_ready = false;
  _resumable_upload_done = false;
}

function resumableBeforeUnload(formID) {
  console.log("Resumable window unloading...");
  if(_resumable_upload_used && (!_resumable_upload_ready || !_resumable_upload_done)) {
    console.log("Adding upload to Resumable_Incomplete");
    var file = r.files[0];
    var form = $('#'+formID);
    console.log(form);

    $.getJSON('/resumable_upload_savestate', {
      identifier: file.uniqueIdentifier, 
      filename: file.fileName,
      url: document.URL,
      formdata: encodeURIComponent(form.serialize()),
      'X-CSRF-Token' : $('meta[name="csrf-token"]').attr('content')
    }, function(data) {
      console.log(data);
    });

  }
}