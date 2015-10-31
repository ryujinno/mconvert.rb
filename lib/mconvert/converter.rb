require 'mconvert/multi_process'

require 'open3'

=begin
  Adopted Format:
    ALAC
    FLAC
    WAVE
    MP3: lame 256kbps VBR
=end

module MConvert

  class Converter

    include MultiProcess

    REQUIRED_COMMANDS = [ 'mediainfo', 'ffmpeg' ]
    
    LOSSLESS_CODECS = [
      'ALAC', 'FLAC', 'Wave',
      # 'TAK', 'APE', 'TTA', 'WMA Lossless',
    ]

    def destination_filename(source_filename)
      # Example to convert into flac file
      #source_filename.gsub(/\.\w+$/, '.flac')
    end

    def command_to_comvert(source_filename)
      # Example to convert with ffmpeg 
      #[
      #  'ffmpeg', '-y', '-loglevel', 'warning',
      #  '-i', source_filename,
      #  '-vn', destination_filename(source_filename)
      #]
    end

    def initialize(options)
      @jobs = get_jobs(options[:jobs])
      @jobs.freeze
    end
    
    def convert(source_files)
      has_commands!
      is_lossless!(source_files)

      concurrent(@jobs, source_files) do |source_filename, i|
        do_convert_command(source_filename)
      end
    end

    def has_commands!(mandatory = REQUIRED_COMMANDS)
      mandatory.each do |command|
        Open3.popen3(ENV, 'which', command) do |stdin, out, err, th|
          raise("#{command} is required!") unless th.join.value.success?
        end
      end
    end

    def is_lossless!(files)
      files.each do |file|
        codecs = []

        IO.popen([ 'mediainfo', file ]) do |io|
          codecs = get_codecs(io)
        end

        lossless = LOSSLESS_CODECS & codecs
        if lossless.empty?
          raise("Input file is not lossless format: #{file}")
        end
      end
    end

    def get_codecs(io)
      codecs = []

      io.each do |line|
        match = line.match(/Format\s*:\s*(.*)$/)
        codecs << match[1] if match
      end

      codecs
    end

    def do_convert_command(source_filename)
      puts("Converting: #{source_filename}")
      suceeded = exec(*command_to_comvert(source_filename))
      unless suceeded
        raise "Cannot convert #{source_filename}"
      end
    end

  end

  class FFMpeg < Converter

    def destination_filename(source_filename)
      # Example to convert into flac file
      #source_filename.gsub(/\.\w+$/, '.flac')
    end

    def command_to_comvert(source_filename)
      [
        'ffmpeg', '-y', '-loglevel', 'warning',
        '-i', source_filename,
        '-vn', destination_filename(source_filename)
      ]
    end

  end

  class FFMpegFlac < FFMpeg

    def destination_filename(source_filename)
      source_filename.gsub(/\.\w+$/, '.flac')
    end

  end

  class FFMpegWave < FFMpeg

    def destination_filename(source_filename)
      source_filename.gsub(/\.\w+$/, '.wav')
    end

  end

  class FFMpegAlac < FFMpeg

    def destination_filename(source_filename)
      source_filename.gsub(/\.\w+$/, '.m4a')
    end

    def command_to_comvert(source_filename)
      [
        'ffmpeg', '-y', '-loglevel', 'warning',
        '-i', source_filename,
        '-vn', '-acodec', 'alac', destination_filename(source_filename)
      ]
    end

  end

  class FFMpegMP3 < FFMpeg

    def destination_filename(source_filename)
      source_filename.gsub(/\.\w+$/, '.mp3')
    end

    def command_to_comvert(source_filename)
      [
        'ffmpeg', '-y', '-loglevel', 'warning',
        '-i', source_filename,
        '-vn',
        '-acodec', 'libmp3lame', '-ab', '256k',
        destination_filename(source_filename)
      ]
    end

  end

end

