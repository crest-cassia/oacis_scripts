import pprint
import oacis
from scipy.optimize import differential_evolution

# simulator
sim = oacis.Simulator.find_by_name("NS_model")

base_param = {"l": 200, "v":5, "rho": 0.3, "p":0.1, "t_init": 500, "t_measure": 10000}

tuned_params = ["v", "rho", "p"]
domains = [(3,7), (0.01,0.9), (0,0.5)]
rounding = [   # functions to map parameters to rounded values
        lambda x: round(x),
        lambda x: round(x,2),
        lambda x: round(x,2)
        ]

num_runs = 1   # number of runs for each ParameterSet

host = oacis.Host.find_by_name("localhost")
host_param = {}

result_key = "flow"

def f(x):
    ps = x_to_ps(x)
    oacis.OacisWatcher.await_ps(ps)
    return -ps.average_result(result_key)[0]

def x_to_ps(x):
    param = base_param.copy()
    for i,x in enumerate(x):
        key = tuned_params[i]
        param[key] = rounding[i](x)
    ps = sim.find_or_create_parameter_set(param)
    runs = ps.find_or_create_runs_upto( num_runs, submitted_to=host, host_param=host_param )
    return ps

def map_func(f, xs):
    ps_array = [x_to_ps(x) for x in xs]
    oacis.OacisWatcher.await_all_ps(ps_array)
    return [ -ps.average_result(result_key)[0] for ps in ps_array ]  # to maximize the result, '-' sign is added

w = oacis.OacisWatcher()
def main():
    result = differential_evolution(f, domains, seed=1234, maxiter=30, updating='deferred', workers=map_func, disp=True)
    pprint.pprint(result)
w.do_async(main)
w.loop()

