// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
$(function() {
  $("#msruns th a, #msruns li a").click(function(event) {
    $.getScript(this.href);
    return false;
  });

  // Fade the alerts out when the delete link is clicked.
  $("#alerts span a").click(function(event) {
    $(this).parent().fadeOut()
  });

  $("#alert_num").click(function(event) {
    event.preventDefault();
    $("#alerts").toggleClass("show"); // Show the alerts box
    $("#not-alerts").toggleClass("show"); // Show the hidden div across the rest of the page
  });

  $("#not-alerts").click(function(event) {
    $("#alerts").removeClass("show");
    $("#not-alerts").removeClass("show");
  });
});

var RailsMetrics = {
  addToComparisonSet: function(whichComparisonSet, clickedObject) {
    "use strict";
    var comparisonID = clickedObject.id.split(/-/)[2]
      , comparisonName = $("#msruns tr#msrunid-"+comparisonID).children().eq(2).text()
      , option = "<option value='"+ comparisonID + "' selected>" + comparisonName + "</option>"
      , isAlreadyIncluded = false
      ;
    $("#comparison" + whichComparisonSet).children().each(function(i, comp) {
      if (comp.value == comparisonID) {
        isAlreadyIncluded = true;
      }
    });
    if (!isAlreadyIncluded) {
      $("#comparison"+whichComparisonSet).append(option);
      return true;
    }
    return false;
  },

  allButtonClicked: function(whichComparisonSet) {
    "use strict";
    var count = 0
      , stamp
      ;
    $("#msruns tr").each(function(i, row) {
      var added
        ;
      if (row.id !== "") {
        //We are at a row that has data
        added = RailsMetrics.addToComparisonSet(whichComparisonSet, $(row).children().eq(parseInt(whichComparisonSet , 10) - 1).children()[0]);
        if (added) {
          count++;
        }
      }
    });
    return count;
  }
};
