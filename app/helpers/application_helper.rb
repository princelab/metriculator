module ApplicationHelper
  CATEGORIES = ["chromatography", "ms1", "dynamic_sampling", "ion_source", "ion_treatment", "peptide_ids", "ms2", "run_comparison"]
  # Return a title which wisely configures itself correctly
  def title
    base_title = "Mass Spectrometry/Analysis Performance Metrics"
    if @title.nil?
      base_title
    else
      "#{@title} | #{base_title}"
    end
  end

  def logo
    image_tag("logo.png", alt: "Metrics", class: 'round', height: "13%", width: "22%")
  end

  # Creates a link to sort table colums.
  def sortable(column_name, title = nil)
    title ||= column_name.titleize
    direction = params[:sort] == column_name && params[:direction] == "asc" ? "desc" : "asc"
    link_to title, :sort => column_name, :direction => direction
  end
end
