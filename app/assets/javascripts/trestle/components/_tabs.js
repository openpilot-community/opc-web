if (Trestle) {
  Trestle._parseURI = function(href) {
    var l = document.createElement("a");
    l.href = href;
    return l;
  };

  Trestle.init(function(e, root) {
    $(root).find("a[data-toggle='tab']").on('shown.bs.tab', function(e) {
      var context = $('.app-main[data-context]');
      var hash = $(this).attr("href");
      var withinModal = $(this).closest('.modal').length > 0;
      var appMainContextPathOnly = Trestle._parseURI(context.attr('data-context')).pathname;
        console.warn("appMainContextPathOnly",appMainContextPathOnly);
      if (hash.substr(0, 1) == "#" && !withinModal) {
        var hashBangTab = "#!" + hash.substr(1)
        var appMainContextWithHash = appMainContextPathOnly + hashBangTab
        context.attr('data-context',appMainContextWithHash);
        $(".btn-fork-link").each(function(i,val) {
          console.log("fork link:",$(this))
          var forkLinkContext = Trestle._parseURI($(this).attr('href')).pathname;
          var hashBangTab = "#!" + hash.substr(1)
          var forkLinkContextWitHash = forkLinkContext + hashBangTab
          $(this).attr('href',forkLinkContextWitHash);
        });
        history.replaceState({ turbolinks: {} }, "", hashBangTab);
      }
    });
  });

  Trestle.focusActiveTab = function() {
    console.log('Focusing active tab...');
    console.log('location.hash',location.hash);

    if (location.hash.substr(0, 2) == "#!") {
      setTimeout(function() {
        var $activeTab = $("a[data-toggle='tab'][href='#" + location.hash.substr(2) + "']")
          $activeTab.tab("show");
      }, 500);
    } else if ($(".tab-pane:has(.has-error)").length) {
      // Focus on first tab with errors
      var pane = $(".tab-pane:has(.has-error)").first();
      $("a[data-toggle='tab'][href='#" + pane.attr("id") + "']").tab("show");
    }
  };

  Trestle.ready(function() {
    Trestle.focusActiveTab();
  });
}