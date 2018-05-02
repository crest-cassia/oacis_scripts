# Print outputs

This script prints values in `_output.json` in each run/analysis as a tab-delimited format.

## Usage

```
./bin/oacis_ruby print_outputs.rb <simulator name> <json> [<analyzer name>]
```

You have to specify an absolute path of a json file.

`template.json` is a sample of the json file.

```
{
  "constants": {
    "x_length": 128,
    "y_length": 128
  },
  "variables": [
    {
      "name": "temperature",
      "short": "T"
    },
    {
      "name": "field",
      "short": "h"
    }
  ],
  "outputs": [
    {
      "name": "magnetization",
      "short": "m"
    },
    {
      "name": "energy",
      "short": "E"
    }
  ]
}
```

The script searches for parameter sets whose parameters specified by constants are fixed. Sample of outputs of the script is as follows (tab is represented by two spaces):

```
## x_length=128 y_length=128
# T  h  mean(m)  se(m)  mean(E)  se(E)
0.5  0.0  1.0  0.1  1.0  0.05
0.5  1.0  1.0  0.01  1.1  0.03
1.0  0.0  0.2  0.008  3.2  0.2
1.0  1.0  0.8  0.07  1.4  0.07
```

If you don't specify the third parameter `<analyzer name>`, the script searches for `_output.json` in each run, and prints means and standard errors of the means. Meanwhile, if you specify it, the script searches for `_output.json` in each analysis. If the analyzer you specify is `:on_run`, the script prints means and SEMs. However, if the analyzer is `:on_parameter_set`, the script doesn't calculate them and prints the raw values whose names are specified in `outputs` field in a json file you specify in the second argument of the script.

## Author

Naoki Yoshioka

