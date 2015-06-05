#!/usr/bin/env ruby

require 'thor'
require 'thwait'
require 'monitor'
require 'open3'

=begin
  Adopted Format:
    ALAC
    FLAC
    WAVE
    MP3: lame 256kbps VBR
=end

module MConvert
  class Command < Thor
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

  class Converter
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
      has_commands!

      if options[:jobs].nil?
        @jobs = n_cpus
      else
        @jobs = [n_cpus, options[:jobs]].min
      end
      @jobs.freeze

      @monitor = Monitor.new
    end
    
    def has_commands!(mandatory = REQUIRED_COMMANDS)
      mandatory.each do |command|
        Open3.popen3(ENV, 'which', command) do |stdin, out, err, th|
          raise("#{command} is required!") unless th.join.value.success?
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

    def convert(source_files)
      is_lossless!(source_files)
      concurrent(source_files) { |source_filename| do_convert_command(source_filename) }
    end

    def is_lossless!(files)
      files.each do |file|
        lossless = false
        IO.popen([ 'mediainfo', file ]) do |io|
          io.each_line do |line|
            codec = $~[1] if line =~ /Format\s*:\s*(.*)$/
            lossless = LOSSLESS_CODECS.include?(codec)
            break if lossless
          end
          unless lossless
            raise("Input file is not lossless format: #{file}")
          end
        end
      end
    end

    def concurrent(queue)
      n_threads = @jobs
      pool = ThreadsWait.new

      queue.each do |q|
        unless pool.threads.length < n_threads
          pool.next_wait.join
        end

        thread = Thread.new(q) do |q|
          yield(q)
        end

        pool.join_nowait(thread)
      end
    ensure
      pool.all_waits
    end

    def do_convert_command(source_filename)
      @monitor.synchronize { puts("Converting #{source_filename}") }
      suceeded = system(*command_to_comvert(source_filename))
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

MConvert::Command.start
