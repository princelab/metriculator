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

    $.get("comparisons?" + query_string, function(data, status, jqXHR) {
      console.log("SUCCESS! " + status);
    });
  });
