sim = Simulator.find_by_name(ARGV[0])

empty_pss = sim.parameter_sets.find_all {|ps| ps.runs.count == 0 }

$stderr.puts "No empty ParameterSet was found" if empty_pss.count == 0

empty_pss.each do |ps|
  $stderr.puts "Deleting #{ps.id}"
  ps.discard
end

