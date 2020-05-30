require 'benchmark'
require 'ffi'

module GoFuncs
  extend FFI::Library
  ffi_lib './ruby.so'
  attach_function :StartBackground, [:string, :int], :void
  attach_function :StopBackground, [], :int
end

def log message
  puts "ffi.rb: #{message}"
end

def active_wait(nb)
  nb.times {
    :'Allocate a new string to do something'
  }
end

class Array
  def avg
    reduce(&:+) / size if size > 0
  end
end

# Disable GC for better measurements
GC.disable

TESTS = [
  # nb iterations in active sleep
  10_000,
  50_000,
  100_001,
  1_000_002,
  10_000_003,
  100_000_004,
  500_000_005,
  1_000_000_006
]

NB_GOROUTINES = 3
TESTS.each do |i|
  log("=== Run ##{i} =======================")
  wait_time_idle_1 = Benchmark.realtime { active_wait(i) }
  log("active_wait: %.3fs" % wait_time_idle_1)

  GoFuncs.StartBackground("Nb active_wait iterations: #{i}", NB_GOROUTINES)

  wait_time_ffi = Benchmark.realtime { active_wait(i) }
  log("active_wait: %.3fs" % wait_time_ffi)

  nb_loops = GoFuncs.StopBackground()
  nb_loops *= 1000 # divided by 1000 in go code
  log("background stopped: #{nb_loops} loops" % nb_loops)

  wait_time_idle_2 = Benchmark.realtime { active_wait(i) }
  log("active_wait: %.3fs" % wait_time_idle_2)

  wait_time_idle_avg = [wait_time_idle_1, wait_time_idle_2].avg
  diff = wait_time_ffi - wait_time_idle_avg
  percent = diff / wait_time_idle_avg * 100
  log("diff: ~%.3fs (+%.2f%%)" % [diff, percent])
end
