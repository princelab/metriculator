$(function() {

  $("#msruns td button#group-1-all").live("click", function () {
    RailsMetrics.allButtonClicked("1");
  });

  $("#msruns td button#group-2-all").live("click", function () {
    RailsMetrics.allButtonClicked("2");
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

RailsMetrics.allButtonClicked = function(whichComparisonSet) {
  var count = 0;
  $("#msruns tr").each(function(i, row) {
    if (row.id !== "") {
      //We are at a row that has data
      RailsMetrics.comparisonClicked(whichComparisonSet, $(row).children().eq(parseInt(whichComparisonSet, 10)).children()[0]);
      count++;
    }
  });
  if (count > 0) {
    //Make a message appear.
    var stamp = new Date().getTime();
    $("span").attr({
      id: stamp,
      "class": ""
    }).text("" + count + " comaprisons added to Comparison Set " + whichComparisonSet + ".").appendTo("#messages");
    setTimeout(function() {
      $("#"+stamp).hide("fold");
    }, 5000);
  }
};
