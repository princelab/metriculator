MetricsSite::Application.config.after_initialize do 
  %x[R CMD BATCH #{File.join(MetricsSite::Application.config.root, 'r_rserve_save.R')}  ]
  %x[R CMD Rserve]
end
