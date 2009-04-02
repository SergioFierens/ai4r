require 'rubygems'
require 'hpricot'
require 'net/http'

def google_search(query, results)
  search_results = []
  start = 0
  while search_results.length<results
    puts "searching #{query} #{start}" 
    search_results += get_10_google_results(query, start)
    start+=10
  end
  return search_results
end

def get_10_google_results(query, start)
  query = query.gsub(/\s/, "%20")
  query_url = "/search?q=#{query}&btnG=Google+Search&start=#{start}"
  response = Net::HTTP.get_response('www.google.com', query_url)
  doc = Hpricot(response.body)
  doc.search("span[@class='gl']").remove  #Remove "Cached" "Similiar cites" links
  doc.search("cite").remove #Remove site url
  search_results = doc.search("//li[@class='g']") #Get individual results
  return search_results.collect do |search_result|
    search_result.search("div[@class='s']").text
  end
end
