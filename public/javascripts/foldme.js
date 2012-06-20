

$(function() {
  $('#curation a[data-fold]').on('click', function() {
    console.log($(this));
    parent = $(this).parent();
    fold_url = $(this).attr('data-fold');
    console.log("fold_url", fold_url);
    url = window.location.origin + "/fold.me";
    console.log("url", url);
    data = {fold_url: fold_url};
    $.ajax({
      type: 'post',
      url: url,
      data: data,
      success: function() { console.log("fold recorded!", parent); parent.fadeOut();
                   }
    });
  });
});
