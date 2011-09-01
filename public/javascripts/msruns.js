$(function() {

  $("#msruns td#group-1-all").live("click", RailsMetrics.allButtonClicked("1"));
  $("#msruns td#group-2-all").live("click", RailsMetrics.allButtonClicked("2"));

  $("#msruns td.comparison1 button").live("click", function() {
    RailsMetrics.comparisonClicked("1", this);
  });

  $("#msruns td.comparison2 button").live("click", function() {
    RailsMetrics.comparisonClicked("2", this);
  });
});

RailsMetrics.comparisonClicked = function(whichComparisonSet, clickedObject) {
  var comparisonID = clickedObject.id.split(/-/)[2];
  var comparisonName = $("#msruns tr#msrunid-"+comparisonID).children().eq(2).text();
  // Check if it is in the select list already. If not, add it in.
  $("#comparison"+whichComparisonSet).append("<option value='"+ comparisonID + "' selected>" + comparisonName + "</option>");
  //Add some kind of flash notice that it was added.
  return true;
};

RailsMetrics.allButtonClicked = function(whichComparisonSet) {
  $("#msruns tr").each(function(i, row) {
    var count = 0;
    if (row.id !== "") {
      //We are at a row that has data
      RailsMetrics.comparisonClicked(whichComparisonSet, $(row).children().eq(parseInt(whichComparisonSet, 10)).children()[0]);
      count++;
    }
    if (count > 0) {
      //Make a message appear.
      var stamp = new Date().getTime();
      var added_message = $("#messages").append("<span id='" + stamp + "'>" + count + " comparisons added to Comparison Set " + whichComparisonSet + ".</span>");
      setTimeout(10000, function() {
        $("#"+stamp).hide("fold");
      });
    }
  });
};
