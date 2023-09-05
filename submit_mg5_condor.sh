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
'

python3 Generation_Monopolo_MG5.py -mass 800 -events 1000 -itera 100 -process photon_fusion -spin half
python3 Generation_Monopolo_MG5.py -mass 1000 -events 1000 -itera 100 -process photon_fusion -spin half
python3 Generation_Monopolo_MG5.py -mass 1200 -events 1000 -itera 100 -process photon_fusion -spin half
python3 Generation_Monopolo_MG5.py -mass 1400 -events 1000 -itera 100 -process photon_fusion -spin half

python3 Generation_Monopolo_MG5.py -mass 800 -events 1000 -itera 100 -process photon_fusion -spin zero
python3 Generation_Monopolo_MG5.py -mass 1000 -events 1000 -itera 100 -process photon_fusion -spin zero
python3 Generation_Monopolo_MG5.py -mass 1200 -events 1000 -itera 100 -process photon_fusion -spin zero
python3 Generation_Monopolo_MG5.py -mass 1400 -events 1000 -itera 100 -process photon_fusion -spin zero

python3 Generation_Monopolo_MG5.py -mass 800 -events 1000 -itera 100 -process drell_yan -spin half
python3 Generation_Monopolo_MG5.py -mass 1000 -events 100 -itera 100 -process drell_yan -spin half
python3 Generation_Monopolo_MG5.py -mass 1200 -events 1000 -itera 100 -process drell_yan -spin half
python3 Generation_Monopolo_MG5.py -mass 1400 -events 1000 -itera 100 -process drell_yan -spin half

python3 Generation_Monopolo_MG5.py -mass 800 -events 1000 -itera 100 -process drell_yan -spin zero
python3 Generation_Monopolo_MG5.py -mass 1000 -events 1000 -itera 100 -process drell_yan -spin zero
python3 Generation_Monopolo_MG5.py -mass 1200 -events 1000 -itera 100 -process drell_yan -spin zero
python3 Generation_Monopolo_MG5.py -mass 1400 -events 1000 -itera 100 -process drell_yan -spin zero