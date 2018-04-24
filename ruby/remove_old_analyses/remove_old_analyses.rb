def remove_old_analyses_from(possible_analyses)
  num_analyses = possible_analyses.length
  return if num_analyses <= 1

  possible_analyses.sort_by {|analysis| analysis.created_at}.take(num_analyses-1).each do |analysis|
    $stdout.puts "deleting #{analysis.id}"
    analysis.discard
  end
end

def remove_old_analyses_of(analyzer, simulator)
  if analyzer[:type] == :on_run then
    simulator.parameter_sets.each do |parameter_set|
      parameter_set.runs.where(status: :finished).each do |run|
        remove_old_analyses_from(run.analyses.where(analyzer: analyzer, status: :finished))
      end
    end
  else# if analyzer[:type] == :on_parameter_set
    simulator.parameter_sets.each do |parameter_set|
      remove_old_analyses_from(parameter_set.analyses.where(analyzer: analyzer, status: :finished))
    end
  end
end


if ARGV.length == 0 or ARGV.length > 2 then
  $stderr.puts "wrong number of arguments: remove_old_analyses.rb <simulator name> [<analyzer name>]"
  exit(1)
end

simulator = Simulator.find_by_name(ARGV[0])

if ARGV.length == 2 then
  remove_old_analyses_of(simulator.find_analyzer_by_name(ARGV[1]), simulator)
else
  simulator.analyzers.each do |analyzer|
    $stdout.puts "analyzer #{analyzer.name}:"
    remove_old_analyses_of(analyzer, simulator)
  end
end
