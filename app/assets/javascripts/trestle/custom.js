// This file may be used for providing additional customizations to the Trestle
// admin. It will be automatically included within all admin pages.
//
// For organizational purposes, you may wish to define your customizations
// within individual partials and `require` them here.
//
//  e.g. //= require "trestle/custom/my_custom_js"
var setupVehicleConfigYear = function() {
  var $year_start = $("#vehicle_config_year");
  var $year_start_column = $(".col-class-year-start");
  var $year_start_select2_container = $year_start_column.find('.select2-container');
  var $year_end = $("#vehicle_config_year_end");
  var $year_end_column = $(".col-class-year-end");
  var $year_end_select2_container = $year_end_column.find('.select2-container');
  var $year_range = $('.col-class-year-range');
  var $add_year_end_link = $("<a class=\"year-end-link\" href=\"javascript:void(0);\">+ Add End Year</a>");
  var originalAddClassMethod = jQuery.fn.addClass;
  var originalRemoveClassMethod = jQuery.fn.removeClass;
  jQuery.fn.addClass = function(){
    // Execute the original method.
    var result = originalAddClassMethod.apply( this, arguments );

    // trigger a custom event
    jQuery(this).trigger('classAdded');

    // return the original result
    return result;
  }
  jQuery.fn.removeClass = function(){
    // Execute the original method.
    var result = originalRemoveClassMethod.apply( this, arguments );

    // trigger a custom event
    jQuery(this).trigger('classRemoved');

    // return the original result
    return result;
  }
  var onYearOpen = function(ev) {
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
  })

  $year_end.on("change",function() {
    var $this = $(this)
    var new_value = $this.val();
    refresh_year_view();
  });

  refresh_year_view();
}

$(Trestle).on("init",function() {
  setupVehicleConfigYear();
})
jQuery(function() {
  var trims;
  var models;
  var $elems = {}
  var $el = Trestle.Dialog.getElement();

  
  
  $.fn.modal.Constructor.prototype.enforceFocus = function () {
    $(document)
      .off('focusin.bs.modal') // guard against infinite focus loop
      .on('focusin.bs.modal', $.proxy(function (e) {
          if (this.$element[0] !== e.target && !this.$element.has(e.target).length && !$(e.target).closest('.select2-dropdown').length) {
              this.$element.trigger('focus')
          }
      }, this))
  }
  $elems['trims'] = $('select#vehicle_config_vehicle_trim_id');
  $elems['makes'] = $('select#vehicle_config_vehicle_make_id');
  $elems['models'] = $('select#vehicle_config_vehicle_model_id');
  $elems['vehicle_models'] = $('#vehicle_trim_vehicle_model_id');

  var getOptions = function(type,scope) {
    $.getJSON("/admin/vehicle_" + type + "s.json?scope=" + scope).then(function(records) {
      var options = records.map(function(record) {
        return $("<option value=\"" + record.id + "\">" + record.name + "</option>");
      });
      options.unshift($("<option value=\"\"></option>"));
      if (options) {
        $elems[type + "s"].select2("val","");
        return $elems[type + "s"].html(options);
      } else {
        return $elems[type + "s"].empty();
      }
    });
  }

  $elems['models'].change(function() {
    var model, options;
    var modelId = $('#vehicle_config_vehicle_model_id').val();
    getOptions('trim',modelId);
  });

  $elems['makes'].change(function() {
    var $this = $(this);
    $optionsParent = $this.find('.select2-selection__rendered');

    sortUsingNestedText($optionsParent,'li','li:text');
    var make, options;
    make = $this.val();
    // // console.log(options);
    getOptions('model', make);
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