# Author::    Sergio Fierens (implementation)
# License::   MPL 1.1
# Project::   ai4r
# Url::       http://www.ai4r.org/
#
# You can redistribute it and/or modify it under the terms of 
# the Mozilla Public License version 1.1  as published by the 
# Mozilla Foundation at http://www.mozilla.org/MPL/MPL-1.1.txt

# In this example we group results from a post-training survey into 4 groups.
# The Diana algorithm is used, but you can try other algorithms by changing 
# the word "Diana" by "KMeans", "AverageLinkage", or any other cluster implementation.
# The cluster API is the same, so you can play around and observe different results.

require 'rubygems'
require 'ai4r'
include Ai4r::Data
include Ai4r::Clusterers

# 5 Questions on a post training survey
questions = [	"The material covered was appropriate for someone with my level of knowledge of the subject.", 
				"The material was presented in a clear and logical fashion", 
				"There was sufficient time in the session to cover the material that was presented", 
				"The instructor was respectful of students", 
				"The instructor provided good examples"]

# Answers to each question go from 1 (bad) to 5 (excellent)
# The answers array has an element per survey complemented. 
# Each survey completed is in turn an array with the answer of each question.
answers = [	[ 1, 2, 3, 2, 2],	# Answers of person 1
		[ 5, 5, 3, 2, 2],	# Answers of person 2
		[ 1, 2, 3, 2, 2],	# Answers of person 3
		[ 1, 2, 2, 2, 2],	# ...
		[ 1, 2, 5, 5, 2],
		[ 3, 3, 3, 3, 3],
		[ 1, 2, 3, 2, 2],
		[ 3, 2, 3, 5, 5],
		[ 3, 3, 3, 5, 2],
		[ 4, 4, 3, 1, 1],
		[ 5, 5, 5, 5, 5],
		[ 4, 2, 4, 2, 1],
		[ 4, 4, 5, 5, 5],
		[ 4, 4, 3, 2, 2],
		[ 2, 2, 3, 2, 3],
		[ 3, 3, 3, 1, 1]]	# Answers of person 16

data_set = DataSet.new(:data_items => answers, :data_labels => questions)

# Let's group answers in 4 groups
clusterer = Diana.new.build(data_set, 4)

clusterer.clusters.each_with_index do |cluster, index| 
	puts "Group #{index+1}"
	p cluster.data_items
end

