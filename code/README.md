# README - Fluence Mapping via Trajectory Optimization

This code uses trajectory optimization to solve the fluence mapping problem:
compute the leaf and dose-rate trajectories to deliver a desired fluence dose profile to a patient.
Here we model a single leaf pair, although the real device has many leaves.
These leaves are moved to selectively block the radiation emitted by a single common source.

## Alogorithm:
- **Nested Optimization  --**
We use a nested optimization framework: an outer optimization computes the dose profile, while an inner optimization computes the leaf trajectories.
This is done so that the problem scales well when there are many leaves, which are coupled by a single dose profile.
- **Radiation-Blocking model  --**
One of the challenges of computing the fluence that is delivered to the target is an integral where the domain is related to the inverse of the leaf trajectory.
This integral can be rewritten so that it uses the full time-domain of the problem,
and the leaf-blocking is captured by a blocking function, which is multiplied by the original integrand.
To avoid discontinuities in the gradients of the optimization, I apply smoothing to this blocking function.
- **Trajectory Representation  --**
Both the dose-rate and leaf trajectories are represented as piece-wise linear functions of time.
For simplicity and faster computation, I use a relatively small number of segments, and match the knot points between all three trajectories.
There are two reasons to select piece-wise linear trajectories.
First, it makes the limits on dose rate and leaf position and velocity easy to compute and enforce.
The second is that it forces a relatively simple trajectory, which, combined with a regularization term in the objective function, helps the optimization avoid local minima.
