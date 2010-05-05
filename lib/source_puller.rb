class SourcePuller

  U = DataCatalog::ImporterFramework::Utility

  def initialize
    source_data = build_sources
    @source_iterator = source_data.each
  end
  
  def fetch
    @source_iterator.next
  rescue StopIteration
    return nil    
  end
    
  protected

  def build_sources
    doc = U.parse_html_from_uri('http://www.utah.gov/data/state_data_files.html')
    utah_data = []
    data_rows = doc.css('div#main table tr')
    data_rows.delete(data_rows.first) # remove the row of headings
    i = 0
    data_rows.each do |row|
      i += 1
      hash = {}
      tds = row.children.reject { |c| c.name == 'text' }
      hash[:title]        = U.single_line_clean(tds[0].text)
      hash[:description]  = U.single_line_clean(tds[1].text)
      hash[:catalog_name] = "Utah.gov"
      hash[:catalog_url]  = "http://www.utah.gov/data/"
      hash[:frequency]    = "unknown"
      hash[:source_type]  = "dataset"
      hash[:url]          = "http://www.utah.gov/data/state_data_files.html?=" + i.to_s
      
      downloads = {}
      downloads[:csv] = extract_href(tds, 2)
      downloads[:xls] = extract_href(tds, 3)
      downloads[:xml] = extract_href(tds, 4)
      downloads[:kml] = extract_href(tds, 5)
      
      hash[:downloads] = []
      downloads.each do |key, value|
        unless value == ''
          hash[:downloads] << {
            :url    => value,
            :format => key.to_s
          }
        end
      end
      
      org_name, org_url = agency_from_url(downloads.values.compact!.first)
      hash[:organization] = {
        :name     => org_name,
        :home_url => org_url
      }
      
      utah_data << hash
    end
    utah_data
  end

  def agency_from_url(url)
    case url
    when /jobs\.utah\.gov/
      ["Department of Workforce Services","http://jobs.utah.gov/"]
    when /governor\.utah\.gov\/dea/
      ["Governor's Office of Planning and Budget","http://governor.utah.gov/gopb/"]
    when /geology\.utah\.gov/
      ["Utah Geological Survey","http://geology.utah.gov/"]
    when /health\.utah\.gov/
      ["Utah Department of Health","http://health.utah.gov/"]
    when /e911\.utah\.gov/
      ["Utah 911 Committee","http://e911.utah.gov/"]
    when /mesowest/
      ["MesoWest","http://mesowest.utah.edu/" ]
    when /weber\.ut\.us/
      ["Weber County, Utah","http://weber.ut.us/"]
    else
      ["Utah","http://www.utah.gov/"]
    end
  end

  def extract_href(nodes, i)
    a_tag = nodes[i].css("a").first
    if a_tag
      U.normalize_url(U.single_line_clean(a_tag["href"]))
    else
      ""
    end
  end

end