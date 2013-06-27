// This one will do the plotting for the UPLC plots

// Format timepoint_data
  var prep_time = function(temp, datapoints) {
    var output = [];
    $.each(temp, function(i,v) {
      output[i] = [Date.parse(v), datapoints[i]];
    })
    output.sort( function(a,b) {
      return a[0]-b[0] 
    })
    return output
  }
var plugin_values = function(file) {


}

var generate_plot = function(file) {
  var t_test = str[3];
  var kdes = str[2];
  var new_vals = str[0];
  var old_vals = str[1];
  var chart_number = str[4] + 1;

  var time_render = 'plot' + chart_number;

  var new_data = prep_time(new_vals[1], new_vals[0]);
  var old_data = prep_time(old_vals[1], old_vals[0]);


}

$(document).ready(function() {
  var time_plot = new Highcharts.Chart({
    chart: {
      renderTo: document.getElementById(time_render),
      zoomType: 'xy',
      reflow: false,
      marginBottom: 55,
      marginTop: 45
    },
      credits: { enabled: false },
      legend: { 
        layout: 'horizontal',
      y: 5
      },
      title: {
        text: "Values over Time"
      },
      subtitle: {
        text: plot_title,
      style: { fontSize: '11px' }
      }, 
      xAxis: { /*
                  labels: {
                  enabled: true, 
                  formatter: function () {
                  return Math.abs(this.value);
                  }
                  }, */
        gridLineWidth: 1, 
        type: 'datetime'
      },
      yAxis: { 
        min: kde_low,
        max: kde_high,
        gridLineWidth: 1, 
        reversed: false, 
        endOnTick: true,
        startOnTick: false, 
        title: {text: null}
      },

      plotOptions: {
        series: {
          animation: false,
          marker: {
            enabled: false
          }, 
          turboThreshold: 10
        },
      },
      tooltip: { crosshairs: true }, 
      series: [{
        type: 'line',
        data: old_data, 
        name: first,
        color: '#00688B',
        zIndex: 1,
      }, {
        type: 'line', 
        data: new_data,
        name: second,
        color: '#B22222',
        zIndex: 1
      }]
  });
});
