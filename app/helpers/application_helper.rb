# Helper functions for the Application
module ApplicationHelper
# This is the list of categories which are used for sorting and grouping the metrics
  Categories = ["uplc", "chromatography", "ms1", "dynamic_sampling", "ion_source", "ion_treatment", "peptide_ids", "ms2", "run_comparison"]
# Return a title which wisely configures itself correctly
  def title
    base_title = "Mass Spectrometry/Analysis Performance Metrics"
    if @title.nil?
      base_title
    else
      "#{@title} | #{base_title}"
    end
  end
# Logo method 
  def logo
    image_tag("logo.png", alt: "Metrics", class: 'round')
  end

# Creates a link to sort table colums.
  def sortable(column_name, title = nil)
    title ||= column_name.titleize
    direction = params[:sort] == column_name && params[:direction] == "asc" ? "desc" : "asc"
    css_class = params[:sort] == column_name ? "sort #{direction}" : nil
    link_to title, params.merge(:sort => column_name, :direction => direction, :page => nil), { :class => css_class }
  end

  # creates linked files, JSON anyone?
  def link_to_file(name, file, *args)
    if file[0] != ?/
      file = "#{@request.relative_url_root}/#{file}"
    end
    link_to name, file, *args
  end
end
