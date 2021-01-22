# check_please

Check for differences between two JSON documents, YAML documents, or Ruby data
structures parsed from either of those.

<!-- start of auto-generated TOC; see https://github.com/ekalinin/github-markdown-toc -->
<!--ts-->
   * [check_please](#check_please)
      * [Installation](#installation)
      * [Terminology](#terminology)
      * [Usage](#usage)
         * [From the Terminal / Command Line Interface (CLI)](#from-the-terminal--command-line-interface-cli)
         * [From RSpec](#from-rspec)
         * [From Ruby](#from-ruby)
         * [Understanding the Output](#understanding-the-output)
            * [Diff Types](#diff-types)
            * [Paths](#paths)
            * [Output Formats](#output-formats)
         * [Flags](#flags)
            * [Setting Flags in the CLI](#setting-flags-in-the-cli)
            * [Setting Flags in Ruby](#setting-flags-in-ruby)
            * ["Reentrant" Flags](#reentrant-flags)
            * [Expanded Documentation for Specific Flags](#expanded-documentation-for-specific-flags)
               * [match_by_key](#match_by_key)
      * [TODO (maybe)](#todo-maybe)
      * [Development](#development)
      * [Contributing](#contributing)
      * [License](#license)
      * [Code of Conduct](#code-of-conduct)

<!-- Added by: sam, at: Fri Jan 22 12:08:57 PST 2021 -->

<!--te-->
<!-- end of auto-generated TOC -->

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'check_please'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install check_please

## Terminology

I know, you just want to see how to use this thing.  Feel free to scroll down,
but be aware that CheckPlease uses a few words in a jargony way:

* **Reference** is always used to refer to the "target" or "source of truth."
  We assume you're comparing two things because you want one of them to be like
  the other; the **reference** is what you're aiming for.
* **Candidate** is always used to refer to some JSON you'd like to compare
  against the **reference**.  _(We could've also used "sample," but it turns
  out that "reference" and "candidate" are the same length, which makes code
  line up neatly in a monospaced font...)_
* A **diff** is what CheckPlease calls an individual discrepancy between the
  **reference** and the **candidate**.  More on this in "Understanding the Output",
  below.

Also, even though this gem was born from a need to compare JSON documents, I'll
be talking about "hashes" instead of "objects", because I assume this will
mostly be used by Ruby developers.  Feel free to substitute "object" wherever
you see "hash" if that's easier for you.  :)

## Usage

### From the Terminal / Command Line Interface (CLI)

Use the `bin/check_please` executable.  (To get started, run it with the '-h' flag.)

Note that the executable assumes you've saved your **reference** to a file.
Once that's done, you can either save the **candidate** to a file as well if
that fits your workflow, **or** you can pipe it to `bin/check_please` in lieu
of giving it a second filename as the argument.  (This is especially useful if
you're copying an XHR response out of a web browser's dev tools and have a tool
like MacOS's `pbpaste` utility.)

### From RSpec

See [check_please_rspec_matcher](https://github.com/RealGeeks/check_please_rspec_matcher).

If you'd like more control over the output formatting, and especially if you'd
like to provide custom logic for diffing your own classes, you might be better
served by the [super_diff](https://github.com/mcmire/super_diff) gem.  Check it
out!

### From Ruby

See also: [./usage_examples.rb](usage_examples.rb).

Create two strings, each containing a JSON or YAML document, and pass them to
`CheckPlease.render_diff`.  You'll get back a third string containing a report
of all the differences CheckPlease found in the two JSON strings.

Or, if you'd like to inspect the diffs in your own way, use `CheckPlease.diff`
instead.  You'll get back a `CheckPlease::Diffs` custom collection that
contains `CheckPlease::Diff` instances.

### Understanding the Output

CheckPlease follows the Unix philosophy of "no news is good news".  If your
**candidate** matches your **reference**, you'll get an empty message.

But let's be honest:  how often is that going to happen?  No, you're using this
tool because you want a human-friendly summary of all the places that your
**candidate** fell short.

When CheckPlease compares your two samples, it generates a list of diffs to
describe any discrepancies it encounters.

An example would probably help here.

_(NOTE: these examples may fall out of date with the code.  They're swiped
from [the CLI integration spec](spec/cli_integration_spec.rb), so please
consider that more authoritative than this README.  If you do spot a
difference, please feel free to open an issue!)_

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
  anything "below" the given path.**  _(Technical note:  CheckPlease uses a
  "recursive descent" strategy to traverse the **reference** data structure,
  and it stops when it encounters a type mismatch in order to avoid producing a
  lot of "garbage" diff output.)_
* **mismatch** means that both the **reference** and the **candidate** had a
  value at the given path, and neither value was an Array or a Hash, and the
  two values were not equal.
* **extra** means that, inside an Array or a Hash, the **candidate** contained
  elements that were not found in the **reference**.
* **missing** is the opposite of **extra**:  inside an Array or a Hash, the
  **reference** contained elements that were not found in the **candidate**.

#### Paths

The second column contains a path expression.  This is extremely lo-fi:

* The root of the data structure is defined as "/".
* If an element in the data structure is an array, its child elements will have
  a **one-based** index appended to their parent's path.
* If an element in the data structure is an object ("Hash" in Ruby), the key
  for each element will be appended to their parent's path, and the values will
  be compared.

_**Being primarily a Ruby developer, I'm quite ignorant of conventions in the
JS community; if there's an existing convention for paths, please open an
issue!**_

#### Output Formats

CheckPlease produces tabular output by default.  (It leans heavily on the
amazing [table_print](http://tableprintgem.com) gem for this.)

If you want to incorporate CheckPlease into some other toolchain, it can also
print diffs as JSON to facilitate parsing.  How you do this depends on whether
you're using CheckPlease from the command line or in Ruby, which is a good time
to talk about...

### Flags

CheckPlease has several flags that control its behavior.

For quick help on which flags are available, as well as some terse help text,
you can run the `check_please` executable with no arguments (or the `-h` or
`--help` flags if that makes you feel better).

While of course we aspire to keep this README up to date, it's probably best to
believe things in the following priority order:

* observed behavior
* the code (start from `./lib/check_please.rb` and search for `Flags.define`,
  then trace through as needed)
* the tests (`spec/check_please/flags_spec.rb` describes how the flags work;
	from there, you'll have to search on the flag's name to see how it shows up
	in code)
* the output of `check_please --help`
* this README :)

All flags have exactly one "Ruby name" and one or more "CLI names".  When the
CLI runs, it parses the values in `ARGV` (using Ruby's native `OptionParser`)
and uses that information to build a `CheckPlease::Flags` instance.  After that
point, a flag will be referred to within the CheckPlease code exclusively by
its "Ruby name".

For example, the flag that controls the format in which diffs are displayed has
a Ruby name of `format`, and CLI names of `-f` and `--format`.

#### Setting Flags in the CLI

This should behave more or less as an experienced Unix CLI user might expect.

As such, you can specify, e.g., that you want output in JSON format using
either `--format json` or `-f json`.

(I might expand this section some day.  In the meantime, if you are not yet an
experienced Unix CLI user, feel free to ask for help!  You can either open an
issue or look for emails in the `.gemspec` file...)

#### Setting Flags in Ruby

All external API entry points allow you to specify flags using their Ruby names
in the idiomatic "options Hash at the end of the argument list" that should be
familiar to most Rubyists.  (Again, I assume that, if you're using this tool, I
don't need to explain this further, but feel free to ask for help if you need
it.)

(Internally, CheckPlease immediately converts that options hash into a
`CheckPlease::Flags` object, but that should be considered an implementation
detail unless you're interested in hacking on CheckPlease itself.)

For example, to get back a String containing the diffs between two data
structures in JSON format, you might do:

```
reference = { "foo" => "wibble" }
candidate = { "bar" => "wibble" }
puts CheckPlease.render_diff(
  reference,
  candidate,
  format: :json # <--- flags
)
```

#### "Reentrant" Flags

Several flags are "reentrant".  This means that the flag and its associated
value **may** appear more than once in the CLI.  I've tried to make both the
CLI and the Ruby API follow their respective environment's conventions.

For example, if you want to specify a path to ignore using the
`--reject-paths` flag, you'd invoke the CLI like this:

* `[bundle exec] check_please reference.json candidate.json --select-paths /foo`

And if you want to specify more than one path, that would look like:

* `[bundle exec] check_please reference.json candidate.json --select-paths /foo --select-paths /bar`

In Ruby, you can specify this in the options hash as a single key with an Array
value:

* `CheckPlease.render_diff(reference, candidate, select_paths: [ "/foo", "/bar" ])`

_(NOTE TO MAINTAINERS: internally, the way `CheckPlease::CLI::Parser` uses
Ruby's `OptionParser` leads to some less than obvious behavior.  Search
`./spec/check_please/flags_spec.rb` for the word "surprising" for details.)_

#### Expanded Documentation for Specific Flags

##### match_by_key

_**I know this looks like a LOT of information, but it's really not that bad.  I
just need some very specific examples, and talking about this stuff in English
(rather than code) is hard.  Take a moment for some deep breaths if you need
it.  :)**_

_If you're comfortable reading RSpec and/or want to check out all the edge
cases, go look in `./spec/check_please/comparison_spec.rb` and check out the
`describe` block labeled `"comparing arrays by keys"`._

The short version is that this allows you to match up arrays of hashes using
the value of a single key that is treated as the identifier for each hash.

There's a lot going on in that sentence, so let's unpack it a bit.

Imagine you're comparing two API endpoints that actually return the same data,
but in different orders.  To use a contrived example, let's say that both
documents consist of a single array of two simple hashes, but the reference
array and the candidate array are reversed:

```ruby
# REFERENCE
[ { "id" => 1, "foo" => "bar" },  { "id" => 2, "foo" => "spam" } ]

# CANDIDATE
[ { "id" => 2, "foo" => "spam" }, { "id" => 1, "foo" => "bar" }  ]
```

By default, CheckPlease will match up array elements by their position in the
array, so this will compare the hash with id=1 against the hash with id=2 and
generate a diff report like this:

```
TYPE     | PATH   | REFERENCE | CANDIDATE
---------|--------|-----------|----------
mismatch | /1/id  | 1         | 2
mismatch | /1/foo | "bar"     | "bat"
mismatch | /2/id  | 2         | 1
mismatch | /2/foo | "bat"     | "bar"
```

To solve this problem, CheckPlease adds a **key expression** to its (very
simple) path syntax that lets you specify a **key** to use to match up elements
in both lists, rather than simply comparing elements by position.

Continuing with the above example, if we give `match_by_key` a value of
`["/:id"]`, it will use the "id" value in both hashes (remember, A's `id` is
`1` and B's `id` is `2`) to identify every element in both the reference array
and the candidate array, and correctly match A and B, giving you an empty list
of diffs.

Please note that the CLI and Ruby implementations of these are a bit different
(see the '"Reentrant" Flags' section).

Here are some examples of how that looks on the command line:

* `--match-by-key /:id` -- this says that the top-level element should be an
  array that contains only hashes, and CheckPlease should use the "id" value in
  each hash to match up reference/candidate pairs.

This would correctly match up the `REFERENCE` and `CANDIDATE` documents
described above.

* `--match-by-key /books/:isbn` -- this says that the top-level element should
  be a hash with a 'books' key that refers to an array of book hashes, and
  CheckPlease should use the "isbn" value in each book hash to match up
  reference/candidate pairs.

This would correctly match up the following documents:

```ruby
# REFERENCE
{
  "books" => [
    { "isbn" => "12345", "title" => "Who Am I, Really?" },
    { "isbn" => "67890", "title" => "Who Are Any Of Us, Really?" },
    # ...
  ]
  # ...
}

# CANDIDATE
{
  "books" => [
    { "isbn" => "67890", "title" => "Who Are Any Of Us, Really?" },
    { "isbn" => "12345", "title" => "Who Am I, Really?" },
    # ...
  ]
  # ...
}
```

* `--match-by-key /authors/:id/books/:isbn` -- this example is only here to
  show that you can have more than one **key expression** in a `match_by_key`
  path expression.

This would correctly match up the following documents:

```ruby
  {
    "authors" => [
      {
        "id"    => 1,
        "name"  => "Anne Onymous",
        "books" => [
          { "isbn" => "12345", "title" => "Who Am I, Really?" },
          # ...
        ]
      },
      {
        "id"    => 2,
        "name"  => "Pseud Onymous",
        "books" => [
          { "isbn" => "67890", "title" => "You'll Never Know" },
          # ...
        ]
      },
      # ...
    ]
  }
```

At the top level, CheckPlease will match up hash elements by key.  When it gets
to the "authors" key, it will look at the `match_by_key` expression, see that
it's supposed to use the "id" key to compare elements in an array, and do so.
Further down, when it encounters the "books" key in both authors 1 and 2, it
will use the "isbn" key to match up elements in the "books" array.

----------------------------

Finally, if there are any diffs to report, CheckPlease uses a **key/value
expression** to report mismatches.

Using the last example above (the one with `/authors/:id/books/:isbn`), if the
reference had Anne Onymous' book title as "Who Am I, Really?" and the candidate
listed it as "Who The Heck Am I?", CheckPlease would show this using the
following path expression: `/authors/id=1/books/isbn=12345`

**This syntax is intended to be readable by humans first.**  If you need to
build tooling on it... well, I'm open to suggestions.  :)



## TODO (maybe)

* document flags for rspec matcher
* command line flags for :allthethings:!
  * change display width for table format
    (for example, "2020-07-16T19:42:41.312978" gets cut off)
  * sort by path?
* detect timestamps and compare after parsing?
  * ignore sub-second precision (option / CLI flag)?
  * possibly support plugins for other folks to add custom coercions?
* display filters?  (e.g., { a: 1, b: 2 } ==> "Hash#3")
  * shorter descriptions of values with different classes
    (but maybe just the existing :type_mismatch diffs?)
  * another "possibly support plugins" expansion point here
* more output formats, maybe?
* [0xABAD1DEA] support wildcards in --select-paths and --reject-paths?
  * `#` for indexes, `**` to match one or more path segments?
    (This could get ugly fast.)
* [0xABAD1DEA] look for a config file in ./.check_please_config or ~/.check_please_config,
  combine flags found there with those in ARGV in order of precedence:
  1) ARGV
  2) ./.check_please
  3) ~/.check_please
  * but this may not actually be worth the time and complexity to implement, so
    think about this first...

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
https://github.com/RealGeeks/check_please. This project is intended to be a
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
