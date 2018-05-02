require 'json'
require 'pathname'
require 'fileutils'

if ARGV.length != 3 then
  $stderr.puts "wrong number of arguments: copy_analysis_files.rb <simulator name> <absolute path of json file> <absolute path of directory>"
  exit(false)
end

simulator = Simulator.find_by_name(ARGV[0])
copying_data_info = JSON.load(File.open(ARGV[1]))
directory = Pathname(ARGV[2])

constants_hash = copying_data_info["constants"].reduce({}) {|result, (key, value)| result["v.#{key}"] = value; result}
variable_info_array = copying_data_info["variables"]

copying_data_info["analyzers"].each do |analyzer_info|
  analyzer_name = analyzer_info["name"]
  analyzer = simulator.find_analyzer_by_name(analyzer_name)
  $stdout.puts "[#{analyzer_name}]"

  analyzer_files = analyzer_info["files"]

  simulator.parameter_sets.where(constants_hash).each do |parameter_set|
    analyses = parameter_set.analyses.where(analyzer: analyzer, status: :finished)
    next if analyses.length == 0
    analysis = analyses.max_by {|analysis| analysis.created_at}

    origins = analyzer_files.map {|filename| analysis.dir.join(filename)}
    destination = variable_info_array.reduce(directory) {|result, variable_info| result.join("#{variable_info["short"]}#{parameter_set.v[variable_info["name"]]}")}

    FileUtils.mkdir_p(destination)
    $stdout.puts "copying to #{destination}"
    origins.find_all {|origin| File.exist?(origin)}.each {|origin| FileUtils.cp(origin, destination)}
  end
end

