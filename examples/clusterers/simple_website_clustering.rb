require File.dirname(__FILE__) + '/google_search'
require File.dirname(__FILE__) + '/build_keywords'
require File.dirname(__FILE__) + '/../../lib/ai4r/clusterers/average_linkage'
require 'rubygems'
require 'hpricot'
require 'net/http'
require 'benchmark'

SITES_TO_CLASSIFY = [
  "www.foxnews.com", "www.usatoday.com", "scm.jadeferret.com",
  "www.accurev.com", "www.lastminute.com", "subversion.tigris.org",
  "news.yahoo.com", "news.bbc.co.uk", "www.orbitz.com"
]
  
# Return array of keywords for the site
def get_keywords(site)
  response = Net::HTTP.get_response(site, "/")
  Hpricot(response.body).
    search("meta[@name='keywords']")[0]. #Select meta keywords element
    attributes["content"].               #Select its content
    split(",").                          #Keywords are coma separated
    collect{ |k| k.strip.downcase }      #Remove start and end white spaces
end

# Get keywords data for each website
Site = Struct.new("Site", :name, :keywords)
sites = SITES_TO_CLASSIFY.collect do |site_name|
  Site.new(site_name, get_keywords(site_name))
end
data_set = Ai4r::Data::DataSet.new(:data_items => sites, 
  :data_labels => Site.members)

# The distance between sites depends on the keywords collected from internet 
keywords_distance_function = lambda do |x,y| 
  return Ai4r::Data::Proximity.simple_matching(x.keyword, y.keywords)
end

# Create the clusters
clusterer = Ai4r::Clusterers::AverageLinkage.new
clusterer.distance_function = keywords_distance_function
clusterer.build(data_set, 3)

# Print results
clusterer.clusters.each do |cluster|
  puts cluster.data_items.collect {|item| item.name}.join(", ")
  puts "============"
end
