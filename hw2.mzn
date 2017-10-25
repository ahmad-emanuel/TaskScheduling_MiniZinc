include "globals.mzn";

int: tasks; % number of tasks
set of int: TASKS = 1..tasks;

int: machines; % number of machines
set of int: MACHINES = 1..machines;

% machine specified duration 
array[MACHINES,TASKS] of int: duration;

int: resources; % number of resources
set of int: RESOURCES = 1..resources;

% Recourse consumption of every task
array[TASKS,RESOURCES] of int: rconsumption;

% Graph G=(Tasks, Arcs)
array[TASKS,TASKS] of int: precedes;

% maximum resource availability machine specified
array[MACHINES,RESOURCES] of int: rmax;

% maximum machine usage
array[MACHINES] of int: tired;

int:maxtime; % maximum Time
set of int: TIME =1..maxtime;

% Variables
array[MACHINES,TASKS] of var 0..1: x;
array[TASKS] of var TIME: start;
var TIME: span;
array[TASKS] of var MACHINES: assign;
%constraints
constraint forall (i in TASKS, j in TASKS, m in MACHINES)
( (precedes[i,j] * start[i]) + ( precedes[i,j] * duration[m,i] * x[m,i]) <= ( precedes[i,j] * start [j]));

constraint forall (t in TASKS)
(sum (m in MACHINES) (x[m,t]) = 1);

constraint forall (m in MACHINES)
(sum (t in TASKS) (x[m,t]) <= tired[m]);

constraint forall(r in RESOURCES, m in MACHINES)
(cumulative (start , [duration[m,t] | t in TASKS] , [x[m,t]*rconsumption[t,r]|t in TASKS] , rmax[m,r]));

constraint forall (t in TASKS, m in MACHINES)
(span >= start[t] + (duration[m,t] * x[m,t]));

constraint forall (t in TASKS, m in MACHINES)
(if x[m,t] == 1 then assign[t]=m else true endif);

solve minimize span;

output["Solution: " ++ show(span)++"\n"] ++[ "Task " ++ show(t) ++":  Machine "++ show(assign[t]) ++"; Start " ++ show(start[t]) ++" "| t in TASKS];
     %++["\n"]++ [show(x[m,t]) ++ if t == tasks then "\n" else " " endif | m in MACHINES,t in TASKS];