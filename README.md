# Int

An interval-arithmetic-ish library (with a terrible name).

## Introduction

Welcome to my new gem! In this directory, I'll find the files I need to be able to package
up my Ruby library into a gem. Put my Ruby code in the file `lib/int`. To experiment with
that code, run `bin/console` for an interactive prompt.

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add int

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install int

## Usage

```ruby
pp Int(1, 2) + Int(3, 4) #=> Int(4..(5.0)..6)
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake
test-unit` to run the tests. You can also run `bin/console` for an interactive prompt that
will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a
new version, update the version number in `version.rb`, and then run `bundle exec rake
release`, which will create a git tag for the version, push git commits and the created
tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/tadd/int
except for name change proposals.
