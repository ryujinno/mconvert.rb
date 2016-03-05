require 'spec_helper'

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
        it 'should raise runtime error' do
          commands = [ 'not_instailed_command' ]
          expect { @ffmpeg.has_commands!(commands) }.to raise_error(RuntimeError)
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
  end
end
