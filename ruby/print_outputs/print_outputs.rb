require 'json'

if ARGV.length != 2 then
  $stderr.puts "wrong number of arguments: print_outputs.rb <simulator name> <absolute path of json file>"
  exit(false)
end

simulator = Simulator.find_by_name(ARGV[0])
outputs_info = JSON.load(File.open(ARGV[1]))

variable_info_array = outputs_info["variables"]
output_info_array = outputs_info["outputs"]

header1 = outputs_info["constants"].reduce("##") {|result, (key, value)| result + " #{key}=#{value}"}
header2 = variable_info_array.reduce("#") {|result, variable_info| if variable_info.has_key?("short") then result + " #{variable_info["short"]}" else result + " #{variable_info["name"]}" end}
header2 += output_info_array.reduce("") {|result, output_info| if output_info.has_key?("short") then result + " avg(#{output_info["short"]}) err(#{output_info["short"]})" else result + " avg(#{output_info["name"]}) err(#{output_info["name"]})" end}

$stdout.puts header1
$stdout.puts header2


simulator.parameter_sets.where(outputs_info["constants"].map {|key, value| ["v.#{key}", value]}.to_h).each do |parameter_set|
  variables = variable_info_array.map {|variable| parameter_set.v[variable["name"]]}
  outputs_array = parameter_set.runs.map {|run| output_json = JSON.load(File.open(run.dir.join("_output.json"))); output_info_array.map{|output_info| output_json[output_info["name"]]}}

  averages = outputs_array.reduce {|result, outputs| result.zip(outputs).map {|result_output| result_output[0] + result_output[1]}}.map {|sum| sum / outputs_array.length}
  errors = outputs_array.reduce {|result, outputs| result.zip(outputs, averages).map {|result_output_average| result_output_average[0] + (result_output_average[1] - result_output_average[2]) ** 2}}.map {|value| Math.sqrt(value / outputs_array.length / (outputs_array.length-1))}

  $stdout.print variables[0]
  variables[1..-1].each {|variable| $stdout.print " #{variable}"}
  averages.zip(errors).each {|average_error| $stdout.print " #{average_error[0]} #{average_error[1]}"}
  $stdout.puts
end

