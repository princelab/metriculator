//= require jquery
//= require 'highcharts'
//= require 'array_tools'
//= require 'science.min'
//= require 'science.stats.min'

// JS goes here
var generate_plot = function(str) {
  var t_test = str[3];
  var kdes = str[2];
  var new_vals = str[0];
  var old_vals = str[1];
  var chart_number = str[4] + 1;
  var bean_render = 'bean' + chart_number;
  var time_render = 'time' + chart_number;

  console.log("CHART%s", chart_number);
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
  var new_data = prep_time(new_vals[1], new_vals[0]);
  var old_data = prep_time(old_vals[1], old_vals[0]);
  // Prepare the KDE values
  var new_kde = kdes[0];
  var old_kde = kdes[1];
  var old_output_kde = [[],[]];
  $.each(old_kde, function(i, arr) {
    $.each(arr, function(j, v) {
      if (i === 0) {
        old_output_kde[0][j] = v;
      } else {
        old_output_kde[1][j] = v * (-1);
      }
    });
  });

  // Determine the proper bounds for the x values and for the kdes
  var kde_high = Array.max(old_kde[0].concat(new_kde[0]));
  var kde_low = Array.min(old_kde[0].concat(new_kde[0]));
  var kde_y_high = Array.max(old_kde[1].concat(new_kde[1]));
  var kde_y_low = Array.min(old_kde[1].concat(new_kde[1]));

  var normalization_value = 3;
  var normalization_factor = 90;

  var bin_and_normalize_input = function(input_data, normalization_val) {
    var val_pairs = new Array();
    var x_vals = new Array();
    $.each(input_data.sort(), function(index, value) {
      val_pairs[index] = [value, normalization_val]
      x_vals[index] = value
    })
    // BINNING HERE (Histogram)
    size = x_vals.length
    bin_width = size / 100.0
    bin_low_val = Array.min(x_vals) - size * normalization_value
    bin_high_val = Array.max(x_vals) + size * normalization_value
    num_bins =  Math.ceil((bin_high_val - bin_low_val)/bin_width)
    var output = new Array(num_bins);
    // Set loop conditions
    var j = 0, bin_low = bin_low_val, bin_mid = bin_low + bin_width /2.0, bin_high = bin_low + bin_width
    // Initialize the x values
    $.each(output, function(i, val) {
      output[i] = new Array(2);
      output[i][0] = bin_mid + bin_width * i;
      output[i][1] = 0;
    });
    // NORMALIZE HERE
    $.each(output, function(i, value) {
      while (val_pairs[j][0] < value[0] && j < size - 1) {
        output[i][1] = value[1] + val_pairs[j][1] * normalization_value;
        j++;
      }
    });
    return output;
  };
  var sort_arrays = function(a,b) {
    return parseFloat(a[0])-parseFloat(b[0])
  };
  
  var normalize_kde = function(input_kde, factor) {
    var output = new Array(input_kde[0].length);
    $.each(output, function(index, value) {
      output[index] = [input_kde[0][index], input_kde[1][index] * factor]
    });
    return output;
  };

  var new_output_data = bin_and_normalize_input(new_vals[0], normalization_value);
  var old_out = bin_and_normalize_input(old_vals[0], normalization_value);
  var old_output_data = new Array(old_out.length);
  $.each(old_out, function(i, v) {
    old_output_data[i] = [v[0], v[1] * (-1)];
  });

  new_kde = normalize_kde(new_kde, normalization_factor);
  old_output_kde = normalize_kde(old_output_kde, normalization_factor);

  console.groupCollapsed("Examine the data");
  console.log("old_output_data.slice(0,10)): %O", old_output_data.slice(0,10));
  console.log("old_output_kde.slice(0,10)): %O", old_output_kde.slice(0,10));
  console.log("new_output_data.slice(0,10)): %O", new_output_data.slice(0,10));
  console.log("new_kde.slice(0,10)): %O", new_kde.slice(0,10));
  console.groupEnd();

  // DOCUMENT
  $(document).ready(function() {
    var area_chart = new Highcharts.Chart({
    chart: {
      renderTo: document.getElementById(bean_render),
      inverted: true, 
      reflow: false, 
      width: 300,
      zoomType: 'xy'
    },
    legend: { 
      floating: true,
      y: -35
    },
    title: { text: 'Beanplot' },
    subtitle: {
      text: "T-test p-value: " + t_test,
      style: { fontSize: '10px' }
    }, 
    yAxis: {
      labels: {
        enabled: true, 
        formatter: function () {
          return Math.abs(this.value);
        }
      }, 
      gridLineWidth: 1 
    },
    xAxis: { 
      min: kde_low,
      max: kde_high,
      gridLineWidth: 1, 
      reversed: false
    },
    plotOptions: {
      column: {
        stacking: 'normal',
        shadow: false,
        borderWidth: 0,
        pointWidth: 1, 
        allowPointSelect: false,
        enableMouseTracking: false, 
        showInLegend: false,
      }, 
      series: {
        animation: false,
        marker: {
          enabled: false
        }, 
        turboThreshold: 10
      },
      area: { 
        enableMouseTracking: false,
      }
    },
    series: [{
        type: 'column',
        data: old_output_data, 
        name: first,
        color: '#00688B',
        zIndex: 1,
      }, { 
        type: 'area',
        data: old_output_kde,
        name: first,
        color: '#01698C',
      }, {
        type: 'column', 
        data: new_output_data,
        name: second,
        color: '#B22222',
        zIndex: 1
      }, {
        type: 'area',
        data: new_kde,
        name: second,
        color: '#B32323',
      }]
    });
    /*
    function(chart){
      varpoint=chart.series[0].data[8];
      varbox= text.getBBox();
      chart.renderer.rect(box.x-5,box.y-5,box.width+10,box.height+10,5).attr({
        fill:'#FFFFEF',
        stroke:'gray',
        'stroke-width':1,
        zIndex:4
      }).add();
    } */
    var time_plot = new Highcharts.Chart({
      chart: {
        renderTo: document.getElementById(time_render),
        zoomType: 'xy',
        reflow: false
      },
      legend: { 
        layout: 'horizontal'
      },
      title: {
        text: "Values over Time"
      },
      subtitle: {
        text: "Chromatography -- Peak Width at Half Height for IDs -- 3QuartValue",  // TODO get the right name
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
        reversed: false
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
};
