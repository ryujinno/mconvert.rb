# MConvert

[![Build Status](https://travis-ci.org/ryujinno/mconvert.rb.svg?branch=master)](https://travis-ci.org/ryujinno/mconvert.rb)

Multi-processed lossless music file converter.

## Installation

### Install dependant commands

For Mac OS X:

```
$ brew install ffmpeg mediainfo
```

For Linux:

```
$ apt-get install ffmpeg mediainfo
```

### Install with bundler

Add the following line to `${HOME}/Gemfile`:

```ruby
gem 'mconvert', github: 'ryujinno/mconvert.rb'
```

Install gems and commands as:

```
$ bundle install --binstubs
```

`mconvert` command is installed to `${HOME}/bin`.

## Usage

```
Commands:
  mconvert alac LOSSLESS_FILES  # Convert lossless files to ALAC
  mconvert flac LOSSLESS_FILES  # Convert lossless files to FLAC
  mconvert help [COMMAND]       # Describe available commands or one specific command
  mconvert mp3 LOSSLESS_FILES   # Convert lossless files to mp3 with lame
  mconvert wave LOSSLESS_FILES  # Convert lossless files to WAVE

Options:
  -j, [--jobs=N]  # Limit jobs under number of CPUs
```

## Contributing

1. Fork it ( https://github.com/ryujinno/mconvert.rb/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
