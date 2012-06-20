

$(function() {
  $('#curation a[data-fold]').on('click', function() {
    console.log($(this));
    parent = $(this).parent().parent().parent();
    fold_url = $(this).attr('data-fold');
    console.log("fold_url", fold_url);
    if ($(this).hasClass('add')) {
      url = window.location.origin + "/fold.me";
    } else if ($(this).hasClass('remove')) {
      url = window.location.origin = "/not.fold";
    } else {
      console.log("unrecognised link", $(this));
    }
    console.log("url", url);
    data = {fold_url: fold_url};
    $.ajax({
      type: 'post',
      url: url,
      data: data,
      success: function() {
        console.log("fold recorded!", parent);
        parent.fadeOut();
      }
    });
  });
});
