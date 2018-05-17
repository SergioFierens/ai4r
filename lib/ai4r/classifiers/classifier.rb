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
  module Classifiers
  
    # This class defines a common API for classifiers.
    # All methods in this class must be implemented in subclasses.
    class Classifier

      include Ai4r::Data::Parameterizable  
    
      # Build a new classifier, using data examples found in data_set.
      # The last attribute of each item is considered as the
      # item class.
      def build(data_set)
        raise NotImplementedError
      end
      
      # You can evaluate new data, predicting its class.
      # e.g.
      #   classifier.eval(['New York',  '<30', 'F'])  # => 'Y'
      def eval(data)
        raise NotImplementedError
      end
      
      # This method returns the generated rules in ruby code.
      # e.g.
      #   
      #   classifier.get_rules
      #     # =>  if age_range=='<30' then marketing_target='Y'
      #           elsif age_range=='[30-50)' and city=='Chicago' then marketing_target='Y'
      #           elsif age_range=='[30-50)' and city=='New York' then marketing_target='N'
      #           elsif age_range=='[50-80]' then marketing_target='N'
      #           elsif age_range=='>80' then marketing_target='Y'
      #           else raise 'There was not enough information during training to do a proper induction for this data element' end
      #
      # It is a nice way to inspect induction results, and also to execute them:  
      #     age_range = '<30'
      #     city='New York'
      #     marketing_target = nil
      #     eval classifier.get_rules   
      #     puts marketing_target
      #       # =>  'Y'
      #
      # Note, however, that not all classifiers are able to produce rules.
      # This method is not implemented in such classifiers.
      def get_rules
        raise NotImplementedError
      end
      
    end
  end
end
