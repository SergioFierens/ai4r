# frozen_string_literal: true

RSpec.shared_examples "a classifier" do
  let(:training_data) do
    Ai4r::Data::DataSet.new(
      data_items: [
        [1, 0], [1, 1], [0, 1], [0, 0],
        [1, 0], [1, 1], [0, 1], [0, 0]
      ],
      data_labels: ['x', 'y'],
      labels: ['A', 'A', 'B', 'B', 'A', 'A', 'B', 'B']
    )
  end
  
  it "implements required interface" do
    expect(subject).to respond_to(:build)
    expect(subject).to respond_to(:eval)
  end
  
  it "builds model from training data" do
    classifier = subject.build(training_data)
    expect(classifier).to eq(subject)  # Returns self
  end
  
  it "evaluates new instances" do
    classifier = subject.build(training_data)
    result = classifier.eval([1, 0])
    expect(['A', 'B']).to include(result)
  end
  
  it "handles edge cases" do
    # Single class data
    single_class_data = Ai4r::Data::DataSet.new(
      data_items: [[1, 0], [0, 1]],
      data_labels: ['x', 'y'],
      labels: ['A', 'A']
    )
    
    classifier = subject.build(single_class_data)
    expect(classifier.eval([0.5, 0.5])).to eq('A')
  end
end

RSpec.shared_examples "a probabilistic classifier" do
  it_behaves_like "a classifier"
  
  it "provides probability estimates" do
    if subject.respond_to?(:get_probability_map)
      classifier = subject.build(training_data)
      probs = classifier.get_probability_map([0.5, 0.5])
      
      expect(probs).to be_a(Hash)
      expect_probability_distribution(probs.values)
    end
  end
end

RSpec.shared_examples "a tree-based classifier" do
  it_behaves_like "a classifier"
  
  it "provides interpretable rules" do
    if subject.respond_to?(:get_rules)
      classifier = subject.build(training_data)
      rules = classifier.get_rules
      
      expect(rules).to be_a(String)
      expect(rules).not_to be_empty
    end
  end
  
  it "can be pruned" do
    if subject.respond_to?(:prune)
      classifier = subject.build(training_data)
      original_size = classifier.tree_size if classifier.respond_to?(:tree_size)
      
      classifier.prune(training_data)
      pruned_size = classifier.tree_size if classifier.respond_to?(:tree_size)
      
      expect(pruned_size).to be <= original_size if original_size && pruned_size
    end
  end
end

RSpec.shared_examples "a regression model" do
  let(:regression_data) do
    # y = 2x + 1 with some noise
    data_items = 20.times.map { |i| [i.to_f] }
    labels = data_items.map { |x| 2 * x[0] + 1 + rand(-0.5..0.5) }
    
    Ai4r::Data::DataSet.new(
      data_items: data_items,
      labels: labels
    )
  end
  
  it "implements required interface" do
    expect(subject).to respond_to(:build)
    expect(subject).to respond_to(:eval)
  end
  
  it "builds model from training data" do
    model = subject.build(regression_data)
    expect(model).to eq(subject)
  end
  
  it "predicts continuous values" do
    model = subject.build(regression_data)
    prediction = model.eval([10.0])
    
    expect(prediction).to be_a(Numeric)
    expect(prediction).to be_within(2.0).of(21.0)  # Should be close to 2*10 + 1
  end
  
  it "provides model parameters" do
    model = subject.build(regression_data)
    
    if model.respond_to?(:coefficients)
      expect(model.coefficients).to be_an(Array)
    end
    
    if model.respond_to?(:r_squared)
      expect(model.r_squared).to be_between(0, 1)
    end
  end
end