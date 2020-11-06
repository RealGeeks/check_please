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

### Terminology

CheckPlease uses a few words in a jargony way:

* **Reference** is always used to refer to the "target" or "source of truth."
  We assume you're comparing two things because you want one of them to be like
  the other; the **reference** is what you're aiming for.
* **Candidate** is always used to refer to some JSON you'd like to compare
  against the **reference**.  __(We could've also used "sample," but it turns
  out that "reference" and "candidate" are the same length, which makes code
  line up neatly in a monospaced font...)__
* A **diff** is what CheckPlease calls an individual discrepancy between the
  **reference** and the **candidate**.  More on this in "Understanding the Output",
  below.

### CLI

Use the `bin/check_please` executable.  (To get started, run it with the '-h' flag.)

### From Within Ruby

Create two JSON strings and pass them to `CheckPlease.render_diff`.  You'll get
back a third string containing a nicely formatted report of all the differences
CheckPlease found in the two JSON strings.  (See also:  [./usage_examples.rb](usage_examples.rb).)

(You can also parse the JSON strings yourself and pass the resulting data
structures in, if you're into that.  I mean, I wrote this to help compare JSON
data that's too big and complicated to scan through visually, but you do you!

### Understanding the Output

CheckPlease follows the Unix philosophy of "no news is good news".  If your
**candidate** matches your **reference**, you'll get an empty message.

But let's be honest:  how often is that going to happen?  No, you're using this
tool because you want a human-friendly summary of all the places that your
**candidate** fell short.

When CheckPlease compares your two samples, it generates a list of diffs to
describe any discrepancies it encounters.  (By default, it prints that list in a
tabular format, but if you want to incorporate this into another toolchain,
CheckPlease can also print these diffs as JSON to facilitate parsing.)

An example would probably help here.

__(NOTE: these examples may fall out of date with the code.  They're swiped
from [the CLI integration spec](spec/cli_integration_spec.rb), so please
consider that more authoritative than this README.  If you do spot a
difference, please feel free to open an issue!)__

Given the following **reference** JSON:
```
{
  "id": 42,
  "name": "The Answer",
  "words": [ "what", "do", "you", "get", "when", "you", "multiply", "six", "by", "nine" ],
  "meta": { "foo": "spam", "bar": "eggs", "yak": "bacon" }
}
```

And the following **candidate** JSON:
```
{
  "id": 42,
  "name": [ "I am large, and contain multitudes." ],
  "words": [ "what", "do", "we", "get", "when", "I", "multiply", "six", "by", "nine", "dude" ],
  "meta": { "foo": "foo", "yak": "bacon" }
}
```

CheckPlease should produce the following output:

```
TYPE          | PATH      | REFERENCE  | CANDIDATE
--------------|-----------|------------|-------------------------------
type_mismatch | /name     | The Answer | ["I am large, and contain m...
mismatch      | /words/3  | you        | we
mismatch      | /words/6  | you        | I
extra         | /words/11 |            | dude
missing       | /meta/bar | eggs       |
mismatch      | /meta/foo | spam       | foo
```

Let's start with the leftmost column...

#### Diff Types

The above example is intended to illustrate every possible type of diff that
CheckPlease defines:

* **type_mismatch** means that both the **reference** and the **candidate** had
  a value at the given path, but one value was an Array or a Hash and the other
  was not.  **When CheckPlease encounters a type mismatch, it does not compare
  anything "below" the given path.** producing a lot of "garbage" diffs.
  __(Technical note:  CheckPlease uses a "recursive descent" strategy to
  traverse the **reference** data structure, and it stops when it encounters a
  type mismatch in order to avoid producing a lot of "garbage" diff output.
  Also, the way these get displayed is likely to change.)__
* **mismatch** means that both the **reference** and the **candidate** had a
  value at the given path, and neither value was an Array or a Hash.
* "**extra**" means that, inside an Array or a Hash, the **candidate**
  contained values that were not found in the **reference**.
* "**missing**" is the opposite of **extra**:  inside an Array or a Hash, the
  **reference** contained values that were not found in the **candidate**.

#### Paths

The second column contains a path expression.  This is extremely basic:

* The first element in the data structure is defined as "/".
* If an element in the data structure is an array, its child elements will have
  a **one-based** index appended to their parent's path.
* If an element in the data structure is an object ("Hash" in Ruby), the key
  for each element will be appended to their parent's path, and the values will
  be compared.

__**Being primarily a Ruby developer, I'm quite ignorant of conventions in the
JS community; if there's an existing convention for paths, please open an
issue!**__

## TODO

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
