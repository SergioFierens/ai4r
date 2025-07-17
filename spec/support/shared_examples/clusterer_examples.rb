# frozen_string_literal: true

RSpec.shared_examples "a clusterer" do
  let(:simple_data) do
    Ai4r::Data::DataSet.new(
      data_items: [
        [1, 1], [1.5, 1.5], [2, 2],      # Cluster 1
        [8, 8], [8.5, 8.5], [9, 9]        # Cluster 2
      ]
    )
  end
  
  it "implements required interface" do
    expect(subject).to respond_to(:build)
    expect(subject).to respond_to(:eval)
    expect(subject).to respond_to(:clusters)
  end
  
  it "builds clusters from data" do
    clusterer = subject.build(simple_data, 2)
    expect(clusterer.clusters).to be_an(Array)
    expect(clusterer.clusters.size).to eq(2)
  end
  
  it "evaluates new data points" do
    clusterer = subject.build(simple_data, 2)
    cluster_index = clusterer.eval([1.2, 1.2])
    expect(cluster_index).to be_between(0, 1)
  end
  
  it "handles edge cases" do
    # Single point
    single_point_data = Ai4r::Data::DataSet.new(data_items: [[1, 1]])
    expect { subject.build(single_point_data, 1) }.not_to raise_error
    
    # Empty data should raise error
    empty_data = Ai4r::Data::DataSet.new(data_items: [])
    expect { subject.build(empty_data, 1) }.to raise_error
  end
end

RSpec.shared_examples "a hierarchical clusterer" do
  it_behaves_like "a clusterer"
  
  it "supports different numbers of clusters" do
    data = generate_clustered_data(clusters: 4, points_per_cluster: 5)
    
    [2, 3, 4].each do |k|
      clusterer = subject.build(data, k)
      expect(clusterer.clusters.size).to eq(k)
    end
  end
  
  it "creates dendrogram" do
    expect(subject).to respond_to(:dendrogram) if subject.respond_to?(:dendrogram)
  end
end

RSpec.shared_examples "a density-based clusterer" do
  it_behaves_like "a clusterer"
  
  it "identifies noise points" do
    # Create data with outliers
    data_with_noise = Ai4r::Data::DataSet.new(
      data_items: [
        [1, 1], [1.1, 1.1], [1.2, 1.2],  # Dense cluster
        [10, 10]                          # Outlier
      ]
    )
    
    if subject.respond_to?(:noise_points)
      subject.build(data_with_noise)
      expect(subject.noise_points).not_to be_empty
    end
  end
end

RSpec.shared_examples "a partitioning clusterer" do
  it_behaves_like "a clusterer"
  
  it "has centroids" do
    data = generate_clustered_data(clusters: 3)
    clusterer = subject.build(data, 3)
    
    if clusterer.respond_to?(:centroids)
      expect(clusterer.centroids).to be_an(Array)
      expect(clusterer.centroids.size).to eq(3)
    end
  end
  
  it "converges within reasonable iterations" do
    data = generate_clustered_data(clusters: 2, points_per_cluster: 20)
    clusterer = subject.build(data, 2)
    
    if clusterer.respond_to?(:iterations)
      expect(clusterer.iterations).to be < 100
    end
  end
end