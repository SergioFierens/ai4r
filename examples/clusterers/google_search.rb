require 'rubygems'
require 'hpricot'
require 'net/http'

WORDS_TO_IGNORE = %w(a all am an and any are as at be but can did do does for
  from had has have here how i if in is it no not of on or so that the then
  there this to too up use what when where who why you by | - was with s ) << ""

def search_google(query, start)
  query.gsub!(/\s/, "%20")
  query_url = "/search?q=#{query}&btnG=Google+Search&start=#{start}"
  response = Net::HTTP.get_response('www.google.com', query_url)
  doc = Hpricot(response.body)
  doc.search("span[@class='gl']").remove  #Remove "Cached" "Similiar cites" links
  doc.search("cite").remove #Remove site url
  search_results = doc.search("//li[@class='g']") #Get individual results
  results = []
  search_results.each do |search_result|
    title = search_result.search("h3 a").text
    description = search_result.search("div[@class='s']").text
    results << {:title => title, :description => description}
  end
  return results
end

def parse_keywords(text, query)
  text.
    split(/[\s,;:\.\(\)\[\]\?\']/).     #Split words
    collect {|token| token.downcase}.  #Everything in lower case
    select {|token| not WORDS_TO_IGNORE.include? token.downcase} # filter common
end
