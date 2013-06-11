//= require jquery
//= require 'highcharts'
//= require 'exporting'
//= require 'array_tools'
//= require 'science.min'
//= require 'science.stats.min'

var generate_plot = function(str) {
  var t_test = str[3];
  var kdes = str[2];
  var new_vals = str[0];
  var old_vals = str[1];
  var chart_number = str[4] + 1;
  var bean_render = 'bean' + chart_number;
  var time_render = 'time' + chart_number;
  var plot_title = eval("plot_title" + chart_number);

  // CONSTANTS
  var binning_size_factor = 50.0;
  var normalization_value = 1.0;
  var bin_scaling_value = 1.5;
  var desired_normalization_level = 1.1;

  console.log("CHART NAME:%s", plot_title);

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
  console.log(new_kde);
  console.log(old_kde);
// FXNS:
  var sort_arrays = function(a,b) {
    return a[0]-b[0]
  };
  var bin_and_normalize_input = function(input_data, normalization_val, minmax) {
    var val_pairs = new Array();
    var x_vals = new Array();
    $.each(input_data.sort(function(a,b){return parseFloat(a)-parseFloat(b)}), function(index, value) {
      val_pairs[index] = [value, 1];
      x_vals[index] = value;
    })
    console.log(x_vals);
    // SETUP BINNING HERE (Histogram)
    if (minmax[1] == minmax[0]) {
      size = input_data.length;
      bin_width = size / binning_size_factor;
      minmax = [minmax[0]-bin_width*2, minmax[1]+bin_width*2];
    } else {
      size = minmax[1]- minmax[0];
      bin_width = size / binning_size_factor;
    }
    num_bins =  binning_size_factor;
    var output = new Array(num_bins);
    // Set loop conditions
    var j = 0, bin_low = minmax[0], bin_mid = bin_low + bin_width /2.0, bin_high = bin_low + bin_width
    // Initialize the x values
    $.each(output, function(i, val) {
      output[i] = [bin_mid+bin_width*i, 0];
    });
    // NORMALIZE HERE
    $.each(output, function(i, value) {
      while (x_vals[j] < value[0] && j <= size) {
        output[i][1] = value[1] + val_pairs[j][1];
        j++;
      }
    });
    return output;
  };
  var normalize_kde = function(input_kde, factor) {
    var output = new Array(input_kde[0].length);
    $.each(output, function(index, value) {
      output[index] = [input_kde[0][index], input_kde[1][index] / factor]
    });
    return output;
  };
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
// END FXNS
  var new_data = prep_time(new_vals[1], new_vals[0]);
  var old_data = prep_time(old_vals[1], old_vals[0]);

  // Determine the proper bounds for the x values and for the kdes
  var kde_high = Array.max(old_kde[0].concat(new_kde[0]));
  var kde_low = Array.min(old_kde[0].concat(new_kde[0]));

  // Bin the values
  var new_output_data = bin_and_normalize_input(new_vals[0], normalization_value, [kde_low, kde_high]);
  var old_out = bin_and_normalize_input(old_vals[0], normalization_value, [kde_low, kde_high]);
  // REVERSE the values for the old_data set
  var old_output_data = new Array(old_out.length);
  $.each(old_out, function(i, v) {
    old_output_data[i] = [v[0], v[1] * (-1)];
  });
  var old_values = new Array(old_out[0].length);
  $.each(old_out, function(i,v) {
    old_values[i] = v[1];
  });
  var new_values = new Array(new_output_data.length);
  $.each(new_output_data, function(i,v) {
    new_values[i] = v[1];
  });
  // CALCULATE MAXES for ratios
  var new_val_max = Array.max(new_values);
  var old_val_max = Array.max(old_values);
  var new_kde_max = Array.max(new_kde[1]);
  var old_kde_max = Array.max(old_kde[1]);
  var new_normalization_factor = new_kde_max/((new_val_max)*desired_normalization_level);
  var old_normalization_factor = old_kde_max/((old_val_max)*desired_normalization_level);

  console.group("NORMALIZATION");
  //console.log("new VAL max: %O", new_val_max);
  //console.log("new KDE max: %O", new_kde_max);
  console.log("new norm factor: %O", new_normalization_factor);
  console.log("==================");
  //console.log("old VAL max: %O", old_val_max);
  //console.log("old KDE max: %O", old_kde_max);
  console.log("old norm factor: %O", old_normalization_factor);
  console.groupEnd();
  // NORMALIZE the KDES
  new_kde = normalize_kde(new_kde, new_normalization_factor);
  old_output_kde = normalize_kde(old_output_kde, old_normalization_factor);

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
      marginBottom: 55,
      marginTop: 45
    },
    credits: {
      enabled: false
    },
    exporting: {
      enabled: true
    },
    legend: { 
    },
    title: { text: 'Beanplot' },
    subtitle: {
      text: "T-test p-value: " + t_test,
      style: { fontSize: '10px' }
    }, 
    yAxis: {
      labels: {
        enabled: true, 
        formatter: function () {return Math.abs(this.value);}
      }, 
      gridLineWidth: 1, 
      title: {text: null}
    },
    xAxis: { 
      min: kde_low,
      max: kde_high,
      gridLineWidth: 1, 
      reversed: false, 
      endOnTick: true,
      startOnTick: false
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
};
