require 'json'

def print_on_run_headers(outputs_info, variable_info_array, output_info_array)
  header1 = outputs_info["constants"].reduce("##") {|result, (key, value)| result + " #{key}=#{value}"}

  header2 = "#"
  if variable_info_array[0].has_key?("short") then
    header2 += " #{variable_info_array[0]["short"]}"
  else
    header2 += " #{variable_info_array[0]["name"]}"
  end
  header2 += variable_info_array[1..-1].reduce("") {|result, variable_info| if variable_info.has_key?("short") then result + "\t#{variable_info["short"]}" else result + "\t#{variable_info["name"]}" end}
  header2 += output_info_array.reduce("") {|result, output_info| if output_info.has_key?("short") then result + "\tavg(#{output_info["short"]})\terr(#{output_info["short"]})" else result + "\tavg(#{output_info["name"]})\terr(#{output_info["name"]})" end}

  $stdout.puts header1
  $stdout.puts header2
end

def print_on_parameter_set_headers(outputs_info, variable_info_array, output_info_array)
  header1 = outputs_info["constants"].reduce("##") {|result, (key, value)| result + " #{key}=#{value}"}

  header2 = "#"
  if variable_info_array[0].has_key?("short") then
    header2 += " #{variable_info_array[0]["short"]}"
  else
    header2 += " #{variable_info_array[0]["name"]}"
  end
  header2 += variable_info_array[1..-1].reduce("") {|result, variable_info| if variable_info.has_key?("short") then result + "\t#{variable_info["short"]}" else result + "\t#{variable_info["name"]}" end}
  header2 += output_info_array.reduce("") {|result, output_info| if output_info.has_key?("short") then result + "\t#{output_info["short"]}" else result + "\t#{output_info["name"]}" end}

  $stdout.puts header1
  $stdout.puts header2
end

def get_variables(variable_info_array, parameter_set)
  variable_info_array.map {|variable| parameter_set.v[variable["name"]]}
end

def get_averages_of(outputs_array)
  num_outputs = outputs_array[0].length
  outputs_array.reduce([0.0] * num_outputs) {|result, outputs| result.zip(outputs).map {|result_output| result_output[0] + result_output[1]}}.map {|sum| sum / outputs_array.length}
end

def get_errors_of(outputs_array, averages)
  num_outputs = averages.length
  outputs_array.reduce([0.0] * num_outputs) {|result, outputs| result.zip(outputs, averages).map {|result_output_average| result_output_average[0] + (result_output_average[1] - result_output_average[2]) ** 2}}.map {|value| Math.sqrt(value / outputs_array.length / (outputs_array.length-1))}
end

def print_averages_errors(variable_info_array, outputs_array, parameter_set)
  variables = get_variables(variable_info_array, parameter_set)

  averages = get_averages_of(outputs_array)
  errors = get_errors_of(outputs_array, averages)

  $stdout.print variables[0]
  variables[1..-1].each {|variable| $stdout.print "\t#{variable}"}
  averages.zip(errors).each {|average_error| $stdout.print "\t#{average_error[0]}\t#{average_error[1]}"}
  $stdout.puts
end

def print_outputs(variable_info_array, outputs, parameter_set)
  variables = get_variables(variable_info_array, parameter_set)

  $stdout.print variables[0]
  variables[1..-1].each {|variable| $stdout.print "\t#{variable}"}
  outputs.each {|output| $stdout.print "\t#{output}"}
  $stdout.puts
end


if ARGV.length < 2 or ARGV.length > 3 then
  $stderr.puts "wrong number of arguments: print_outputs.rb <simulator name> <absolute path of json file> [<analyzer name>]"
  exit(false)
end

simulator = Simulator.find_by_name(ARGV[0])
outputs_info = JSON.load(File.open(ARGV[1]))

variable_info_array = outputs_info["variables"]
output_info_array = outputs_info["outputs"]


constants_hash = outputs_info["constants"].reduce({}) {|result, (key, value)| result["v.#{key}"] = value; result}
if ARGV.length == 2 then
  print_on_run_headers(outputs_info, variable_info_array, output_info_array)

  simulator.parameter_sets.where(constants_hash).each do |parameter_set|
    outputs_array = parameter_set.runs.where(status: :finished).map {|run| output_json = JSON.load(File.open(run.dir.join("_output.json"))); output_info_array.map {|output_info| output_json[output_info["name"]]}}

    print_averages_errors(variable_info_array, outputs_array, parameter_set)
  end
else
  analyzer = simulator.find_analyzer_by_name(ARGV[2])

  if analyzer[:type] == :on_run then
    print_on_run_headers(outputs_info, variable_info_array, output_info_array)

    simulator.parameter_sets.where(constants_hash).each do |parameter_set|
      outputs_array = parameter_set.runs.where(status: :finished).map {|run| output_json = JSON.load(File.open(run.analyses.where(analyzer: analyzer, status: :finished).max_by {|analysis| analysis.created_at}.dir.join("_output.json"))); output_info_array.map {|output_info| output_json[output_info["name"]]}}

      print_averages_errors(variable_info_array, outputs_array, parameter_set)
    end
  else# if analyzer[:type] == :on_parameter_set then
    print_on_parameter_set_headers(outputs_info, variable_info_array, output_info_array)

    simulator.parameter_sets.where(constants_hash).each do |parameter_set|
      output_json = JSON.load(File.open(parameter_set.analyses.where(analyzer: analyzer, status: :finished).max_by {|analysis| analysis.created_at}.dir.join("_output.json")))
      outputs = output_info_array.map {|output_info| output_json[output_info["name"]]}

      print_outputs(variable_info_array, outputs, parameter_set)
    end
  end
end

