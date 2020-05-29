require 'benchmark'
require 'ffi'

module GoFuncs
  extend FFI::Library
  ffi_lib './ruby.so'
  attach_function :StartBackground, [:string, :int], :void
  attach_function :StopBackground, [], :int
end

def active_wait
  100_000_000.times {
    'Allocate a new string to do something'
  }
end

puts("pure ruby wait lasts %fs" % Benchmark.realtime { active_wait })

puts(Benchmark.realtime do
  puts "ffi.rb: starting go background loop"
  GoFuncs.StartBackground("whatever", 200)

  puts("pure ruby wait lasts %fs" % Benchmark.realtime { active_wait })

  nb_loops = GoFuncs.StopBackground()
  puts "ffi.rb: background stopped after #{nb_loops} loops"
end)
