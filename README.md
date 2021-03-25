# PlatoonFalsification

This is a repository for the project String Stability Assurance

## Install
- Install [Breach](https://github.com/decyphir/breach). (Ver. 1.2.13 is recommended.)
  - Run `git reset --hard 89d1f74`
  - Run InstallBreach.m
  - Change the random seed in Line 326 of `Core/Algos/@BreachProblem/BreachProblem.m`
- Clone this repository.
   `git clone https://github.com/choshina/PlatoonFalsification.git`
   
## Usage
- Configure `phi_Train.m`
  - Add the path of Breach
  - Modify the values of parameters
- Run `phi_Train.m` in the Matlab commandline.
- Check the results in `results/`
