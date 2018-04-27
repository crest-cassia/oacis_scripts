# Remove old analyses

Assume you have an analyzer for parameter sets whose `auto_run` flag is "yes".
Now you have to create more runs in order to decrease statistical errors:
If you are not satisfied with their statistics, you have to do again and again.
Then you would realize many junks of old analyses...

Using this script, you can remove all of old analyses from a specified simulator.

## Usage

```
./bin/oacis_ruby remove_old_analyses.rb <simulator name> [<analyzer name>]
```

You must specify a name of a simulator whose analyses would be expected to be removed.
If you don't specify a name of an analyzer, the script removes all of old analyses from the simulator.
If you specify it, old analyses created by the analyzer would be removed.

## Note

This script find old analyses by checking `created_at` fields of analyses.

## Author

Naoki yoshioka

