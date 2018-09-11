//= require_self
//= require underscore/underscore
//= require ./garage
//= require ./capabilities_toggler
//= require ./capabilities_filter
//= require ./follow-button
//= require ./inline-attachment
//= require ./input.inline-attachment
//= require ./codemirror-4.inline-attachment
//= require ./highlight.pack
//= require ./editor
//= require ./voter
//= require ./comments
var originalAddClassMethod = jQuery.fn.addClass;
var originalRemoveClassMethod = jQuery.fn.removeClass;
function pollRefreshingStatus(){
  $.getJSON(window.location.href + "/refreshing_status.json", function(data) {
      if (data.refreshing) {
        setTimeout(pollRefreshingStatus,15000);
      } else {
        Trestle.refreshMainContext();
      }
  });
}

jQuery.fn.addClass = function(){
  var result = originalAddClassMethod.apply( this, arguments );
  jQuery(this).trigger('classAdded');
  return result;
}

jQuery.fn.removeClass = function(){
  var result = originalRemoveClassMethod.apply( this, arguments );
  jQuery(this).trigger('classRemoved');
  return result;
}
// This file may be used for providing additional customizations to the Trestle
// admin. It will be automatically included within all admin pages.
//
// For organizational purposes, you may wish to define your customizations
// within individual partials and `require` them here.
//
//  e.g. //= require "trestle/custom/my_custom_js"
var setupVehicleConfigYear = function() {
  var $badgeVoteCount = $(".badge-vote-count");
  $badgeVoteCount.on("click",function(ev) {
    ev.preventDefault();
    return false;
  })
  var $quickAdd = $("#tab-capabilities .type-quick-add");
  var $quickDelete = $("#tab-capabilities .type-quick-delete");
  var $voter = $("a.vote-up,a.vote-down");
  $voter.on("ajax:success",function(ev, data) {
    var votes = data.votes;
    var $this = $(this);
    var $parent = $this.parents('.vote-action');
    var curr_vote;

    if ($parent.hasClass('upvoted')) {
      curr_vote = "up";
    }

    if ($parent.hasClass('downvoted')) {
      curr_vote = "down";
    }

    if ($this.find('.fa-arrow-up').length) {
      $parent.removeClass('voted downvoted upvoted')
      if (curr_vote !== 'up') {
        $parent.addClass('voted upvoted');
      }
    }
    if ($this.find('.fa-arrow-down').length) {
      $parent.removeClass('voted downvoted upvoted')
      if (curr_vote !== 'down') {
        $parent.addClass('voted downvoted');
      }
    }
    $parent.find("span.badge").text(data.votes);
  });
  // $quickAdd.off("click");
  $quickAdd.on("click",function(ev) {
    var $this = $(this);
    ev.preventDefault();
    var vehicle_capability_id = $this.attr('data-vehicle-capability-id');
    var vehicle_config_type_id = $this.attr('data-vehicle-config-type-id');
    var url = location.href.replace(location.hash,"")

    console.warn("Sending to URL:",url);
    console.warn("vehicle_config_type_id:",vehicle_config_type_id);
    console.warn("vehicle_capability_id:",vehicle_capability_id);
    $.ajax({
      url: url + '/quick_add',
      type: 'POST',
      dataType: "text/html",
      data: {
        vehicle_capability_id: vehicle_capability_id,
        vehicle_config_type_id: vehicle_config_type_id
      }
    })
  })
  var is_visitor = $(".is-visitor").length;
  var should_disable_fields = false;
  var should_show_trim_styles = false;
  // if (!$("body.controller-admin-vehicle-lookups").length) {
  //   should_disable_fields = true;
  // }
  // if ($("body.controller-admin-vehicle-lookups").length && !window.location.href.includes("vehicle_lookups")) {
  //   should_disable_fields = true;
  //   should_show_trim_styles = true;
  // }
  // var is_guides = $("body.controller-admin-guides.action-new,");
  // if (is_guides && is_visitor) {
  //   should_disable_fields = false;
  // }
  // if ($('.app-wrapper.is-visitor').length) {
  //   if (should_disable_fields) {
  //     $(".trestle-table .actions > *").remove();
  //     $(".main-content .form-control,.modal-body .form-control").attr('disabled',true);
  //   }

  //   if (should_show_trim_styles) {
  //     var $trimStylesTab = $("a[data-toggle='tab'][href='#tab-trim_styles']");
      
  //     if ($trimStylesTab.length) {
  //       $trimStylesTab.tab("show");
  //     }
  //   }
  // }
  
  // console.warn('setupVehicleConfigYear');
  var $year_start = $("#vehicle_config_year");
  // $year_start.select2();
  var $year_start_column = $(".col-class-year-start");
  var $year_start_select2_container = $year_start_column.find('.select2-container');
  var $year_end = $("#vehicle_config_year_end");
  // $year_end.select2();
  var $year_end_column = $(".col-class-year-end");
  var $year_end_select2_container = $year_end_column.find('.select2-container');
  var $year_range = $('.col-class-year-range');
  var $add_year_end_link = $("<a class=\"year-end-link\" href=\"javascript:void(0);\">+ Add End Year</a>");
  
  var onYearOpen = function(ev) {
    console.warn("onYearOpen");
    $year_range.addClass('open');
  }
  // var onYearFocus = function(ev) {
  //   console.log("year focus");
  //   $year_range.addClass('focus');
  // }
  // var onYearBlur = function(ev) {
  //   console.log("year onblur");
  //   $year_range.removeClass('focus');
  // }
  var onYearClose = function(ev) {
    // console.warn("onYearClose");
    $year_range.removeClass('open');
  }
  // $year_start.on("focus", onYearFocus);
  // $year_start.on("blur",onYearBlur);
  // $year_end.on("focus", onYearFocus);
  // $year_end.on("blur",onYearBlur);
  var refresh_classes = function() {
    if ($year_start_select2_container.hasClass('select2-container--focus') || $year_end_select2_container.hasClass('select2-container--focus')){
      $year_range.addClass('focus');
    } else {
      $year_range.removeClass('focus');
    }
  }
  $year_start_select2_container.on('classAdded', function(){ 
    refresh_classes();
  });
  $year_end_select2_container.on('classAdded', function(){ 
    refresh_classes();
  });
  $year_start_select2_container.on('classRemoved', function(){ 
    refresh_classes();
  });
  $year_end_select2_container.on('classRemoved', function(){ 
    refresh_classes();
  });

  $($year_start,$year_end).on("select2:open",onYearOpen);
  $($year_start,$year_end).on("select2:close",onYearClose);

  var refresh_year_view = function() {
    if (parseInt($year_end.val()) < parseInt($year_start.val())) {
      set_year_end_value($year_start.val());
    }
    if (parseInt($year_end.val()) === parseInt($year_start.val())) {
      $year_range.removeClass('has-year-end');
    }
    if ($year_range && !$year_end_column.find('.year-end-link').length) {
      $add_year_end_link.appendTo($year_end_column);
    }
    if (parseInt($year_end.val()) > parseInt($year_start.val())) {
      $year_range.addClass("has-year-end");
    }
  }
  var set_year_end_value = function(val) {
    $year_end.val(parseInt(val)).trigger('change');
  }
  $add_year_end_link.on("click",function() {
    set_year_end_value(parseInt($year_start.val())+1);
  });

  $year_end.on("change",function() {
    var $this = $(this)
    var new_value = $this.val();
    refresh_year_view();
  });

  refresh_year_view();

  var $config_video = $("#vehicle_config_video_video_id");
  console.log("$config_video:",$config_video);
  $config_video.on("change",function() {
    var $this = $(this)
    getVideo($this.val());
  });
  var getVideo = function(video) {
    $.getJSON("/videos/" + video + ".json").then(function(record) {
      console.warn("record:",record);
      $(".video-output").html(record.html);
    });
  }
}
function isElementVisible(el) {
  var rect     = el.getBoundingClientRect(),
      vWidth   = window.innerWidth || doc.documentElement.clientWidth,
      vHeight  = window.innerHeight || doc.documentElement.clientHeight,
      efp      = function (x, y) { return document.elementFromPoint(x, y) };     

  // Return false if it's not in the viewport
  if (rect.right < 0 || rect.bottom < 0 
          || rect.left > vWidth || rect.top > vHeight)
      return false;

  // Return true if any of its four corners are visible
  return (
        el.contains(efp(rect.left,  rect.top))
    ||  el.contains(efp(rect.right, rect.top))
    ||  el.contains(efp(rect.right, rect.bottom))
    ||  el.contains(efp(rect.left,  rect.bottom))
  );
}
$(Trestle).on("init",function() {
  // $(".thread").show();
  // var simplemde = new SimpleMDE({ element: document.getElementById("comment_body") });
  var $sidebar = $(".app-sidebar");
  var $contentContainer = $(".main-content-container");
  var resizeDocument = function() {
    var is_lookup_form = $("body.controller-admin-vehicle-lookups.action-new").length;
    var sidebarWidth = $sidebar.outerWidth();
    // console.warn("sidebar is : ",isElementVisible($sidebar[0]));
    if (!is_lookup_form) {
      if ($("body.mobile-nav-expanded").length) {
        $contentContainer.css({
          width: $(document).width()-sidebarWidth
        });
      } else {
        if ($(document).width() >= 768) {
          $contentContainer.css({
            width: $(document).width()-sidebarWidth
          });
        } else {
          $contentContainer.css({
            width: $(document).width()
          });
        }
      }
    }
  }
  $(window).on("resize",function() {
    resizeDocument();
  });
  resizeDocument();
  setupVehicleConfigYear();
  
  if ($("body.controller-admin-vehicle-lookups.action-new .alert.alert-dismissable.alert-success").length) {
    // window.location = '/vehicle_lookups/new';
    $("body").removeClass("action-new");
  }
  
  
  var trims;
  var models;
  var $elems = {}
  var $el = Trestle.Dialog.getElement();

  $('[data-toggle="tooltip"]').tooltip();
  
  $.fn.modal.Constructor.prototype.enforceFocus = function () {
    $(document)
      .off('focusin.bs.modal') // guard against infinite focus loop
      .on('focusin.bs.modal', $.proxy(function (e) {
          if (this.$element[0] !== e.target && !this.$element.has(e.target).length && !$(e.target).closest('.select2-dropdown').length) {
              this.$element.trigger('focus')
          }
      }, this))
  }
  var $buttonToMove = $("body.controller-admin-vehicle-configs.action-index .btn.btn-default.btn-lg");
  var $navItem = $("body.controller-admin-vehicle-configs.action-index .app-nav .vehicles .nav-header");

  if (!$(".app-wrapper").hasClass("is-visitor")) {
    $buttonToMove.insertAfter($navItem)
    $buttonToMove.find("span.sr-only").removeClass("sr-only").text("Add New Vehicle");
  }
  $elems['repositories'] = $("#vehicle_config_repository_repository_id");
  $elems['repository_branches'] = $("#vehicle_config_repository_repository_branch_id");
  $elems['vehicle_configs'] = $("#user_vehicle_vehicle_config_id");
  $elems['trims'] = $('select#vehicle_config_vehicle_trim_id,select#user_vehicle_vehicle_trim_id');
  $elems['trim_styles'] = $('select#vehicle_config_vehicle_trim_style_id,select#user_vehicle_vehicle_trim_style_id');
  $elems['years'] = $('select#vehicle_config_year,select#vehicle_lookup_year');
  $elems['makes'] = $('select#vehicle_config_vehicle_make_id,select#vehicle_lookup_vehicle_make_id');
  $elems['models'] = $('select#vehicle_config_vehicle_model_id,select#vehicle_lookup_vehicle_model_id');
  $elems['vehicle_models'] = $('#vehicle_trim_vehicle_model_id');
  $elems['makes'].attr('disabled',true);
  $elems['models'].attr('disabled',true);
  $elems['lookupSubmitBtn'] = $(".controller-admin-vehicle-lookups .new_vehicle_lookup .btn-success");
  $elems['lookupSubmitBtn'].attr('disabled',true);
  $elems['lookupSubmitBtn'].text("Lookup Vehicle");
  var checkIfReady = function() {
    if ($elems['years'].val() && $elems['makes'].val() && $elems['models'].val()) {
      $elems['lookupSubmitBtn'].attr('disabled',false);
    } else {
      $elems['lookupSubmitBtn'].attr('disabled',true);
    }
  }
  if ($("body").hasClass("controller-admin-vehicle-lookups action-new")) {
    $elems['years'].attr('disabled',false);
  }
  var getModelsForMake = function(make) {
    $.getJSON("/vehicle_models.json?make=" + make).then(function(records) {
      var options = records.map(function(record) {
        return $("<option value=\"" + record.id + "\">" + record.name + "</option>");
      });
      options.unshift($("<option value=\"\">Select your model</option>"));
      if (options) {
        $elems["models"].select2("val","");
        
        return $elems["models"].html(options);
      } else {
        return $elems["models"].empty();
      }
    });
  }
  var getTrimsForVehicleConfig = function(vehicle_config) {
    $.getJSON("/vehicle_configs/trims.json?vehicle_config=" + vehicle_config).then(function(records) {
      var options = records.map(function(record) {
        return $("<option value=\"" + record.id + "\">" + record.name + "</option>");
      });
      options.unshift($("<option value=\"\">Select your trim</option>"));
      if (options) {
        $elems["trims"].select2("val","");
        
        return $elems["trims"].html(options);
      } else {
        return $elems["trims"].empty();
      }
    });
  }
  var getTrimStylesForTrim = function(trim) {
    $.getJSON("/vehicle_trim_styles.json?trim=" + trim).then(function(records) {
      var options = records.map(function(record) {
        return $("<option value=\"" + record.id + "\">" + record.name + "</option>");
      });
      options.unshift($("<option value=\"\">Select your trim style</option>"));
      if (options) {
        $elems["trim_styles"].select2("val","");
        
        return $elems["trim_styles"].html(options);
      } else {
        return $elems["trim_styles"].empty();
      }
    });
  }
  
  var getBranchesForRepository = function(repository) {
    $.getJSON("/repository_branches.json?repository=" + repository).then(function(records) {
      var options = records.map(function(record) {
        return $("<option value=\"" + record.id + "\">" + record.name + "</option>");
      });
      options.unshift($("<option value=\"\"></option>"));
      if (options) {
        $elems["repository_branches"].select2("val","");
        return $elems["repository_branches"].html(options);
      } else {
        return $elems["repository_branches"].empty();
      }
    });
  }
  $elems['years'].change(function() {
    var year = $(this).val();

    if (year) {
      $elems['makes'].attr('disabled',false);
    } else {
      $elems['makes'].attr('disabled',true);
    }
    checkIfReady();
  });
  $elems['models'].change(function() {
    var model, options;
    var modelId = $('#vehicle_config_vehicle_model_id').val();
    // getModelsForMake('trim',modelId);
    checkIfReady();
  });

  $elems['makes'].change(function() {
    var $this = $(this);
    $optionsParent = $this.find('.select2-selection__rendered');

    sortUsingNestedText($optionsParent,'li','li:text');
    var make, options;
    make = $this.val();
    // // console.log(options);
    if (make) {
      $elems['models'].attr('disabled',false);
      getModelsForMake(make);
    } else {
      $elems['models'].attr('disabled',true);
    }
    checkIfReady();
  });
  
  $elems['repositories'].change(function() {
    var $this = $(this);
    $optionsParent = $this.find('.select2-selection__rendered');

    sortUsingNestedText($optionsParent,'li','li:text');
    var repository, options;
    repository = $this.val();
    // // console.log(options);
    getBranchesForRepository(repository);
  });
  $elems['vehicle_configs'].change(function() {
    var $this = $(this);
    $optionsParent = $this.find('.select2-selection__rendered');

    sortUsingNestedText($optionsParent,'li','li:text');
    var vehicle_config, options;
    vehicle_config = $this.val();
    // // console.log(options);
    getTrimsForVehicleConfig(vehicle_config);
  });

  if ($elems['vehicle_configs'].val()) {
    getTrimsForVehicleConfig($elems['vehicle_configs'].val());
  }

  $elems['trims'].change(function() {
    var $this = $(this);
    $optionsParent = $this.find('.select2-selection__rendered');

    sortUsingNestedText($optionsParent,'li','li:text');
    var trim, options;
    trim = $this.val();
    // // console.log(options);
    getTrimStylesForTrim(trim);
  });
  function sortUsingNestedText(parent, childSelector, keySelector) {
      var items = parent.children(childSelector).sort(function(a, b) {
          var vA = $(keySelector, a).text();
          var vB = $(keySelector, b).text();
          return (vA < vB) ? -1 : (vA > vB) ? 1 : 0;
      });
      parent.append(items);
  }

  $elems['trims'].change(function() {
    
  })
});
$(Trestle).on("init",function() {
  var $refreshingTrims = $(".alert-loading-trims");
  if ($refreshingTrims.length) {
    // pollRefreshingStatus();
  }
});