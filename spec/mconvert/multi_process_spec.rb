require 'spec_helper'

module MConvert

  describe MultiProcess do

    before(:all) do
      @converter = Converter.new({})
    end

    describe '#get_jobs' do

      context 'with nil option' do
        it 'should return #n_cpus' do
          jobs = @converter.get_jobs(nil)
          expect(jobs).to eq(@converter.n_cpus)
        end
      end

      context 'with small option' do
        it 'should return smaller option' do
          jobs = @converter.get_jobs(1)
          expect(jobs).to eq(1)
        end
      end

      context 'with big option' do
        it 'should return smaller #n_cpus' do
          jobs = @converter.get_jobs(100)
          expect(jobs).to eq(@converter.n_cpus)
        end
      end

    end

    describe '#concurrent' do

      context 'against all processes succeeded' do
        it 'should not call #process_failed' do
          expect(@converter).to_not receive(:process_failed)

          @converter.concurrent(1, [ 0, 1, 2 ]) do
            exec('/usr/bin/true')
          end
        end
      end

      context 'against process failed at the end' do
        it 'should call #process_failed_end' do
          expect(@converter).to receive(:process_failed_end)

          @converter.concurrent(1, [ 0 ]) do
            exec('/usr/bin/false')
          end
        end
      end

      context 'against process failed in the middle' do
        it 'should call #process_failed_middle' do
          expect(@converter).to receive(:process_failed_middle)

          @converter.concurrent(1, [ 0, 1 ]) do |q, i|
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
