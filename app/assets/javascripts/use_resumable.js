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

  console.log(r.files);
  // Remove all old files from list
  for(var i = 0; i < r.files.length-1; i++) {
    $(".resumable-file-" + r.files[i].uniqueIdentifier).remove();
    r.removeFile(r.files[i]);
  }
  console.log(r.files);

  // Show progress pabr
  $('.resumable-progress, .resumable-list').show();

  $('.resumable-progress .progress-resume-link').show();
  $('.resumable-progress .progress-pause-link').hide();

  // Add the file to the list
  $('.resumable-list').append('<li class="resumable-file-'+file.uniqueIdentifier+'"><span class="resumable-file-name"></span> <span class="resumable-file-progress"></span>');

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
  // Handle progress for both the file and the overall upload
  $('.resumable-file-'+file.uniqueIdentifier+' .resumable-file-progress').html(Math.floor(file.progress()*100) + '%');
  $('.progress-bar').css({width:Math.floor(r.progress()*100) + '%'});
});

function resumeCallback() {
  // Show pause, hide resume
  $('.resumable-progress .progress-resume-link').hide();
  $('.resumable-progress .progress-pause-link').show();
}

function resumableClean() {
  console.log("Running Resumable Clean");
  $.getJSON('/resumable_upload_clean', {
    identifier: r.files[0].uniqueIdentifier, 
    filename: r.files[0].fileName,
    'X-CSRF-Token' : $('meta[name="csrf-token"]').attr('content')
  }, function(data) {
    console.log(data);
  });
}