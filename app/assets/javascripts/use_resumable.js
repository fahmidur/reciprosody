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
if(!r.support) {
	$('.resumable-error').show();
} else {
  console.log("Resumable is supported");  

  $('.resumable-drop').show();
  r.assignDrop($('.resumable-drop')[0]);
  r.assignBrowse($('.resumable-browse')[0]);
}
r.on('fileAdded', function(file){
  // Show progress pabr
  $('.resumable-progress, .resumable-list').show();
  // Show pause, hide resume
  $('.resumable-progress .progress-resume-link').hide();
  $('.resumable-progress .progress-pause-link').show();

  // Add the file to the list
  $('.resumable-list').append('<li class="resumable-file-'+file.uniqueIdentifier+'">Uploading <span class="resumable-file-name"></span> <span class="resumable-file-progress"></span>');

  $('.resumable-file-'+file.uniqueIdentifier+' .resumable-file-name').html(file.fileName);

  // Actually start the upload
  r.upload();
});

r.on('pause', function(){
  // Show resume, hide pause
  $('.resumable-progress .progress-resume-link').show();
  $('.resumable-progress .progress-pause-link').hide();
});

r.on('complete', function(){
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