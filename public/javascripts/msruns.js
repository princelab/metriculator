$(function() {
  "use strict";

  $("#search_rawtime_start").live("click", function() {
    $(this).datepicker({dateFormat: "yy-mm-dd",});
  });
  $("#search_rawtime_end").live("click", function() {
    $(this).datepicker({dateFormat: "yy-mm-dd",});
  });

  // When the "Filter" button is clicked, filter based on data
  // in ALL search forms.
  $("button#filter").live("click", function () {
    //Build the query string from the filter forms
    var parms = []
      , query_string
      ;
    $("form div.filter-form :input").each(function(i, obj) {
      var query_string_fragment
        ;
      if (obj.type === "submit" || obj.value === "") {
        return;
      }
      query_string_fragment = obj.name + "=" + obj.value;
      console.log(query_string_fragment);
      if (parms.indexOf(query_string_fragment) === -1) {
        parms.push(query_string_fragment);
      }
    });

    query_string = parms.join("&");
    console.log(query_string);

    $.get("msruns?" + query_string, function(data, status, jqXHR) {
      console.log("SUCCESS! " + status);
    });
  });

  // Add stuff to comparison form.
  $("#msruns td button#group-1-all").live("click", function () {
    RailsMetrics.allButtonClicked("1");
  });

  $("#msruns td button#group-2-all").live("click", function () {
    RailsMetrics.allButtonClicked("2");
  });

  $("#msruns td.comparison1 button").live("click", function() {
    var res = RailsMetrics.addToComparisonSet("1", this)
      , stamp
      ;
    if (res) {
      stamp = new Date().getTime();
      $("span").attr({
        "id": stamp,
        "class": stamp
      }).text("Comparison added to Comparison 1.").appendTo("#messages");
      setTimeout(function() {
        $("#"+stamp).hide("fold");
      }, 5000);
    }
  });

  //UGHH Repeated code
  $("#msruns td.comparison2 button").live("click", function() {
    var res = RailsMetrics.addToComparisonSet("2", this)
      , stamp
      ;

    if (res) {
      stamp = new Date().getTime();
      $("span").attr({
        "id": stamp,
        "class": stamp
      }).text("Comparison added to Comparison 2.").appendTo("#messages");
      setTimeout(function() {
        $("."+stamp).hide("fold");
      }, 5000);
    }
  });
});
