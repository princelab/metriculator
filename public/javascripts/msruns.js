$(function() {
  "use strict";

  //Encapsulate the notification stuff in here, so it
  //is not strewn about everywhere.
  function displayNotification(notificationText) {
    humane.log(notificationText);
  }

  $("#search_rawtime_start").live("click", function() {
    $(this).datepicker({dateFormat: "yy-mm-dd",});
  });
  $("#search_rawtime_end").live("click", function() {
    $(this).datepicker({dateFormat: "yy-mm-dd",});
  });

  // When the "Filter" button is clicked, filter based on data
  // in ALL search forms.
  $("#filter").live("click", function () {
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
  $("#group-1-all").live("click", function () {
    var count
      ;
    count = RailsMetrics.allButtonClicked("1");
    displayNotification("" + count + " comparisons added to Comparison Set 1.");
  });

  $("#group-2-all").live("click", function () {
    var count
      ;
    count = RailsMetrics.allButtonClicked("2");
    displayNotification("" + count + " comparisons added to Comparison Set 2.");
  });

  $("#msruns td.comparison1>div").live("click", function() {
    var res
      , stamp
      ;

    res = RailsMetrics.addToComparisonSet("1", this);
    if (res) {
      displayNotification("Comparison added to Comparison 1.");
    }
  });

  //UGHH Repeated code
  $("#msruns td.comparison2>div").live("click", function() {
    var res = RailsMetrics.addToComparisonSet("2", this)
      , stamp
      ;

    if (res) {
      displayNotification("Comparison added to Comparison 2.");
    }
  });
});
