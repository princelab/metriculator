// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
$(function() {
  $("#msruns th a, #msruns li a").click(function(event) {
    $.getScript(this.href);
    return false;
  });

  // Fade the alerts out when the delete link is clicked.
  $("#alerts div a").click(function() {
    $(this).parent().fadeOut(500, function () {
      $(this).remove();
      // Decrement the count
      alertcount = $("#alert_num").text();
      alertcount--;

      if (alertcount == 0) {
        $("#alert_num").removeClass("alert_bad");
      }

      $("#alert_num").text(alertcount);

      // If this was the last alert, set the div to 'No alerts'
      if ($("#alerts").children().length == 0) {
        $("#alerts").text("No alerts.");
      }
    });
  });

  $("#alert_num").click(function(event) {
    event.preventDefault();
    $("#alerts, #not-alerts, #alert_num").toggleClass("show"); // Show the alerts box and related elements
    $("#alert_num").parent().toggleClass("show");
  });

  $("#not-alerts").click(function(event) {
    $("#alerts, #not-alerts, #alert_num").removeClass("show");
    $("#alert_num").parent().removeClass("show");
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
