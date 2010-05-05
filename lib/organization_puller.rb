class OrganizationPuller

  def initialize
    org_data = build_orgs
    @org_iterator = org_data.each
  end
  
  def fetch
    @org_iterator.next
  rescue StopIteration
    return nil
  end
    
  protected

  def build_orgs
    AgencyLookup.read.map do |item|
      {
        :name         => item['name'],
        :url          => item['url'],
        :organization => { :name => "Utah" },
        :description  => "",
        :org_type     => "governmental",
        :catalog_url  => "http://www.utah.gov/data/"
      }
    end
  end
  
end