sim = Simulator.find_by_name(ARGV[0])

param_keys = sim.parameter_definitions.map(&:key)
result_keys = sim.runs.where(status: :finished).first&.result&.keys
raise "there is no runs having a result" if result_keys.nil?

puts "# " + param_keys.join(',') + ',' + result_keys.join(',')  # print header
sim.runs.where(status: :finished).each do |run|
  ps = run.parameter_set
  values = param_keys.map {|k| ps.v[k] } + result_keys.map {|k| run.result[k] }
  puts values.join(',')
end

