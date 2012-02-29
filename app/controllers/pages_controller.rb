# This serves up the general introductory pages
class PagesController < ApplicationController
# The home page, which a brief introduction to the site and the tutorial or instructional pages
  def home
  end

# The status page, which probably doesn't actually need any content.
  def status
  end

# This page contains information for contacting the developer(s) and for contributing to the metriculator project.
  def contact
  end
  
# This page hosts an introduction to the beanplots and examples of the way they can help identify problems.
  def beanplot
  end

  def app_config
    @hash = AppConfig
  end

  def qc_config
    @hash = QcConfig
  end

end
