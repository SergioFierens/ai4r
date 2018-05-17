# Author::    Will Warner
# License::   MPL 1.1
# Project::   ai4r
# Url::       https://github.com/SergioFierens/ai4r
#
# You can redistribute it and/or modify it under the terms of 
# the Mozilla Public License version 1.1  as published by the 
# Mozilla Foundation at http://www.mozilla.org/MPL/MPL-1.1.txt

module Ai4r
  module Classifiers
    class Votes

      def initialize
        self.tally_sheet = Hash.new(0)
      end

      def increment_category(category)
        tally_sheet[category] += 1
      end

      def tally_for(category)
        tally_sheet[category]
      end

      def get_winner
        n = 0 # used to create a stable sort of the tallys
        sorted_sheet = tally_sheet.sort_by { |_, score| n += 1; [score, n] }
        sorted_sheet.last.first
      end

      private

      attr_accessor :tally_sheet
    end
  end
end

