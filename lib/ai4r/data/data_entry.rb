# Author::    Sergio Fierens
# License::   MPL 1.1
# Project::   ai4r
# Url::       http://ai4r.rubyforge.org/
#
# You can redistribute it and/or modify it under the terms of
# the Mozilla Public License version 1.1  as published by the
# Mozilla Foundation at http://www.mozilla.org/MPL/MPL-1.1.txt

require 'csv'
require 'set'
require File.dirname(__FILE__) + '/statistics'

module Ai4r
  module Data
    class DataEntry
      attr_accessor :klass, :entries

      def initialize(item, klass_index)
        @klass = item[klass_index]
        item.delete_at klass_index
        @entries = item

      end
    end
  end
end

