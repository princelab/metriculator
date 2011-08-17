// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
$(function() {
  $("#msruns th a, #msruns li a").live("click", function() {
    $.getScript(this.href);
    return false;
  });

  // Fade the alerts out when the delete link is clicked.
  $("#alerts span a").live("click", function() {
    $(this).parent().fadeOut()
  });
});

//Define our namespace
var RailsMetrics = {};
