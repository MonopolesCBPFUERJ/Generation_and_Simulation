# Generation and Simulation

## Instructions for Generating Events with MadGraph

- **Download the Release**:
    ```bash
    cmsrel CMSSW_10_6_24

- **Access the `src` Directory**:
    Navigate to the directory using:
    ```
    cd CMSSW_10_6_24/src
- Download the latest LTS version of MadGraph5 (http://madgraph.phys.ucl.ac.be/):
   ```
   wget https://launchpad.net/mg5amcnlo/lts/2.9.x/+download/MG5_aMC_v2.9.16.tar.gz
- Unzip the file using:
  ```
  tar -xzvf MG5_aMC_v2.9.16

- Create a virtual machine with python3 to run MadGraph.
- 
     ```
     python3 -m venv hepenv
     . hepenv/bin/activate
    ```
- Enter the MadGraph5 environment using
     ```
     ./bin/mg5_aMC
- Download packages at a time:
    ```
    install MadAnalysis5
    install lhapdf6
Checks in the MadGraph environment itself that both files are installed using display options

- Make sure the `LHAPDF_DATA_PATH` environment variable is set correctly. You can verify this using the echo command in a terminal: `echo $LHAPDF_DATA_PATH`. This should return the path to the directory containing the `pdfsets.index` file. If it doesn't return anything or returns the wrong path, you can set the environment variable correctly with the export command:
   ```bash
   export LHAPDF_DATA_PATH=/afs/cern.ch/user/m/matheus/CMSSW_10_6_24/src/MG5_aMC_v2_9_15/HEPTools/lhapdf6_py3/share/LHAPDF

- Open the `~/.bashrc` file in a text editor. You can use any editor you like. For example, to open the file in the *vim* editor, you would use the command: `vi ~/.bashrc`. Add the following line to the end of the file:
   ```bash
   export LHAPDF_DATA_PATH=/afs/cern.ch/user/m/matheus/CMSSW_10_6_24/src/MG5_aMC_v2_9_15/HEPTools/lhapdf6_py3/share/LHAPDF

- If this last step doesn't work, it's likely that MadGraph5 is not finding lhapdf. If that happen:

   - you need to determine where lhapdf-config is on your system. If you have already installed LHAPDF6, you can use the command:
     ```bash
     which lhapdf-config

   - If this command returns a path, you must use that path. Otherwise, if the command returns nothing, it means either you don't have LHAPDF6 installed correctly, or it isn't in your `$PATH`.

   - Tell MadGraph about the lhapdf-config:

   - Assuming that the which command returned a path like /home/username/lhapdf/bin/lhapdf-config, you would configure MadGraph5 like this:
     ```
     MG5_aMC> set lhapdf /home/username/lhapdf/bin/lhapdf-config
   - Replace `/home/username/lhapdf/bin/` with the exact path you got from the which command.

   - If you don't have LHAPDF6 installed or if lhapdf-config is not found, you need to install LHAPDF6 or add the directory containing lhapdf-config to your `$PATH`. After following these steps, MadGraph5 should be able to use LHAPDF6 without any problems.
  
   
With MadGraph5 configured, inside the directory execute the commands:

    
     voms-proxy-init --rfc --voms cms -valid 192:00
     cmsenv

Now you may be able to run the code for generating the events.
The `Generation_Monopolo_MG5.py` file is responsible for the entire generation process. On lines 39 and 40 you should change the paths to the absolute path of the madgraph(`MADGRAPH_PATH_RUN`) and the output in your `eos` where the generation will be saved (`OUTPUT_DIR`).

    
     MADGRAPH_PATH_RUN = '/afs/cern.ch/user/m/matheus/CMSSW_10_6_24/src/MG5_aMC_v2_9_15/bin/mg5_aMC'
     OUTPUT_DIR = '/eos/home-m/matheus/magnetic_monopole_output'

The shellcode `submit_mg5_condor.sh` is the executable that will be allocated to the condor (`condor_sub_mg5.sub`)

If you want to generate local code, just run it locally using

   ```
   python3 Generation_Monopolo_MG5.py -mass 1000 -events 100 -itera 10 -process photon_fusion -spin half

   -mass 1000 --> Monopole mass
   -events 100 --> How many events do you want to generate
   -itera 10 --> Number of times you want to generate the same code
   -process photon_fusion --> Which process do you want to run: Drell Yan or Photon Fusion
   -spin half --> Which spin do you want: Spin 0 or Spin 1/2
