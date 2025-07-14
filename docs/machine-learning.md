# Machine Learning with ID3 Decision Trees in Ruby

## Introduction to ID3 algorithm

AI4R implements the ID3 algorithm (Quinlan) as one of its automatic classifiers. Given a set of preclassified examples, it builds a top-down induction of decision tree, biased by the information gain and entropy measure.

The good thing about this automatic learning method is that humans learn as well. Unlike other AI techniques like neural networks, classifiers can generate ruby code with if / else sentences. You can use this to evaluate parameters on realtime, copy paste them in a code, or just read them to learn about your problem domain.

## Marketing target strategy example using ID3 Decision Trees in Ruby

Let's suppose that you are writing an application that must identify people as relevant marketing targets or not. The only information that you have is a collection of examples, provided by a marketing survey:

```ruby
DATA_LABELS = [ 'city', 'age_range', 'gender', 'marketing_target'  ]

DATA_SET = [  
  ['New York',  '<30',      'M',  'Y'],
  ['Chicago',   '<30',      'M',  'Y'],
  ['Chicago',   '<30',      'F',  'Y'],
  ['New York',  '<30',      'M',  'Y'],
  ['New York',  '<30',      'M',  'Y'],
  ['Chicago',   '[30-50)',  'M',  'Y'],
  ['New York',  '[30-50)',  'F',  'N'],
  ['Chicago',   '[30-50)',  'F',  'Y'],
  ['New York',  '[30-50)',  'F',  'N'],
  ['Chicago',   '[50-80]',  'M',  'N'],
  ['New York',  '[50-80]',  'F',  'N'],
  ['New York',  '[50-80]',  'M',  'N'],
  ['Chicago',   '[50-80]',  'M',  'N'],
  ['New York',  '[50-80]',  'F',  'N'],
  ['Chicago',   '>80',      'F',  'Y']
]
```

You can create an ID3 Decision tree to do the dirty job for you:

```ruby
id3 = ID3.new(DATA_SET, DATA_LABELS)
```

The Decision tree will automatically create the "rules" to parse new data, and identify new possible marketing targets:

```ruby
id3.get_rules
  # =>  if age_range=='<30' then marketing_target='Y'
        elsif age_range=='[30-50)' and city=='Chicago' then marketing_target='Y'
        elsif age_range=='[30-50)' and city=='New York' then marketing_target='N'
        elsif age_range=='[50-80]' then marketing_target='N'
        elsif age_range=='>80' then marketing_target='Y'
        else raise 'There was not enough information during training to do a proper induction for this data element' end

id3.eval(['New York', '<30', 'M'])
  # =>  'Y'
```

## Better data loading

In real life you will use many more data training examples, with more attributes. Consider moving your data to an external CSV (comma separated values) file.

```ruby
data_set = []
CSV::Reader.parse(File.open("#{File.dirname(__FILE__)}/data_set.csv", 'r')) do |row|
  data_set << row
end
data_labels = data_set.shift

id3 = ID3.new(data_set, data_labels)
```

## A good tip for data evaluation

The ID3 class provides a method to evaluate new data.

```ruby
id3.eval(['New York', '<30', 'M'])
  # =>  'Y'
```

But instead of going through the tree every time, you can take advantage of the fact that the method "get_rules" generates proper ruby code!

```ruby
id3 = ID3.new(DATA_SET, DATA_LABELS)
age_range = '<30'
city = 'New York'
gender = 'M'
marketing_target = nil
eval id3.get_rules
puts marketing_target
  # =>  'Y'
```

## More about ID3 and decision trees

- [Wikipedia article on Decision trees](http://en.wikipedia.org/wiki/Decision_tree)
- [Wikipedia article on ID3 Algorithm](http://en.wikipedia.org/wiki/ID3_algorithm)