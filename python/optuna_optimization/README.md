# Parameter optimization by TPE algorithm using Optuna

A script for parameter optimization problem using the TPE algorithm [1].
It finds a ParameterSet which gives the minimum (or maximum) of the simulation result via iterated simulations.

TPE (Tree-structured Parzen Estimator) is an algorithm typically used for hyperparameter tuning for machine learning. [Optuna](https://github.com/pfnet/optuna) is a library implementing the hyperparameter optimization.
This algorithm is effective when the evaluation of the objective function needs a long time.

[1] Bergstra, James S., et al. "Algorithms for hyper-parameter optimization." Advances in neural information processing systems. 2011.

In this sample, we used Optuna to find a best set of parameters for a traffic simulation model [Nagel-Schereckenberg model](https://en.wikipedia.org/wiki/Nagel%E2%80%93Schreckenberg_model) (NS model).
We will find a set of parameters which maximizes the amount of traffic flow. The domains of the parameters are

- v : maximum velocity (3~7)
- p : deceleration probability (0~0.5)
- rho : density of the vehicles (0.01~0.9)

Although we use it for the NS model in this sample, the code is readily applicable to other simulators as well.

We are going to use the DE algorithm implemented in `scipy.optimize.differential_evolution` module.
See the [reference](https://docs.scipy.org/doc/scipy/reference/generated/scipy.optimize.differential_evolution.html) of this package for details.

## Prerequisite

`optuna` library is needed. The code is tested against version 0.7.0.

```
$ pip install optuna==0.7.0
```

Pipenv users may use the following instead.

```
$ pipenv install
```

## Usage

First, register a sample simulator used in this sample. We are going to use this simulator.
https://github.com/yohm/sim_ns_model
Follow the instruction to register the model on OACIS.

You'll find "NS_model" simulator on your OACIS.
This sample simulator has several input parameters, l, v, rho, p, ....

In our setting, l = 200, t_init=500, t_measure=10000 are fixed while the other parameters are subject to change.
To find a solution which maximizes the flow, run the script as the following.

```
$ <oacis_path>/bin/oacis_python optuna_optimize.py 2> log
```

An example of the output is the following.
It typically takes several minutes to complete one generation. (It depends on the "Max # of Jobs" of the host.) It may take a few hours until the whole process get completed.

```
```

Therefore, the optimal parameters found by the DE algorithm is `l = 7`, `rho=0.13` and `p=0`.

It iteratively creates ParameterSets and Runs. When the evaluation of a ParameterSet is complete, populations in the next generations are created.

You'll find something like the following if you make a heatmap of flow as a function of rho and p.

![plot](plot_flow_rho_p.png "Amount of traffic flow as a function of rho and p")

## Author

@yohm

