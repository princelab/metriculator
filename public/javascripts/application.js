// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
$(function() {
  $("#msruns th a, #msruns li a").live("click", function() {
    $.getScript(this.href);
    return false;
  });
});

//Define our namespace
var RailsMetrics = {};
