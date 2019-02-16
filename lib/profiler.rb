# require 'memory_profiler'

def profile(prefix = 'foo::bar_profile', skip_profile = false, use_call_grind = true)
  if skip_profile
    yield
  else
    if use_call_grind # else use memory_profiler
      # default is RubyProf::WALL_TIME
      # RubyProf.measure_mode = RubyProf::WALL_TIME
      RubyProf.measure_mode = RubyProf::PROCESS_TIME
      # RubyProf.measure_mode = RubyProf::CPU_TIME
      # RubyProf.measure_mode = RubyProf::ALLOCATIONS
      # RubyProf.measure_mode = RubyProf::MEMORY
      # RubyProf.measure_mode = RubyProf::GC_TIME
      # RubyProf.measure_mode = RubyProf::GC_RUNS
      result = RubyProf.profile { yield }

      dir = File.join(Rails.root, 'tmp', 'callgrind')
      FileUtils.mkdir_p(dir)
      # file = File.join(dir, "callgrind.out.%s.%s.%s" % [ prefix.parameterize,
      #                                                    RubyProf.measure_mode_string.parameterize,
      #                                                    Time.now.strftime('%d%m%Y.%H%M').parameterize ] )
      # open(file, "w") {|f| RubyProf::CallTreePrinter.new(result).print(path: dir, min_percent: 10) }
      RubyProf::CallTreePrinter.new(result).print(profile: 'callgrind.out.', path: dir, min_percent: 1)
    else # use memory_profiler
      report = MemoryProfiler.report { yield }
      dir = File.join(Rails.root, 'tmp', 'memory_profiler')
      FileUtils.mkdir_p(dir)
      file = File.join(dir, 'callgrind.out.mem.prof.%s.%s' % [prefix.parameterize, Time.now.strftime('%d%m%Y.%H%M').parameterize])
      report.pretty_print(to_file: file)
    end
  end
end

def time_split(txt = '')
  @time_split = Time.now
  yield
  puts "#{txt} takes: #{(Time.now - @time_split).to_i} sec"
end

def profile_stack(profile = 'stackprof.dump', mode = :cpu)
  dir = File.join(Rails.root, 'tmp', 'performance', 'stackprof')
  StackProf.run(mode: mode, out: dir + profile) do
    yield
  end
end

# gem 'allocation_tracer'
def allocation_trace(_profile = 'allocation_tracer.dump')
  ObjectSpace::AllocationTracer.setup(%i(path line type))
  report = ObjectSpace::AllocationTracer.trace do
    yield
  end
  dir = File.join(Rails.root, 'tmp', 'performance', 'allocation_tracer')
  FileUtils.mkdir_p(dir)
  file = File.join(dir, 'allocation_tracer.prof.%s.%s' % [prefix.parameterize, Time.now.strftime('%d%m%Y.%H%M').parameterize])
  report.pretty_print(to_file: file)
end
