require File.dirname(__FILE__) + '/../data/parameterizable'
require File.dirname(__FILE__) + '/layer'

module Ai4r

  module Som

    class Node

      include Ai4r::Data::Parameterizable
      
      parameters_info :weights => "holds the current weight",
                      :instantiated_weight => "holds the very first weight",
                      :x => "holds the row ID of the unit in the map",
                      :y => "holds the column ID of the unit in the map"

      def self.create(id,total, dimensions)
        n = Node.new
        n.instantiate_weight dimensions
        n.x = id % total
        n.y = (id / total).to_i
        n
      end

      def instantiate_weight(dimensions)
        @weights = Array.new dimensions
        @weights.each_with_index do |weight, index|
          @weights[index] = rand
        end
      end

    end

  end

end
