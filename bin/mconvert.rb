#!/usr/bin/env ruby

require 'thor'
require 'thwait'
require 'monitor'
require 'open3'

=begin
  Adopted Format:
    FLAC
    ALAC
    WAVE
    MP3: lame 256kbps VBR
=end

module MConvert
  class Command < Thor
    desc 'alac FILES', 'Convert Lossless files to ALAC'
    def alac(*files)
      FFMpegAlac.new.convert(*files)
    end

    desc 'flac FILES', 'Convert Lossless files to FLAC'
    def flac(*files)
      FFMpegFlac.new.convert(*files)
    end

    desc 'wave FILES', 'Convert Lossless files to WAVE'
    def wave(*files)
      FFMpegWave.new.convert(*files)
    end

    desc 'mp3 FILES', 'Convert Lossless files to mp3 with lame'
    def mp3(*files)
      FFMpegMP3.new.convert(*files)
    end
  end

  class Converter
    REQUIRE_COMMANDS = [ 'mediainfo', 'ffmpeg' ]
    
    LOSSLESS_CODECS = [
      'ALAC', 'FLAC', 'Wave',
      # 'TAK', 'APE', 'TTA', 'WMA Lossless',
    ]

    def destination_filename(source_filename)
      # Example to convert into flac file
      #source_filename.gsub(/(\.\w+){1,2}$/, '.flac')
    end

    def command_to_comvert(source_filename)
      # Example to convert with ffmpeg 
      #[
      #  'ffmpeg', '-y', '-loglevel', 'warning',
      #  '-i', source_filename,
      #  '-vn', destination_filename(source_filename)
      #]
    end

    def initialize
      has_commands!
    end
    
    def has_commands!(mandatory = REQUIRE_COMMANDS)
      mandatory.each do |command|
        Open3.popen3(ENV, 'which', command) do |stdin, out, err, th|
          abort("#{command} is required!") unless th.join.value.success?
        end
      end
    end

    def is_lossless!(*files)
      files.each do |file|
        lossless = false
        IO.popen([ 'mediainfo', file ]) do |io|
          io.each_line do |line|
            codec = $~[1] if line =~ /Format\s*:\s*(.*)$/
            lossless = LOSSLESS_CODECS.include?(codec) 
            break if lossless
          end
          unless lossless
            abort("Input file is not lossless format: #{file}")
          end
        end
      end
    end

    def n_cpus
      if RUBY_PLATFORM.include?('-linux')
        processor = 0
        IO.foreach('/proc/cpuinfo') do |line|
          if line =~ /^processor\s*:\s*(\d)$/
            processor = $~[1].to_i
          end
        end
        processor + 1 # CPU # starts from 0

      elsif RUBY_PLATFORM.include?('-darwin')
        `sysctl -n hw.ncpu`.strip.to_i

      else
        1
      end
    end

    def concurrent(*files)
      n_threads = n_cpus
      pool = ThreadsWait.new
      @monitor = Monitor.new

      files.each do |file|
        unless pool.threads.length < n_threads
          pool.next_wait 
        end

        thread = Thread.new(file) do |file|
          begin
            yield(file)
          rescue => error
            puts error
          end
        end

        pool.join_nowait(thread)
      end
    ensure
      pool.all_waits
    end

    def convert(*source_files)
      is_lossless!(*source_files)
      concurrent(*source_files) { |source_filename| do_convert_command(source_filename) }
    end

    def do_convert_command(source_filename)
      @monitor.synchronize { puts("Converting #{source_filename}") }
      suceeded = system(*command_to_comvert(source_filename))
      unless suceeded
        abort("Failed to covnert: #{source_filename}")
      end
    end
  end

  class FFMpeg < Converter
    def destination_filename(source_filename)
      # Example to convert into flac file
      #source_filename.gsub(/(\.\w+){1,2}$/, '.flac')
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
      source_filename.gsub(/(\.\w+){1,2}$/, '.flac')
    end
  end

  class FFMpegWave < FFMpeg
    def destination_filename(source_filename)
      source_filename.gsub(/(\.\w+){1,2}$/, '.wav')
    end
  end

  class FFMpegAlac < FFMpeg
    def destination_filename(source_filename)
      source_filename.gsub(/(\.\w+){1,2}$/, '.m4a')
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
      source_filename.gsub(/\.\w+(\.m4a)?$/, '.mp3')
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

MConvert::Command.start
