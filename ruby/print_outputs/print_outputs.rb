require 'json'

def print_on_run_headers(outputs_info, variable_info_array, output_info_array)
  header1 = outputs_info["constants"].reduce("##") {|result, (key, value)| result + " #{key}=#{value}"}
  header2 = variable_info_array.reduce("#") {|result, variable_info| if variable_info.has_key?("short") then result + " #{variable_info["short"]}" else result + " #{variable_info["name"]}" end}
  header2 += output_info_array.reduce("") {|result, output_info| if output_info.has_key?("short") then result + " avg(#{output_info["short"]}) err(#{output_info["short"]})" else result + " avg(#{output_info["name"]}) err(#{output_info["name"]})" end}

  $stdout.puts header1
  $stdout.puts header2
end

def print_on_parameter_set_headers(outputs_info, variable_info_array, output_info_array)
  header1 = outputs_info["constants"].reduce("##") {|result, (key, value)| result + " #{key}=#{value}"}
  header2 = variable_info_array.reduce("#") {|result, variable_info| if variable_info.has_key?("short") then result + " #{variable_info["short"]}" else result + " #{variable_info["name"]}" end}
  header2 += output_info_array.reduce("") {|result, output_info| if output_info.has_key?("short") then result + " #{output_info["short"]}" else result + " #{output_info["name"]}" end}

  $stdout.puts header1
  $stdout.puts header2
end


if ARGV.length < 2 or ARGV.length > 3 then
  $stderr.puts "wrong number of arguments: print_outputs.rb <simulator name> <absolute path of json file> [<analyzer name>]"
  exit(false)
end

simulator = Simulator.find_by_name(ARGV[0])
outputs_info = JSON.load(File.open(ARGV[1]))

variable_info_array = outputs_info["variables"]
output_info_array = outputs_info["outputs"]


if ARGV.length == 2 then
  print_on_run_headers(outputs_info, variable_info_array, output_info_array)

  simulator.parameter_sets.where(outputs_info["constants"].reduce({}) {|result, (key, value)| result["v.#{key}"] = value; result}).each do |parameter_set|
    variables = variable_info_array.map {|variable| parameter_set.v[variable["name"]]}
    outputs_array = parameter_set.runs.where(status: :finished).map {|run| output_json = JSON.load(File.open(run.dir.join("_output.json"))); output_info_array.map {|output_info| output_json[output_info["name"]]}}

    averages = outputs_array.reduce([]) {|result, outputs| result.zip(outputs).map {|result_output| result_output[0] + result_output[1]}}.map {|sum| sum / outputs_array.length}
    errors = outputs_array.reduce([]) {|result, outputs| result.zip(outputs, averages).map {|result_output_average| result_output_average[0] + (result_output_average[1] - result_output_average[2]) ** 2}}.map {|value| Math.sqrt(value / outputs_array.length / (outputs_array.length-1))}

    $stdout.print variables[0]
    variables[1..-1].each {|variable| $stdout.print " #{variable}"}
    averages.zip(errors).each {|average_error| $stdout.print " #{average_error[0]} #{average_error[1]}"}
    $stdout.puts
  end
else
  analyzer = simulator.find_analyzer_by_name(ARGV[2])

  if analyzer[:type] == :on_run then
    print_on_run_headers(outputs_info, variable_info_array, output_info_array)

    simulator.parameter_sets.where(outputs_info["constants"].reduce({}) {|result, (key, value)| result["v.#{key}"] = value; result}).each do |parameter_set|
      variables = variable_info_array.map {|variable| parameter_set.v[variable["name"]]}
      outputs_array = parameter_set.runs.where(status: :finished).map {|run| output_json = JSON.load(File.open(run.analyses.where(analyzer: analyzer, status: :finished).max_by {|analysis| analysis.created_at}.dir.join("_output.json"))); output_info_array.map {|output_info| output_json[output_info["name"]]}}

      averages = outputs_array.reduce([]) {|result, outputs| result.zip(outputs).map {|result_output| result_output[0] + result_output[1]}}.map {|sum| sum / outputs_array.length}
      errors = outputs_array.reduce([]) {|result, outputs| result.zip(outputs, averages).map {|result_output_average| result_output_average[0] + (result_output_average[1] - result_output_average[2]) ** 2}}.map {|value| Math.sqrt(value / outputs_array.length / (outputs_array.length-1))}

      $stdout.print variables[0]
      variables[1..-1].each {|variable| $stdout.print " #{variable}"}
      averages.zip(errors).each {|average_error| $stdout.print " #{average_error[0]} #{average_error[1]}"}
      $stdout.puts
    end
  else# if analyzer[:type] == :on_parameter_set then
    print_on_parameter_set_headers(outputs_info, variable_info_array, output_info_array)

    simulator.parameter_sets.where(outputs_info["constants"].reduce({}) {|result, (key, value)| result["v.#{key}"] = value; result}).each do |parameter_set|
      variables = variable_info_array.map {|variable| parameter_set.v[variable["name"]]}
      output_json = JSON.load(File.open(parameter_set.analyses.where(analyzer: analyzer, status: :finished).max_by {|analysis| analysis.created_at}.dir.join("_output.json")))
      outputs = output_info_array.map {|output_info| output_json[output_info["name"]]}

      $stdout.print variables[0]
      variables[1..-1].each {|variable| $stdout.print " #{variable}"}
      outputs.each {|output| $stdout.print " #{output}"}
      $stdout.puts
    end
  end
end

