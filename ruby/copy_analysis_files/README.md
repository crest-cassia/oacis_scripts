# Copy output files of analyses recursively

It is useful if you have to compare results of some of parameter sets such as scaling analysis of cluster size distributions.

## Usage

```
./bin/oacis_ruby copy_analysis_files.rb <simulator name> <json> <directory>
```

You have to specify absolute paths of a json file and directory to copy files.

`template.json` is a sample of the json file.

```
{
  "constants": {
    "x_length": 128,
    "y_length": 128
  },
  "variables": [
    {
      "name": "fire_rate",
      "short": "f"
    },
    {
      "name": "pop_rate",
      "short": "p"
    }
  ],
  "analyzers": [
    {
      "name": "frequency_size_distribution",
      "files": ["frequency_size_distribution.dat", "frequency_size_distribution.eps"]
    },
    {
      "name": "waiting_time_distribution",
      "files": ["waiting_time_distribution.dat", "waiting_time_distribution.eps"]
    }
  ]
}
```

The script searches for parameter sets whose parameters specified by `constants` are fixed.
Each file would copy to the directory `"<directory>/f#{fire_rate}/p#{pop_rate}/` in the case of the above example.
Copied files are specified in the `analyzers` field.

## Author

Naoki Yoshioka

