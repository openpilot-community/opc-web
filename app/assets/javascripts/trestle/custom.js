var originalAddClassMethod = jQuery.fn.addClass;
var originalRemoveClassMethod = jQuery.fn.removeClass;
function pollRefreshingStatus(){
  $.getJSON($(".app-main").attr('data-context') + "/refreshing_status.json", function(data) {
      console.log(data);  // process results here

      if (data.refreshing) {
        setTimeout(pollRefreshingStatus,5000);
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
  var $refreshingTrims = $(".alert-loading-trims");
  var $quickAdd = $("#tab-capabilities .type-quick-add");
  var $quickDelete = $("#tab-capabilities .type-quick-delete");

  $quickAdd.off("click");

  $quickAdd.on("click",function(ev) {
    ev.preventDefault();

    $.ajax({
      url: '/vehicle_config_capabilities/quick_add.json',
      type: 'post',
      dataType: 'json',
      data: {

      }
    })
  })
  if ($refreshingTrims.length) {
    pollRefreshingStatus();
  }
  if ($('.app-wrapper.is-visitor').length) {
    if (!$("body.controller-admin-vehicle-lookups.action-new").length) {
      console.log("DISABLING FIELDS");
      $(".trestle-table .actions > *").remove();
      $(".main-content .form-control,.modal-body .form-control").attr('disabled',true);
    }
  }
  
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
  // var $vehicle_make = $("#vehicle_config_vehicle_make_id").select2();
  // var $vehicle_model = $("#vehicle_config_vehicle_model_id").select2();
  // console.warn("$year_start:", $year_start);
  // console.warn("$year_start_column:", $year_start);
  // console.warn("$year_start_select2_container:", $year_start);
  // console.warn("$year_end:", $year_end);
  // console.warn("$year_end_column:", $year_end);
  // console.warn("$year_end_select2_container:", $year_end);

  // console.warn("$year_range:", $year_range);
  // console.warn("$add_year_end_link:", $add_year_end_link);
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

$(Trestle).on("init",function() {
  var $sidebar = $(".app-sidebar");
  var $contentContainer = $(".main-content-container");
  var resizeDocument = function() {
    var sidebarWidth = $sidebar.outerWidth();
    $contentContainer.css({
      width: $(document).width()-sidebarWidth
    });
  }
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

  $elems['repositories'] = $("#vehicle_config_repository_repository_id");
  $elems['repository_branches'] = $("#vehicle_config_repository_repository_branch_id");
  $elems['trims'] = $('select#vehicle_config_vehicle_trim_id');
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