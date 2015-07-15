#!/usr/bin/env ruby

require 'thor'
require 'open3'

=begin
  Adopted Format:
    ALAC
    FLAC
    WAVE
    MP3: lame 256kbps VBR
=end

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

  module MultiThread

    def get_jobs(option)
      if option.nil?
        jobs = n_cpus
      else
        jobs = [n_cpus, option].min
      end

      jobs
    end

    def n_cpus
      if RUBY_PLATFORM.include?('-linux')
        processor = 0
        IO.foreach('/proc/cpuinfo') do |line|
          match = line.match(/^processor\s*:\s*(\d)$/)
          processor = match[1].to_i if match
        end
        processor + 1 # CPU # starts from 0

      elsif RUBY_PLATFORM.include?('-darwin')
        `sysctl -n hw.ncpu`.strip.to_i

      else
        1
      end
    end

    def concurrent(n_processes, queue, *args)
      pool = {}

      queue.each_with_index do |q, i|
        while pool.size >= n_processes do
          pid, status = Process.wait2
          unless status.success?
            process_failed_middle(pool[pid])
          end

          pool.delete(pid)
        end

        pid = Process.fork do
          yield(q, i, *args)
        end

        pool[pid] = { queue: q, index: i }
      end

    ensure
      Process.waitall.each do |pid, status|
        unless status.success?
          process_failed_end(pool[pid])
        end
      end
    end

    def process_failed(failed)
      raise "Process ##{failed[:index]} failed: #{failed[:queue]}"
    end

    alias :process_failed_middle :process_failed
    alias :process_failed_end    :process_failed

  end

  class Converter

    include MultiThread

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
        codecs << match[1] unless match.nil?
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

MConvert::CLI.start unless File.basename($0) == 'rspec'
