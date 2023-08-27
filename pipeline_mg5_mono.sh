#!/usr/bin/env sh

: '
This script automates the event generation process using MadGraph for various models and initial conditions.

Pre-requisites:
- MadGraph installed at the specified path.
- Source environments available and paths valid.

Script Features:
1. Initializes the MadGraph environment and Python virtualenv.
2. Defines models and generate commands for specific processes.
3. Generates process directories for model and command combinations.
4. Modifies certain files in the filesystem as needed.
5. Launches event generation in MadGraph for various mass values.
6. Renames and moves output directories to a specified directory, appending iteration suffixes.

Inputs:
- The script does not accept input arguments. All parameters are hard-coded within the script.

Outputs:
- Output directories for each combination of model, command, and mass value, located in "/eos/home-m/matheus/magnetic_monopole_output".
  Each directory contains generated event results and is renamed with an iteration suffix.

Usage:
$ ./pipeline_mg5_mono.sh

Note:
Ensure all paths and prerequisites are available and correct. This script was written for a specific research environment and may need adjustments for different setups.

by Matheus Macedo UERJ-RIO-BRAZIL (matheus.macedo@cern.ch)
'

source /cvmfs/cms.cern.ch/cmsset_default.sh
source /afs/cern.ch/user/m/matheus/hepenv/bin/activate

# Path to MadGraph. Adjust as needed.
MADGRAPH_PATH="/afs/cern.ch/user/m/matheus/CMSSW_10_6_24/src/MG5_aMC_v2_9_15/bin/mg5_aMC"

# List of models.
models=("mono_spinhalf" "mono_spinzero")

# List of generate commands.
generates=("generate a a > mm+ mm-" "generate p p > mm+ mm-")

# Create the output directory outside the loop.
mkdir -p /eos/home-m/matheus/magnetic_monopole_output

for iteration in {1..100}; do

    # First, let's generate all the process directories.
    for model in "${models[@]}"; do
        for generate in "${generates[@]}"; do
            # Create the temporary command file for this combination.
            temp_command_file="temp_commands_${model}.mg5"
            echo "set auto_convert_model T" > $temp_command_file
            echo "import model $model" >> $temp_command_file
            echo "$generate" >> $temp_command_file
            
            # Deciding the directory name based on the model and generate command.
            if [ "$model" == "mono_spinhalf" ]; then
                if [ "$generate" == "generate a a > mm+ mm-" ]; then
                    dir_name="SpinHalf_PF"
                else
                    dir_name="SpinHalf_DY"
                fi
            elif [ "$model" == "mono_spinzero" ]; then
                if [ "$generate" == "generate a a > mm+ mm-" ]; then
                    dir_name="SpinZero_PF"
                else
                    dir_name="SpinZero_DY"
                fi
            fi

            if [ -n "$dir_name" ]; then
                echo "output $dir_name" >> $temp_command_file
                $MADGRAPH_PATH < $temp_command_file
                rm $temp_command_file
            fi
        done
    done

    # Now, outside the MadGraph environment, we will make necessary edits in the file system.
    directories=("SpinHalf_PF" "SpinHalf_DY" "SpinZero_PF" "SpinZero_DY")
    for dir_name in "${directories[@]}"; do
        absolute_path="$PWD/$dir_name/Source/maxparticles.inc"
        file_to_edit="$dir_name/Source/genps.inc"
        if [ -f "$file_to_edit" ]; then
            sed -i "s|'maxparticles.inc'|'$absolute_path'|g" "$file_to_edit"
        else
            echo "File $file_to_edit not found!"
        fi
    done

    # ------------ Next step --> Generate Events ------------ #

    launch_command_file="temp_launch_commands.mg5"

    # Mass values.
    mass_values=(1000 1500 2000)

    # Loop through the directories to execute the launch commands.
    for dir_name in "${directories[@]}"; do
        for mass in "${mass_values[@]}"; do
            echo "launch $dir_name" > $launch_command_file

            # Decide which analysis to use based on the directory name.
            if [ "$dir_name" == "SpinHalf_PF" ] || [ "$dir_name" == "SpinZero_PF" ]; then
                echo "analysis=madanalysis5" >> $launch_command_file
                echo "set run_card pdlabel lhapdf" >> $launch_command_file
                echo "set run_card lhaid 324900" >> $launch_command_file
            else
                echo "analysis=madanalysis4" >> $launch_command_file
                echo "set run_card pdlabel nn23lo1" >> $launch_command_file
                echo "set run_card lhaid 230000" >> $launch_command_file
            fi

            # Common commands for all directories.
            echo "set run_card ebeam1 6500." >> $launch_command_file
            echo "set run_card ebeam2 6500" >> $launch_command_file
            echo "set run_card lpp1 1" >> $launch_command_file
            echo "set run_card lpp2 1" >> $launch_command_file
            echo "set run_card nevents 10000" >> $launch_command_file
            echo "set run_card dynamical_scale_choice -1" >> $launch_command_file
            echo "set run_card fixed_couplings False" >> $launch_command_file
            echo "set param_card mass 25 125" >> $launch_command_file
            echo "set param_card mass 4110000 $mass" >> $launch_command_file
            echo "set param_card decay 4110000 0.000000e+0" >> $launch_command_file
            echo "set param_card gch 1 1.0" >> $launch_command_file
            
            # Execute the commands in MadGraph.
            $MADGRAPH_PATH < $launch_command_file
            
            # Loop through all the run_XX directories.
            for run_dir in "$dir_name/Events"/run_*/; do
                if [ -f "${run_dir}/unweighted_events.lhe.gz" ]; then
                    gunzip "${run_dir}/unweighted_events.lhe.gz"
                    mv "${run_dir}/unweighted_events.lhe" "/eos/home-m/matheus/magnetic_monopole_output/${dir_name}_mass_${mass}_run_${iteration}.lhe"
                fi
            done
            
            # Remove the temporary command file.
            rm $launch_command_file

        done

        # Apagar o diretório após mover os arquivos .lhe
        rm -r "$dir_name"

    done
done
