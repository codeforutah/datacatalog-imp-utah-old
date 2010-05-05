require File.dirname(__FILE__) + '/output'

class AgencyLookup

  def self.read
    filename = Output.absolute_path('../config/agency_lookup.yml')
    raise "Could not find agency_lookup.yml" unless File.exist?(filename)
    YAML::load_file(filename)
  end

end
