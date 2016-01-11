module MConvert

  module MultiProcess

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
        processor + 1 # CPU number starts from 0

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

end

