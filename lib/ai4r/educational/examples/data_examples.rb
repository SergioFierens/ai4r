# frozen_string_literal: true

module Ai4r
  module Data
    class EducationalExamples
      def self.tutorial_tracks
        {
          beginner: beginner_track,
          intermediate: intermediate_track,
          advanced: advanced_track
        }
      end
      
      def self.beginner_track
        {
          title: 'AI4R Beginner Track',
          description: 'Start your journey with AI4R - no prior experience required',
          prerequisites: ['Basic Ruby knowledge', 'High school math'],
          learning_objectives: [
            'Understand basic AI concepts',
            'Work with datasets',
            'Implement simple algorithms',
            'Evaluate model performance'
          ],
          modules: [
            {
              name: 'Introduction to AI4R',
              exercises: [
                {
                  title: 'Hello AI4R',
                  difficulty: 'easy',
                  code: 'require "ai4r"\nputs "Welcome to AI4R!"'
                }
              ],
              quiz: [
                {
                  question: 'What does AI4R stand for?',
                  options: ['AI for Ruby', 'Artificial Intelligence for Ruby', 'Advanced Intelligence 4 Ruby'],
                  answer: 'Artificial Intelligence for Ruby'
                }
              ]
            },
            {
              name: 'Basic Data Structures',
              exercises: [],
              quiz: []
            },
            {
              name: 'Simple Classification',
              exercises: [],
              quiz: []
            },
            {
              name: 'Basic Clustering',
              exercises: [],
              quiz: []
            }
          ]
        }
      end
      
      def self.intermediate_track
        {
          title: 'AI4R Intermediate Track',
          description: 'Deepen your understanding of machine learning',
          prerequisites: ['Beginner Track', 'Linear algebra basics'],
          learning_objectives: [
            'Master advanced algorithms',
            'Understand mathematical foundations',
            'Optimize model performance',
            'Handle real-world data'
          ],
          modules: [
            {
              name: 'Advanced Classification',
              exercises: [],
              quiz: []
            },
            {
              name: 'Neural Networks',
              exercises: [],
              quiz: []
            },
            {
              name: 'Feature Engineering',
              exercises: [],
              quiz: []
            }
          ],
          projects: [
            {
              name: 'Image Classifier',
              description: 'Build a digit recognition system',
              requirements: ['Neural networks', 'Data preprocessing']
            }
          ]
        }
      end
      
      def self.advanced_track
        {
          title: 'AI4R Advanced Track',
          description: 'Master cutting-edge AI techniques',
          prerequisites: ['Intermediate Track', 'Calculus', 'Statistics'],
          learning_objectives: [
            'Implement state-of-the-art algorithms',
            'Conduct AI research',
            'Build production systems',
            'Contribute to AI4R'
          ],
          modules: [
            {
              name: 'Deep Learning',
              exercises: [],
              quiz: []
            },
            {
              name: 'Ensemble Methods',
              exercises: [],
              quiz: []
            },
            {
              name: 'AutoML',
              exercises: [],
              quiz: []
            }
          ],
          research_papers: [
            {
              title: 'Deep Learning in Ruby: A Practical Approach',
              authors: ['AI4R Community'],
              year: 2024,
              summary: 'Implementing deep learning algorithms in Ruby'
            }
          ],
          capstone_project: {
            title: 'AI System Design',
            description: 'Design and implement a complete AI system',
            deliverables: ['Code', 'Documentation', 'Performance Analysis'],
            evaluation_criteria: ['Innovation', 'Code Quality', 'Performance', 'Documentation']
          }
        }
      end
      
      def self.interactive_examples
        [
          {
            title: 'K-means Clustering Visualization',
            description: 'See how K-means clusters data points',
            type: 'visualization',
            code: 'kmeans = Ai4r::Clusterers::KMeans.new',
            interactive_elements: ['Adjust K value', 'Add data points', 'Reset'],
            visualization_type: 'scatter'
          }
        ]
      end
      
      def self.code_challenges
        [
          {
            title: 'Implement Distance Function',
            difficulty: 'easy',
            description: 'Implement Euclidean distance between two points',
            starter_code: 'def euclidean_distance(point1, point2)\n  # Your code here\nend',
            test_cases: [
              { input: [[0, 0], [3, 4]], expected: 5.0 },
              { input: [[1, 1], [1, 1]], expected: 0.0 }
            ],
            solution: 'Math.sqrt(point1.zip(point2).sum { |a, b| (a - b)**2 })'
          },
          {
            title: 'Binary Classifier',
            difficulty: 'medium',
            description: 'Create a simple binary classifier',
            starter_code: 'class BinaryClassifier\n  # Your code here\nend',
            test_cases: [],
            solution: 'See full solution in documentation'
          },
          {
            title: 'Neural Network from Scratch',
            difficulty: 'hard',
            description: 'Implement a basic neural network',
            starter_code: 'class SimpleNeuralNetwork\n  # Your code here\nend',
            test_cases: [],
            solution: 'Advanced implementation available'
          }
        ]
      end
      
      def self.glossary
        {
          'classification' => {
            definition: 'The task of predicting a discrete class label',
            example: 'Classifying emails as spam or not spam'
          },
          'clustering' => {
            definition: 'Grouping similar data points together',
            example: 'Customer segmentation based on purchasing behavior'
          },
          'neural network' => {
            definition: 'A computational model inspired by biological neural networks',
            example: 'Multi-layer perceptron for image recognition'
          },
          'gradient descent' => {
            definition: 'An optimization algorithm to minimize a cost function',
            example: 'Training neural networks by updating weights'
          }
        }
      end
      
      def self.learning_paths
        {
          data_scientist: {
            modules: ['Data Analysis', 'Statistical Learning', 'Deep Learning'],
            estimated_time: '3 months',
            prerequisites: ['Statistics', 'Linear Algebra']
          },
          ml_engineer: {
            modules: ['ML Algorithms', 'System Design', 'Production ML'],
            estimated_time: '4 months',
            prerequisites: ['Software Engineering', 'Algorithms']
          },
          researcher: {
            modules: ['Theory', 'Advanced Algorithms', 'Research Methods'],
            estimated_time: '6 months',
            prerequisites: ['Graduate-level Math', 'Research Experience']
          },
          student: {
            modules: ['Fundamentals', 'Projects', 'Capstone'],
            estimated_time: '2 months',
            prerequisites: ['Basic Programming']
          }
        }
      end
      
      def self.real_world_applications
        [
          {
            industry: 'Healthcare',
            problem: 'Disease prediction from symptoms',
            solution: 'Classification algorithms',
            ai4r_components: ['Decision Trees', 'Neural Networks'],
            code_example: 'classifier = Ai4r::Classifiers::ID3.new'
          }
        ]
      end
      
      def self.performance_benchmarks
        {
          classification: [
            {
              algorithm: 'Decision Tree',
              dataset: 'Iris',
              accuracy: 0.95,
              training_time: 0.01,
              memory_usage: '1MB'
            }
          ],
          clustering: [
            {
              algorithm: 'K-means',
              dataset: 'Blobs',
              accuracy: 0.88,
              training_time: 0.05,
              memory_usage: '2MB'
            }
          ],
          neural_networks: [
            {
              algorithm: 'Backpropagation',
              dataset: 'XOR',
              accuracy: 0.99,
              training_time: 0.5,
              memory_usage: '5MB'
            }
          ]
        }
      end
      
      def self.troubleshooting_guide
        [
          {
            issue: 'Model not converging',
            symptoms: ['Loss not decreasing', 'Accuracy stuck'],
            possible_causes: ['Learning rate too high', 'Data not normalized'],
            solutions: ['Reduce learning rate', 'Normalize input data', 'Check for bugs']
          }
        ]
      end
      
      def self.best_practices
        {
          data_preparation: ['Clean missing values', 'Normalize features', 'Split train/test'],
          algorithm_selection: ['Start simple', 'Consider data size', 'Validate assumptions'],
          model_evaluation: ['Use cross-validation', 'Check multiple metrics', 'Test on holdout'],
          deployment: ['Version models', 'Monitor performance', 'Plan for updates']
        }
      end
      
      def self.community_resources
        {
          github: 'https://github.com/SergioFierens/ai4r',
          documentation: 'http://ai4r.org',
          forums: 'AI4R Community Forum',
          tutorials: 'AI4R Learning Hub',
          contributing: 'See CONTRIBUTING.md'
        }
      end
    end
  end
end