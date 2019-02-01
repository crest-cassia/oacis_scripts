import oacis,os,sys

if oacis.Simulator.where(name="root_find_sample").size() == 0:
    sim = {
        "name": "root_find_sample",
        "command": f"python {os.path.abspath(os.path.dirname(os.path.realpath(__file__)))}/sample_sim.py > _output.json",
        "support_input_json": True,
        "parameter_definitions": [
            {"key": "p1", "type": "Float", "default": 0.0},
            {"key": "p2", "type": "Float", "default": 0.0}
          ],
          "executable_on": [ oacis.Host.find_by_name("localhost")]
        }
    oacis.Simulator.create(sim)
    print("A new simulator 'root_find_sample' was created.")
else:
    print("'root_find_sample' already exists")
