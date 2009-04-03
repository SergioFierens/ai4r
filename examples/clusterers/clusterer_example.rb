require File.dirname(__FILE__) + '/google_search'
require File.dirname(__FILE__) + '/build_keywords'
require File.dirname(__FILE__) + '/../../lib/ai4r/clusterers/single_linkage'
require 'benchmark'

WORDS_TO_CLASSIFY = [
  "The Beattles", "Elvis Presley", "Bob Marley", "Celine Dion", "AC/DC",]
  ["Bee Gees", "Julio Iglesias", "Led Zeppelin", "Madonna", "Mariah Carey",
  "The Rolling Stones", "Julio Iglesias", "Led Zeppelin", "Madonna", "Mariah Carey",
  "Backstreet Boys", "Aerosmith", "Charles Aznavour", "Cher", "Bon Jovi",
  "Guns N' Roses", "The Jackson 5", "Lionel Richie", "Metallica", "Queen",
  "Roberto Carlos", "Rod Stewart", "U2", "The Who", "Annie Lennox",
  "Eurythmics", "Van Halen", "Ace of Base", "Alice Cooper", "Andrea Bocelli",
  "Black Sabbath", "The Beach Boys", "Barbra Streisand", "Bob Dylan", "Bryan Adams",
  "Def Leppard", "Iron Maiden", "Pearl Jam", "Nirvana", "Oasis",
  "Red Hot Chili Peppers", "Shakira", "Spice Girls", "UB40", "Village People",
  "Vicente Fernández", "Boyz II Men", "Frank Sinatra", "Bing Crosby", "Michael Jackson",
  "Tino Rossi", "The Carpenters", "George Michael", "Luciano Pavarotti", "Paul McCartney",  
  ]
  
# Search musicians in google
search_results = {}
WORDS_TO_CLASSIFY.each do |word_to_classify|
  search_results[word_to_classify] = google_search(word_to_classify, 100)
end

# Create data items with info collected from internet
Musician = Struct.new("Musician", :name, :keywords)
musicians = []
WORDS_TO_CLASSIFY.each do |word_to_classify|
  musician = Musician.new
  musician.name = word_to_classify
  musician.keywords = build_keywords(search_results[word_to_classify], 50)
  musicians << musician
end
data_set = Ai4r::Data::DataSet.new(:data_items => musicians, 
  :data_labels => ["Name", "Keywords"])

# The distance between musicians depends on the keyword collected from internet 
keywords_distance_function = lambda do |x,y| 
  distance = 0
  x.keywords.each {|keyword| distance += 1 if not y.keywords.include?(keyword)}
  return distance
end

# Create the clusters
clusterer = Air4::Clusterers::SingleLinkage.new
clusterer.distance_function = keywords_distance_function
clusterer.build(data_set, 4)

# Print results
clusterer.clusters.each do |cluster|
  cluster.data_items.collect {|item| item.name}.join(", ")
  puts "============"
end
