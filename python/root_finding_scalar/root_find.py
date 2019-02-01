import oacis
from scipy import optimize

# simulator
sim = oacis.Simulator.find_by_name("root_find_sample")

base_param = {"p1": 0, "p2": 0}

tuned_param = "p1"
param_range = (0,10)

xtol = 0.1
maxiter = 20

num_runs = 1   # number of runs for each ParameterSet

host = oacis.Host.find_by_name("localhost")
host_param = {}

result_key = "r1"
result_target = 2


def func(p1):
    param = base_param.copy()
    param["p1"] = p1
    ps = sim.find_or_create_parameter_set(param)
    runs = ps.find_or_create_runs_upto( num_runs, submitted_to=host, host_param=host_param )
    oacis.OacisWatcher.await_ps( ps )
    return ps.average_result(result_key)[0] - result_target

w = oacis.OacisWatcher()
def f():
    x = optimize.brentq(func, param_range[0], param_range[1], xtol=xtol, maxiter=maxiter, full_output=True)
    print(x)
w.do_async(f)
w.loop()

