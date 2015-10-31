require 'thor'

module MConvert

  class CLI < Thor

    class_option :jobs, aliases: '-j', type: :numeric, desc: 'Limit jobs under number of CPUs'

    desc 'alac LOSSLESS_FILES', 'Convert lossless files to ALAC'
    def alac(*files)
      FFMpegAlac.new(options).convert(files)
    end

    desc 'flac LOSSLESS_FILES', 'Convert lossless files to FLAC'
    def flac(*files)
      FFMpegFlac.new(options).convert(files)
    end

    desc 'wave LOSSLESS_FILES', 'Convert lossless files to WAVE'
    def wave(*files)
      FFMpegWave.new(options).convert(files)
    end

    desc 'mp3 LOSSLESS_FILES', 'Convert lossless files to mp3 with lame'
    def mp3(*files)
      FFMpegMP3.new(options).convert(files)
    end

  end

end
