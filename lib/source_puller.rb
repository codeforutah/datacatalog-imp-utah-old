require File.dirname(__FILE__) + '/agency_lookup'

class SourcePuller

  U = DataCatalog::ImporterFramework::Utility

  def initialize
    @agency_lookup = AgencyLookup.read
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
      hash[:catalog_name] = "utah.gov"
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
        if value
          hash[:downloads] << {
            :url    => value,
            :format => key.to_s
          }
        end
      end
      
      org_url = downloads.values.compact!.first
      org_name, org_url = org_from_url(org_url)
      hash[:organization] = {
        :name     => org_name,
        :home_url => org_url
      }
      
      utah_data << hash
    end
    utah_data
  end

  def org_from_url(url)
    @agency_lookup.each do |item|
      if Regexp.new(item['match']) =~ url
        return [item['name'], item['url']]
      end
    end
    puts "No match for #{url} - using default."
    ["Utah", "http://www.utah.gov"]
  end

  def extract_href(nodes, i)
    a_tag = nodes[i].css("a").first
    if a_tag
      U.normalize_url(U.single_line_clean(a_tag["href"]))
    else
      nil
    end
  end

end