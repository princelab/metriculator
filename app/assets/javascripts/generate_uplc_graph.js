// This one will do the plotting for the UPLC plots

var generate_plot = function(file) {



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
