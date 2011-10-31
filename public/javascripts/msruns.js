$(function() {

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
    var parms = [];
    $("form div.filter-form :input").each(function(i, obj) {
      if (obj.type === "submit" || obj.value === "") {
        return;
      }
      var query_string = obj.name + "=" + obj.value;
      console.log(query_string);
      if (parms.indexOf(query_string) === -1) {
        parms.push(query_string);
      }
    });

    var query_string = parms.join("&");
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
    var res = RailsMetrics.addToComparisonSet("1", this);
    if (res) {
      var stamp = new Date().getTime();
      $("span").attr({
        id: stamp,
        "class": ""
      }).text("Comparison added to Comparison 1.").appendTo("#messages");
      setTimeout(function() {
        $("#"+stamp).hide("fold");
      }, 5000);
    }
  });

  //UGHH Repeated code
  $("#msruns td.comparison2 button").live("click", function() {
    var res = RailsMetrics.addToComparisonSet("2", this);

    if (res) {
      var stamp = new Date().getTime();
      $("span").attr({
        id: stamp,
        class: stamp 
      }).text("Comparison added to Comparison 2.").appendTo("#messages");
      setTimeout(function() {
        $("."+stamp).hide("fold");
      }, 5000);
    }
  });
});

RailsMetrics.addToComparisonSet = function(whichComparisonSet, clickedObject) {
  var comparisonID = clickedObject.id.split(/-/)[2];
  var comparisonName = $("#msruns tr#msrunid-"+comparisonID).children().eq(2).text();
  //TODO: Check if it is in the select list already. If not, add it in.
  var option = "<option value='"+ comparisonID + "' selected>" + comparisonName + "</option>";
  var isAlreadyIncluded = false;
  $("#comparison" + whichComparisonSet).children().each(function(i, comp) {
    if (comp.value == comparisonID) {
      isAlreadyIncluded = true;
    }
  });
  if (!isAlreadyIncluded) {
    $("#comparison"+whichComparisonSet).append(option);
    // TODO: Add some kind of flash notice that it was added.
    return true;
  }
  return false;
};

RailsMetrics.allButtonClicked = function(whichComparisonSet) {
  var count = 0;
  $("#msruns tr").each(function(i, row) {
    if (row.id !== "") {
      //We are at a row that has data
      var added = RailsMetrics.addToComparisonSet(whichComparisonSet, $(row).children().eq(parseInt(whichComparisonSet - 1, 10)).children()[0]);
      if (added) {
        count++;
      }
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
