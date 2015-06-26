# Mconvert

Multi-processed lossless music file converter

## Installation

Install as:

    $ brew install ffmpeg mediainfo
    $ gem install specific_install
    $ gem specific_install ryujinno/mconvert.rb

## Usage

    $ mconvert.rb alac LOSSLESS_FILES.wav ... # Convert lossless files to ALAC
    $ mconvert.rb flac LOSSLESS_FILES.m4a ... # Convert lossless files to FLAC
    $ mconvert.rb mp3  LOSSLESS_FILES.m4a ... # Convert lossless files to mp3 with lame
    $ mconvert.rb wave LOSSLESS_FILES.m4a ... # Convert lossless files to WAVE

## Contributing

1. Fork it ( https://github.com/ryujinno/mconvert/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
