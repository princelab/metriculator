$(function() {
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
