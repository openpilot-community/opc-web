$(Trestle).on("init",function() {
  var $ownersColumn = $(".owners-column");

  $ownersColumn.on("click",function(ev) {
    ev.preventDefault();
    // return false;
  })
  var $content_header = $(".content-header");
  var is_garage = $("body").hasClass("controller-admin-user-vehicles action-index");
  var $add_new_lookup = $("<a class=\"btn btn-default btn-lg\" href=\"/lookup?garage=true\">" +
                            "<i class=\"fa fa-plus\" style=\"margin-right:5px\"></i>" +
                            "<span>Add Your Vehicle</span>" +
                          "</a>");
  if (is_garage) {
    $content_header.find(".btn").remove();
    $add_new_lookup.appendTo($content_header)
  }
  var $addConfigToGarage = $(".add-vc-link");
  var $addTrimToGarage = $(".add-trim-link");

  // $addTrimToGarage.on("click",function(ev) {

  // });
  // console.warn("$addTrimToGarage",$addTrimToGarage);
  $addConfigToGarage.on("ajax:complete",function(ev, data) {
    console.warn("complete");
    console.warn(data.responseJSON);
    if (data.responseJSON.error && data.responseJSON.error === "You need to sign in or sign up before continuing.") {
      window.location='/sign_in';
    }
  });
  $addConfigToGarage.on("ajax:success",function(ev, data) {
    console.warn("saved garage");
    var response = data;
    var $this = $(this);
    var $icon = $this.find('.fa');
    // var $ownMessage = $this.find(".own-message");
    var $messageText = $this.find(".message-text");
    var $parent = $this.parents(".owners-column");
    var $value = $parent.find(".message > span");
    var new_value;
    var value = parseInt($value.text());
    // console.log($value);
    if ($icon.hasClass('fa-check')) {
      $icon.removeClass('fa-check').addClass('fa-plus');
      if (value-1 < 0) {
        new_value = 0;
      } else {
        new_value = value - 1;
      }
      $value.text(new_value);
      $messageText.text("Own");
      $this.removeClass('user-owns').addClass("user-not-owns");

    } else {
      $icon.removeClass('fa-plus').addClass('fa-check');
      $value.text(value+1);
      $messageText.text("Owned");
      $this.removeClass('user-not-owns').addClass("user-owns");
    }
    // try {
    //   Trestle.activeDialog.hide();
    //   Trestle.activeDialog.setContent(null);
    // } catch (e) {
    //   console.warn(e);
    // }
  });
  $addTrimToGarage.on("ajax:complete",function(ev, data) {
    console.warn("complete");
    console.warn(data.responseJSON);
    if (data.responseJSON.error && data.responseJSON.error === "You need to sign in or sign up before continuing.") {
      window.location='/sign_in';
    }
  });
  $addTrimToGarage.on("ajax:success",function(ev, data) {
    console.warn("saved garage");
    var response = data;
    var $this = $(this);
    var $icon = $this.find('.fa');

    if ($icon.hasClass('fa-check')) {
      $icon.removeClass('fa-check').addClass('fa-plus');
    } else {
      $icon.removeClass('fa-plus').addClass('fa-check');
    }
    // try {
    //   Trestle.activeDialog.hide();
    //   Trestle.activeDialog.setContent(null);
    // } catch (e) {
    //   console.warn(e);
    // }
  });
});