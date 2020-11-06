# check_please

Check for differences between two JSON strings (or Ruby data structures parsed from them).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'check_please'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install check_please

## Usage

### CLI

Use the `bin/check_please` executable.  (To get started, run it with the '-h' flag.)

### From Within Ruby

Create two JSON strings and pass them to `CheckPlease.render_diff`.  You'll get
back a third string containing a nicely formatted report of all the differences
CheckPlease found in the two JSON strings.  (See also:  ./usage_examples.rb.)

(You can also parse the JSON strings yourself and pass the resulting data
structures in, if you're into that.  I mean, I wrote this to help compare JSON
data that's too big and complicated to scan through visually, but you do you!

## TODO

* rspec custom matcher (separate gem?)
* command line flags for :allthethings:!
  * --fail-fast
  * limit to first N
  * sort by path?
  * max depth (for iterative refinement?)
* detect timestamps and compare after parsing?
  * ignore sub-second precision (option / CLI flag)?
  * possibly support plugins for other folks to add custom coercions?
* support expressions of specific paths to ignore
  * wildcards?  `#` for indexes, `**` to match one or more path segments?
    (This could get ugly fast.)
* display filters?  (e.g., { a: 1, b: 2 } ==> "Hash#3")
  * shorter descriptions of values with different classes
    (but maybe just the existing :type_mismatch diffs?)
  * another "possibly support plugins" expansion point here
* more output formats, maybe?

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run
`rake spec` to run the tests. You can also run `bin/console` for an interactive
prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To
release a new version, update the version number in `version.rb`, and then run
`bundle exec rake release`, which will create a git tag for the version, push
git commits and tags, and push the `.gem` file to
[rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at
https://github.com/[USERNAME]/check_please. This project is intended to be a
safe, welcoming space for collaboration, and contributors are expected to
adhere to the [code of
conduct](https://github.com/[USERNAME]/check_please/blob/master/CODE_OF_CONDUCT.md).


## License

The gem is available as open source under the terms of the [MIT
License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the CheckPlease project's codebases, issue trackers,
chat rooms and mailing lists is expected to follow the [code of
conduct](https://github.com/[USERNAME]/check_please/blob/master/CODE_OF_CONDUCT.md).
