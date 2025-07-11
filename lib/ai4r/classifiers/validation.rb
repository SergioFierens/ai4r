module Ai4r
  module Classifiers
    # Utility helpers for classifier evaluation.
    module Validation
      module_function

      # Split a data set into a training and test set. `test_ratio` specifies the
      # proportion of items to place in the test set.
      def train_test_split(data_set, test_ratio = 0.3, shuffle: true)
        items = data_set.data_items.dup
        items.shuffle! if shuffle
        test_size = (items.length * test_ratio).round
        test_items = items.slice(0, test_size)
        train_items = items.slice(test_size, items.length - test_size)
        [
          Ai4r::Data::DataSet.new(data_items: train_items, data_labels: data_set.data_labels),
          Ai4r::Data::DataSet.new(data_items: test_items,  data_labels: data_set.data_labels)
        ]
      end

      # Divide a data set into +k+ folds for cross validation.
      def k_folds(data_set, k, shuffle: true)
        items = data_set.data_items.dup
        items.shuffle! if shuffle
        base = items.length / k
        rem = items.length % k
        sizes = Array.new(k, base)
        rem.times { |i| sizes[i] += 1 }
        folds = []
        idx = 0
        sizes.each do |s|
          folds << Ai4r::Data::DataSet.new(
            data_items: items.slice(idx, s),
            data_labels: data_set.data_labels
          )
          idx += s
        end
        folds
      end

      # Perform k-fold cross validation. The +classifier_klass+ should be a class
      # implementing the Classifier API. Optional +params+ will be passed to
      # +set_parameters+ when available.
      # Returns an array with the accuracy for each fold.
      def evaluate_k_fold(classifier_klass, data_set, k, params = {})
        folds = k_folds(data_set, k)
        folds.each_index.map do |i|
          test_set = folds[i]
          train_items = []
          folds.each_index do |j|
            train_items.concat(folds[j].data_items) unless j == i
          end
          train_set = Ai4r::Data::DataSet.new(
            data_items: train_items,
            data_labels: data_set.data_labels
          )
          classifier = classifier_klass.new
          classifier.set_parameters(params) if params && classifier.respond_to?(:set_parameters)
          classifier.build(train_set)
          correct = test_set.data_items.count do |item|
            classifier.eval(item[0..-2]) == item.last
          rescue Ai4r::Classifiers::ModelFailureError
            false
          end
          correct.to_f / test_set.data_items.length
        end
      end
    end
  end
end
