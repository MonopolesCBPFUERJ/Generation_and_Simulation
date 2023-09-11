import os

# Diretório onde os arquivos .err estão localizados
dir_path = 'output'
# Caminho base para os arquivos que falharam
base_path = '/eos/home-m/matheus/magnetic_monopole_output/'

# Padrões de erro para procurar
error_patterns = [
    "Fatal system signal has occurred during exit",
    "condor_exec.exe: line 97:   197 Aborted                 (core dumped) cmsRun"
]

# Lista para armazenar os arquivos que falharam
failed_files = []

# Percorre todos os arquivos no diretório
for filename in os.listdir(dir_path):
    if filename.endswith('.err'):
        with open(os.path.join(dir_path, filename), 'r') as file:
            content = file.read()
            # Verifica se algum dos padrões de erro está no conteúdo do arquivo
            if all(pattern in content for pattern in error_patterns):
                # Procura pelo caminho do arquivo que falhou
                for line in content.splitlines():
                    if base_path in line and "Initiating request to open LHE file file:" in line:
                        # Extrai apenas o caminho do arquivo
                        failed_file_path = line.split("file:")[-1].strip()
                        failed_files.append(failed_file_path)
                        # Printa o nome do arquivo .err e o arquivo .lhe associado que falhou
                        print(f"Found Erro in: {filename} -> Files that failed: {failed_file_path}")

# Escreve os arquivos que falharam em um arquivo .txt
with open('failed_jobs.txt', 'w') as output_file:
    for failed_file in failed_files:
        output_file.write(failed_file + '\n')

print(f"\n{len(failed_files)} File Failed. See 'failed_jobs.txt' to detales.")
