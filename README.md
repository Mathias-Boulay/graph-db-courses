# graph-db-courses

Oh good lord this repository is a mess. Kinda don't want to share it, but I guess I have to.

## "sub"repos
I cloned 2 additional repositories which are under the `fraud-detection` and `do5-2025` folders.
Ignore them, they are not relevant.

## Setting up the environment
I ended up creating a file called `setup.sh` to set up the environment. 
It contains all the steps that were needed to prepare it for the hackaton.

Note: The strimzi operator was not the nicest to play around with.
It frequently forgot to add all the pods, and I had to keep restarting the operator until it worked. Usually after 3-4 restarts it would work. Perhaps I should instanciate kafka without zookeeper, but I didn't have time to test it.

## Activities

The scala code is within the `spark` submodule. Classes are not organized, so good luck with that.

The output of some scala code is within comments in the code itself.

Note: After bringing more dependencies, I ended up breaking the über jar (also called fat jar). I'm too lazy to fix it. However, note that the über jar is not the best aproach, as you may import classes from the wrong jar, which can create really silly runtime issues. Bringing the dependecies externally would be the best approach.


As for cypher queries and kubernetes deployment, they are scattered across folders called `monday` through `thursday`
The result of some queries are next to the cypher queries themselves.

The output of some activities is in the form of screenshots, inside the `activities_output` folder.

And yes, this repository is a mess.


## Hackaton
See the `hackaton.pdf` file.

