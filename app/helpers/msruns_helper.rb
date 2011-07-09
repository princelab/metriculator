module MsrunsHelper
  # generates the pagination links for MsRuns. This is super ugly, but it works.
  # Ideally this would be in a partial or something, and I should not have to pass in
  # as much data as I am doing.
  def pagination_links(msruns, current_page, per_page=8)
    num_pages = msruns.chunks(per_page).length
    num_links = num_pages > 5 ? 5 : num_pages
    if current_page.to_i > 2
      start = current_page.to_i - 3
    else
      start = 0
    end

    if current_page.to_i + 2 > num_pages
      end_index = num_pages
    else
      end_index = current_page.to_i + 2
    end

    #need a first, previous, the page numbers, next, and last link
    res = "<ul class='pagination'>"
    res += "<li class='first'>" + params_link(0, "First")
    res += "</li>"
    (start...end_index).each do |page|
      p page
      puts "page class is #{page.class}"
      res += "<li"
      res += " 'class=current'" if page == current_page
      res +=">" + params_link(page)
      res += "</li>"
    end
    res += "<li class='last'> #{params_link(num_pages - 1, "Last")}</li></ul>"
    return res
  end

  # Create a link to the correct page for pagination
  def params_link(page_num, text=nil)
    text = "#{page_num + 1}" if text == nil
    link_to text, params.merge(:sort => params[:sort], :direction => params[:direction], :page => page_num + 1)
  end
end
