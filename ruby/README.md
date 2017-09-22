# YogaLayout

Gem `yoga_layout` implements a Ruby wrapper around Facebook's Yoga layout
library. Use this gem to create and lay out trees of nodes via a friendly ruby interface:

```ruby
layout = YogaLayout::Node[
  width: 500,
  height: 100,
  flex_direction: :row,
  padding: 20,
  children: [
    YogaLayout::Node[
      width: 80,
      margin_end: 20,
    ],
    YogaLayout::Node[
      height: 25,
      align_self: :center,
      flex_grow: 1,
    ]
  ],
]

layout.calculate_layout
layout.get_child(1).layout
# => { :left => 120.0, :top => 38.0, :width => 350.0, :height => 25.0, ... }
```

See [the Yoga website](https://facebook.github.io/yoga) for more information
about Yoga.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'yoga_layout'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install yoga_layout

## Usage

Create Nodes to represent views in your application.

```ruby
node = YogaLayout::Node.new
```

Update your node's style properties to set your layout's constraints.

```ruby
node.set_styles(width: 500, height: 100)
```

Note that you can create nodes with styles in a single step, using the Node literal syntax:

```ruby
node = YogaLayout::Node[width: 500, height: 100]
```

Build up a tree of nodes, then call `Node#calculate_layout` on your root node.
Yoga will set each node's `#layout` property with the calculated layout information.

```
root = YogaLayout::node[width: 500, height: 100]
image = YogaLayout::Node[width: 80, margin_end: 20]
content = YogaLayout::Node[height: 25, align_self: :center, :flex_grow: 1]

root.insert_child(image, 0).insert_child(content, 1)
root.calculate_layout

content.layout
# => { :left => 120.0, :top => 38.0, :width => 350.0, :height => 25.0, ... }
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/facebook/yoga.
