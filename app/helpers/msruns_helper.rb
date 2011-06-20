module MsrunsHelper
  def pagination_links(msruns, current_page=1, per_page=8)
    num_of_pages = msruns.length

    res = "<ul>"
    (0...num_of_pages).each do |page|
      p page
      puts "page class is #{page.class}"
      res += "<li"
      res += " 'class=current'" if page == current_page
      res +=">" + link_to("#{page + 1}", params.merge(:sort => params[:sort], :direction => params[:direction], :page => page + 1))
      res += "</li>"
    end
    res += "</ul>"
    return res
  end
end
