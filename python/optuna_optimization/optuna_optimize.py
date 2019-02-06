import pprint
import oacis
import optuna

# simulator
sim = oacis.Simulator.find_by_name("NS_model")

base_param = {"l": 200, "v":5, "rho": 0.3, "p":0.1, "t_init": 500, "t_measure": 10000}

tuned_params = {
    "v": (lambda t: t.suggest_int("v", 3, 7) ),
    "rho": (lambda t: t.suggest_discrete_uniform("rho", 0.01, 0.9, 0.01) ),
    "p": (lambda t: t.suggest_discrete_uniform("p", 0, 0.5, 0.01) )
}

num_runs = 1   # number of runs for each ParameterSet

host = oacis.Host.find_by_name("localhost")
host_param = {}

result_key = "flow"


def objective(trial):
    param = base_param.copy()
    for key,suggest in tuned_params.items():
        param[key] = suggest(trial)
    ps = sim.find_or_create_parameter_set(param)
    runs = ps.find_or_create_runs_upto( num_runs, submitted_to=host, host_param=host_param )
    oacis.OacisWatcher.await_ps(ps)
    return -ps.average_result(result_key)[0]

w = oacis.OacisWatcher()
def main():
    sampler = optuna.samplers.TPESampler(seed=1234)   # to fix the seed, we explicitly initialize TPESampler
    study = optuna.create_study(sampler=sampler)
    study.optimize(objective, n_trials=5)
    pprint.pprint(study.best_params)
w.do_async(main)
w.loop()

