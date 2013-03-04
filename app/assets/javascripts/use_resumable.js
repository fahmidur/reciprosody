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
  $('.resumable-list').append('<div title="remove" class="resumable-file-'+file.uniqueIdentifier+' corpi_item_small resumable-remove" data-iden="'+file.uniqueIdentifier+'"><span class="remove-warning"></span><span class="resumable-file-name label label-info"></span> <span class="resumable-file-progress"></div>');

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

$('.resumable-remove').live('click', function() {
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

  if(r.files.length == 0) {
    // Hide progress bar
    $('.resumable-progress, .resumable-list').hide();
  }
}

function resumableBeforeUnload(formID) {
  console.log("Resumable window unloading...");
  //if(_resumable_upload_used && (!_resumable_upload_ready || !_resumable_upload_done)) {
    console.log("Adding upload to Resumable_Incomplete");
    var file = r.files[0];
    var form = $('#'+formID);
    console.log(form);
    var url = document.URL; 
    var m = url.match(/^(.+)\?/);
    if(m) {url = m[1];}

    var filename = file !== undefined ? file.relativePath : "";

    $.getJSON('/resumable_upload_savestate', {
      identifier: file !== undefined ? file.uniqueIdentifier : "", 
      filename: filename,
      url: url,
      formdata: encodeURIComponent(form.serialize()+"&filename="+filename),
      'X-CSRF-Token' : $('meta[name="csrf-token"]').attr('content')
    }, function(data) {
      console.log(data);
    });

  //}
}

function loadFormData() {
  var url = document.URL;
  var m;
  if((m = url.match(/formdata\=(.+)$/))) {
    var formdata = uri_to_obj(decodeURIComponent(m[1]));
    if(formdata['filename'] !== "") {
      $('body').prepend('<div class="modal fade" id="upload-filename">'+
          '<div class="modal-header">' +
            '<a class="close" data-dismiss="modal">×</a>' +
            '<h3>Upload Reminder</h3>' +
          '</div>' +
          '<div class="modal-body">' +
            '<p>You were trying to upload a file named </p>' +
            '<span class="label label-warning">'+(formdata['filename'])+'</span>' +
          '</div>'+
          '<div class="modal-footer">'+
            '<a href="#" data-dismiss="modal" class="btn">Ok</a>'+
          '</div>'+
        '</div>'
      );

      $('#upload-filename').modal('show');  
    }
    console.log(formdata);
    var obj;
    for(name in formdata) {
      obj = $("[name='"+name+"']");
      if(obj !== undefined) {
        obj.val(formdata[name]);
      }
    }
  }
}

loadFormData();
