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
    org_data = []
    standard_fields = { :organization => { :name => "Utah" }, :description => "", :org_type => "governmental", :catalog_url => "http://www.utah.gov/data/" }
    org_data << { :name => "Department of Workforce Services", :url => "http://jobs.utah.gov/",:home_url => "http://jobs.utah.gov/" }.merge(standard_fields)
    org_data << { :name => "Governor's Office of Planning and Budget", :url => "http://governor.utah.gov/gopb/", :home_url => "http://governor.utah.gov/gopb/" }.merge(standard_fields)
    org_data << { :name => "Utah Geological Survey", :url => "http://geology.utah.gov/", :home_url => "http://geology.utah.gov/" }.merge(standard_fields)
    org_data << { :name => "Utah Department of Health", :url => "http://health.utah.gov/", :home_url => "http://health.utah.gov/" }.merge(standard_fields)
    org_data << { :name => "Utah 911 Committee", :url => "http://e911.utah.gov/", :home_url => "http://e911.utah.gov/" }.merge(standard_fields)
    org_data << { :name => "MesoWest", :url => "http://mesowest.utah.edu/", :home_url => "http://mesowest.utah.edu/" }.merge(standard_fields)
    org_data << { :name => "Weber County, Utah", :url => "http://weber.ut.us/", :home_url => "http://weber.ut.us/" }.merge(standard_fields)
    org_data
  end
  
end