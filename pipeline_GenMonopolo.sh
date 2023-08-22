#!/bin/bash

# Rodar o script Python
python run_gen_Monopolo.py -m 1000 2000 3000 4000 -ne 50000

# Definir o diretório de trabalho
workdir="/afs/cern.ch/user/m/matheus/CMSSW_10_6_24/src/MG5_aMC_v2_9_15/SpinZero_DY/Events"

# Criar um arquivo .txt com o caminho completo dos arquivos de saída
echo -n "" > /eos/home-m/matheus/root_monopolos/input_files_list.txt
for run_dir in $(ls -d ${workdir}/run_0?); do
    find "${run_dir}" -name "Monopole_SpinZero_DY_*GeV_*.lhe" >> /eos/home-m/matheus/root_monopolos/input_files_list.txt
done


# Rodar o código ROOT
root.exe -q -b code.C

# Cria a pasta de destino se ela não existir
dest_dir="/eos/home-m/matheus/root_monopolos/SpinZero_DY_root"
mkdir -p $dest_dir

# Copia os arquivos para a pasta de destino
for run_dir in $(ls -d ${workdir}/run_0?); do
    find "${run_dir}" -name "*.*" -exec cp {} $dest_dir \;
done

rm -r /afs/cern.ch/user/m/matheus/CMSSW_10_6_24/src/MG5_aMC_v2_9_15/SpinZero_DY/


