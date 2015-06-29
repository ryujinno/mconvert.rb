require File.expand_path('../../bin/mconvert.rb', __FILE__)

require 'tempfile'

module MConvert

  describe MConvert::FFMpeg do

    before(:all) do
      @ffmpeg = FFMpeg.new({})
    end

    describe '#has_commands!' do

      context 'with command installed' do
        it 'should not raise error' do
          commands = [ 'true' ]
          expect { @ffmpeg.has_commands!(commands) }.to_not raise_error
        end
      end

      context 'with command not installed' do
        it 'should raise error' do
          commands = [ 'not_instailed_command' ]
          expect { @ffmpeg.has_commands!(commands) }.to raise_error
        end
      end

    end

    describe '#get_codecs' do

      context 'with format' do
        it 'should return codecs as a array' do
          lines = [ 'Format: MPEG-4', 'Format: ALAC' ]
          expect(@ffmpeg.get_codecs(lines)). to match_array([ 'MPEG-4', 'ALAC' ])
        end
      end

      context 'without format' do
        it 'should return empty array' do
          lines = [ 'General', 'Audio' ]
          expect(@ffmpeg.get_codecs(lines)). to be_empty
        end
      end

    end

    describe MultiThread do

      describe '#get_jobs' do

        context 'with nil option' do
          it 'should return #n_cpus' do
            jobs = @ffmpeg.get_jobs(nil)
            expect(jobs).to eq(@ffmpeg.n_cpus)
          end
        end

        context 'with small option' do
          it 'should return smaller option' do
            jobs = @ffmpeg.get_jobs(1)
            expect(jobs).to eq(1)
          end
        end

        context 'with big option' do
          it 'should return smaller #n_cpus' do
            jobs = @ffmpeg.get_jobs(100)
            expect(jobs).to eq(@ffmpeg.n_cpus)
          end
        end

      end

      describe '#concurrent' do

        context 'against all processes succeeded' do
          it 'should not call #process_failed' do
            expect(@ffmpeg).to_not receive(:process_failed)

            @ffmpeg.concurrent(1, [ 0, 1, 2 ]) do
              exec('/usr/bin/true')
            end
          end
        end

        context 'against process failed at the end' do
          it 'should call #process_failed_end' do
            expect(@ffmpeg).to receive(:process_failed_end)

            @ffmpeg.concurrent(1, [ 0 ]) do
              exec('/usr/bin/false')
            end
          end
        end

        context 'against process failed in the middle' do
          it 'should call #process_failed_middle' do
            expect(@ffmpeg).to receive(:process_failed_middle)

            @ffmpeg.concurrent(1, [ 0, 1 ]) do |q, i|
              if q == 0
                exec('/usr/bin/false')
              else
                exec('/usr/bin/true')
              end
            end
          end
        end

      end

    end

  end
end
