# Mconvert

Multi-processed lossless music file converter.

## Installation

### Install dependant commands

For Mac OS X:

    $ brew install ffmpeg mediainfo

For Linux:

    $ apt-get install ffmpeg mediainfo

### Install with bundler

Add following line to your Gemfile:

    gem 'mconvert', git: 'https://github.com/ryujinno/mconvert.rb.git'

Install gems and commands as:

    $ bundle install --binstubs

## Usage

    Commands:
      mconvert alac LOSSLESS_FILES  # Convert lossless files to ALAC
      mconvert flac LOSSLESS_FILES  # Convert lossless files to FLAC
      mconvert help [COMMAND]       # Describe available commands or one specific command
      mconvert mp3 LOSSLESS_FILES   # Convert lossless files to mp3 with lame
      mconvert wave LOSSLESS_FILES  # Convert lossless files to WAVE

    Options:
      -j, [--jobs=N]  # Limit jobs under number of CPUs

## Contributing

1. Fork it ( https://github.com/ryujinno/mconvert/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
