import os
import subprocess
import argparse
import gzip
import shutil

# How execute --> python3 run_gen_Monopolo.py -m 1000 2000 3000 4000 -ne 50000

# Function to parse command line arguments
def parse_arguments():
    parser = argparse.ArgumentParser(description='Generate MadGraph simulations with different mass values.')
    parser.add_argument('-m', '--mass_values', metavar='M', type=int, nargs='+', required=True,
                        help='a list of mass values for particle 4110000')
    parser.add_argument('-ne', '--num_events', metavar='N', type=int, default=100000,
                        help='number of events to be generated (default: 100000)')
    args = parser.parse_args()
    return args.mass_values, args.num_events

# Function to parse command line arguments
madgraph_directory = '/afs/cern.ch/user/m/matheus/CMSSW_10_6_24/src/MG5_aMC_v2_9_15'

# Specify the path to the configuration file
config_file = '/afs/cern.ch/user/m/matheus/CMSSW_10_6_24/src/MG5_aMC_v2_9_15/SpinScript.txt'

# Write the configuration file
def write_config_file(mass, num_events):
    with open(config_file, 'w') as f:
        f.write('launch /afs/cern.ch/user/m/matheus/CMSSW_10_6_24/src/MG5_aMC_v2_9_15/SpinZero_DY\n')
        f.write('analysis=madanalysis5\n')
        f.write('set run_card ebeam1 6500\n')
        f.write('set run_card ebeam2 6500\n')
        f.write('set run_card lpp1 1\n')
        f.write('set run_card lpp2 1\n')
        f.write('set run_card pdlabel nn23lo1\n')
        f.write('set run_card lhaid 230000\n') #82000
        f.write(f'set run_card nevents {num_events}\n')
        f.write('set run_card dynamical_scale_choice -1\n')
        f.write('set run_card fixed_couplings False\n')
        f.write('set param_card mass 25 125\n')
        f.write(f'set param_card mass 4110000 {mass}\n')
        f.write('set param_card decay 4110000 0.000000e+0\n')
        f.write('set param_card gch 1 1.0\n')

def unzip_lhe_file(input_file, output_file):
    with gzip.open(input_file, 'rb') as f_in:
        with open(output_file, 'wb') as f_out:
            shutil.copyfileobj(f_in, f_out)

def rename_file(old_name, new_name):
    os.rename(old_name, new_name)

# Analyze the command line arguments
mass_values, num_events = parse_arguments()

Events_file = '/afs/cern.ch/user/m/matheus/CMSSW_10_6_24/src/MG5_aMC_v2_9_15/SpinZero_DY/Events'
# Execute MadGraph for each mass value
for i, mass in enumerate(mass_values, start=1):
    print(f'Running simulation for mass {mass} GeV with {num_events} events...')
    write_config_file(mass, num_events)
    subprocess.run(['./bin/mg5_aMC', config_file], cwd=madgraph_directory)

    run_dir = os.path.join(Events_file, f'run_0{i}')
    unzip_lhe_file(os.path.join(run_dir, 'unweighted_events.lhe.gz'),
                   os.path.join(run_dir, 'unweighted_events.lhe'))
    rename_file(os.path.join(run_dir, 'unweighted_events.lhe'),
                os.path.join(run_dir, f'Monopole_SpinZero_DY_{mass}GeV_{num_events}.lhe'))

os.remove(config_file)
