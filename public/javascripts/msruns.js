$(function() {
  $("#msruns td#group-1-all").live("click", function() {
    // Add everything on the page to the option
    $("#msruns tr").each(function(i, row) {
      if (row.id !== "") {
        //We are at a row that has data
        RailsMetrics.comparisonClicked("1", row.children().eq(1).children());
      }
    });
  });
  $("#msruns td#group-2-all").live("click", function() {
    $("#msruns tr").each(function(i, row) {
      if (row.id !== "") {
        // We are at a row that has data
        RailsMetrics.comparisonClicked("2", row.children().eq(2).children());
      }
    });
  });
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
