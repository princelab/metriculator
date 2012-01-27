MetricsSite::Application.config.after_initialize do 
  %x[R CMD Rserve]
end
