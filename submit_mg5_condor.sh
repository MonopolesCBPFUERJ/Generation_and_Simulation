#!/bin/bash

: '
Script for generating events using MadGraph for different configurations of monopole masses and spins.

Phases:
1. Generate events for monopoles with spin "half" and process "photon_fusion" for masses of 800, 1000, 1200 and 1400.
2. Generate events for monopoles with "zero" spin and "photon_fusion" process for masses of 800, 1000, 1200 and 1400.
3. Generate events for monopoles with spin "half" and process "drell_yan" for masses of 800, 1000, 1200 and 1400.
4. Generate events for monopoles with spin "zero" and process "drell_yan" for masses of 800, 1000, 1200 and 1400.


######## Drell Yan Process ########

q                                    M+
  *                                *
     *                          *
        *                    *
           *      Z*/γ    *
            **************
           *              *
        *                    *
    *                           *
*                                  *
q̄                                    M-

######## Photon Fusion Process ########


γ                                     M+
  *                                *
     *                          *
        *                    *
           *              *
            **************
           *              *
        *                    *
    *                           *
*                                  *
γ                                    M-


Lower limits on the mass of magnetic monopoles and HECOs (in TeV) at 95% confidence level in models of
                  spin-0 and spin-1/2 Drell-Yan (DY) and photon-fusion (PF) pair production
 __________________________________________________________________________________________________                  
|                                                                                                  |   
| Process and Spin | |g| = 1gD | |g| = 2gD | |z| = 20 | |z| = 40 | |z| = 60 | |z| = 80 | |z| = 100 |
|------------------|-----------|-----------|----------|----------|----------|----------|-----------|
|   DY spin-0      | 2.1       | 2.1       | 1.4      | 1.8      | 1.9      | 1.8      | 1.7       |
|   DY spin-1/2    | 2.6       | 2.5       | 1.8      | 2.2      | 2.2      | 2.1      | 1.9       |
|   PF spin-0      | 3.4       | 3.5       | 2.1      | 2.8      | 2.9      | 2.8      | 2.5       |
|   PF spin-1/2    | 3.6       | 3.7       | 2.5      | 3.1      | 3.1      | 3.0      | 2.5       |
|                                                                                                  |
|                https://arxiv.org/pdf/2308.04835.pdf --> Table 2, pag 13                          |
|__________________________________________________________________________________________________|
'

python3 Generation_Monopolo_MG5.py -mass 3600 -events 10000 -itera 10 -process photon_fusion -spin half
python3 Generation_Monopolo_MG5.py -mass 3700 -events 10000 -itera 10 -process photon_fusion -spin half
python3 Generation_Monopolo_MG5.py -mass 3800 -events 10000 -itera 10 -process photon_fusion -spin half
python3 Generation_Monopolo_MG5.py -mass 3900 -events 10000 -itera 10 -process photon_fusion -spin half
python3 Generation_Monopolo_MG5.py -mass 4000 -events 10000 -itera 10 -process photon_fusion -spin half

python3 Generation_Monopolo_MG5.py -mass 3400  -events 10000 -itera 10 -process photon_fusion -spin zero
python3 Generation_Monopolo_MG5.py -mass 3500  -events 10000 -itera 10 -process photon_fusion -spin zero
python3 Generation_Monopolo_MG5.py -mass 3600  -events 10000 -itera 10 -process photon_fusion -spin zero
python3 Generation_Monopolo_MG5.py -mass 3700  -events 10000 -itera 10 -process photon_fusion -spin zero
python3 Generation_Monopolo_MG5.py -mass 3800  -events 10000 -itera 10 -process photon_fusion -spin zero

python3 Generation_Monopolo_MG5.py -mass 2600 -events 10000 -itera 10 -process drell_yan -spin half
python3 Generation_Monopolo_MG5.py -mass 2700 -events 10000 -itera 10 -process drell_yan -spin half
python3 Generation_Monopolo_MG5.py -mass 2800 -events 10000 -itera 10 -process drell_yan -spin half
python3 Generation_Monopolo_MG5.py -mass 2900 -events 10000 -itera 10 -process drell_yan -spin half
python3 Generation_Monopolo_MG5.py -mass 3000 -events 10000 -itera 10 -process drell_yan -spin half

python3 Generation_Monopolo_MG5.py -mass 2100 -events 10000 -itera 10 -process drell_yan -spin zero
python3 Generation_Monopolo_MG5.py -mass 2200 -events 10000 -itera 10 -process drell_yan -spin zero
python3 Generation_Monopolo_MG5.py -mass 2300 -events 10000 -itera 10 -process drell_yan -spin zero
python3 Generation_Monopolo_MG5.py -mass 2400 -events 10000 -itera 10 -process drell_yan -spin zero
python3 Generation_Monopolo_MG5.py -mass 2500 -events 10000 -itera 10 -process drell_yan -spin zero

touch ListFile_condor.txt
find /eos/home-m/matheus/magnetic_monopole_output/*.lhe > /afs/cern.ch/user/m/matheus/CMSSW_10_6_23/src/ListFile_condor.txt
