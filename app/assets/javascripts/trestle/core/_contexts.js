Trestle.refreshContext = function(context) {
  var url = context.data('context');
  console.log("Refreshing context...", url);
  console.warn(url);
  $.get(url, function(data) {
    context.html(data);
    $(Trestle).trigger('init', context);
  });
};

Trestle.refreshMainContext = function() {
  var context = $('.app-main[data-context]');
  console.log("Refreshing main context...", context);
  Trestle.refreshContext(context);
};