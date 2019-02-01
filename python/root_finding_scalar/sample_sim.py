import json,random

def func(x):
    return x**2 - 1 + random.gauss(0.0, 0.2)

with open('_input.json') as f:
    param = json.load(f)
    x = param['p1']
    out = {"r1": func(x)}
    print(json.dumps(out))

