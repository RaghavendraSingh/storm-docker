import yaml
import sys

with open(sys.argv[1]) as f:
    list_doc = yaml.load(f)
print(list_doc)
numCores=int(sys.argv[2])
workerPorts=[]
for i in range(1,numCores+1):
    workerPorts.append(6700+i)
print(workerPorts)
list_doc["supervisor.slots.ports"]=workerPorts
with open(sys.argv[1], "w") as f:
    yaml.dump(list_doc, f,default_flow_style=False)
