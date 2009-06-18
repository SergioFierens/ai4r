# Author::    Thomas Kern
# License::   MPL 1.1
# Project::   ai4r
# Url::       http://ai4r.rubyforge.org/
#
# You can redistribute it and/or modify it under the terms of
# the Mozilla Public License version 1.1  as published by the
# Mozilla Foundation at http://www.mozilla.org/MPL/MPL-1.1.txt

module Ai4r
  module Data

    #stores the instance of the data entry
    #the data is accessible via entries
    #stores the class-column in the attribute klass and
    #removes the column for the class-entry

    class DataEntry
      attr_accessor :klass, :entries

      def initialize(item, klass_index)
        @klass = item[klass_index]
        item.delete_at klass_index unless klass_index.nil?
        @entries = item
      end

      # wrapper method for the access to @entries
      def [](index)
        @entries[index]
      end
    end
  end
end

