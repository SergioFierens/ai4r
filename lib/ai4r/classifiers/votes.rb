# frozen_string_literal: true

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
    # Utility class to count votes from ensemble classifiers.
    class Votes
      # @return [Object]
      def initialize
        self.tally_sheet = Hash.new(0)
      end

      # @param category [Object]
      # @return [Object]
      def increment_category(category)
        tally_sheet[category] += 1
      end

      # @param category [Object]
      # @return [Object]
      def tally_for(category)
        tally_sheet[category]
      end

      # @param tie_break [Object]
      # @return [Object]
      def get_winner(tie_break = :last, rng: Random.new)
        n = 0 # used to create a stable sort of the tallys
        sorted_sheet = tally_sheet.sort_by do |_, score|
          n += 1
          [score, n]
        end
        return nil if sorted_sheet.empty?

        if tie_break == :random
          max_score = sorted_sheet.last[1]
          tied = sorted_sheet.select { |_, score| score == max_score }.map(&:first)
          tied.sample(random: rng)
        else
          sorted_sheet.last.first
        end
      end

      private

      attr_accessor :tally_sheet
    end
  end
end
