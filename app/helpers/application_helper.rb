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
end
