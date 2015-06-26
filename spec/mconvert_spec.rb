require File.expand_path('../../bin/mconvert.rb', __FILE__)

require 'tempfile'

module MConvert

  describe MConvert::FFMpeg do

    describe '#concurrent' do

      before(:all) do
        @ffmpeg = FFMpeg.new({})
      end

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
