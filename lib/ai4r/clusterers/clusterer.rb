# Author::    Sergio Fierens
# License::   MPL 1.1
# Project::   ai4r
# Url::       https://github.com/SergioFierens/ai4r
#
# You can redistribute it and/or modify it under the terms of 
# the Mozilla Public License version 1.1  as published by the 
# Mozilla Foundation at http://www.mozilla.org/MPL/MPL-1.1.txt

require File.dirname(__FILE__) + '/../data/parameterizable'

module Ai4r
  module Clusterers
    
    # The purpose of this class is to define a common API for Clusterers.
    # All methods in this class (other than eval) must be implemented in 
    # subclasses. 
    class Clusterer

      include Ai4r::Data::Parameterizable
    
      # Build a new clusterer, using data examples found in data_set.
      # Data items will be clustered in "number_of_clusters" different
      # clusters.
      def build(data_set, number_of_clusters)
        raise NotImplementedError
      end
      
      # Classifies the given data item, returning the cluster it belongs to.
      def eval(data_item)
        raise NotImplementedError
      end
      
      protected    
      def get_min_index(array)
        min = array.first
        index = 0
        array.each_index do |i|
          x = array[i]
          if x < min
            min = x
            index = i
          end
        end
        return index
      end
      
    end
  end
end
