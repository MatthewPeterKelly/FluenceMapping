# README - Fluence Mapping via Trajectory Optimization

This code is a first-attempt to use trajectory optimization to solve the fluence mapping problem:
compute the leaf and dose-rate trajectories to deliver a desired fluence dose profile to a patient.
Here we model a single leaf pair, although the real device has many leaves.
These leaves are moved to selectively block the radiation emmitted by a single common source.

## Alogorithm:
- **Nested Optimization  --**
We use a nested optimization framework
