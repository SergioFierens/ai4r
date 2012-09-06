# Author::    Sergio Fierens
# License::   MPL 1.1
# Project::   ai4r
# Url::       http://www.ai4r.org/
#
# You can redistribute it and/or modify it under the terms of 
# the Mozilla Public License version 1.1  as published by the 
# Mozilla Foundation at http://www.mozilla.org/MPL/MPL-1.1.txt

require File.dirname(__FILE__) + '/../../lib/ai4r/classifiers/id3'

# Load data from data_set.csv
data_filename = "#{File.dirname(__FILE__)}/id3_data.csv"
data_set = Ai4r::Data::DataSet.new.load_csv_with_labels data_filename

# Build ID3 tree
id3 = Ai4r::Classifiers::ID3.new.build(data_set)

# Show rules
puts "Discovered rules are:"
puts id3.get_rules
puts 

# Try to predict some values
puts "Prediction samples:"
puts "['Moron Sur (GBA)','4','[86 m2 - 100 m2]'] => " + id3.eval(['Moron Sur (GBA)','4','[86 m2 - 100 m2]'])
puts "['Moron Sur (GBA)','3','[101 m2 - 125 m2]'] => " + id3.eval(['Moron Sur (GBA)','3','[101 m2 - 125 m2]'])
puts "['Recoleta (CABA)','3','[86 m2 - 100 m2]'] => " + id3.eval(['Recoleta (CABA)','3','[86 m2 - 100 m2]',])
puts "['Tigre (GBA)','3','[71 m2 - 85 m2]'] => " + id3.eval(['Tigre (GBA)','3','[71 m2 - 85 m2]',])
