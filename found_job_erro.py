import os

# Directory where the .err files are located
dir_path = 'output'
# Base path for the files that failed
base_path = '/eos/home-m/matheus/magnetic_monopole_output/'

# Error patterns to look for
error_patterns = [
    "Fatal system signal has occurred during exit",
    "condor_exec.exe: line 97:   197 Aborted                 (core dumped) cmsRun",
    "No such file or directory",
    "FileOpenError",
    "Begin Fatal Exception"
]

# List to store the files that failed
failed_files = []

# Loop through all the files in the directory
for filename in os.listdir(dir_path):
    if filename.endswith('.out'):
        with open(os.path.join(dir_path, filename), 'r') as file:
            content = file.read()
            # Check if any of the error patterns are in the content of the file
            if any(pattern in content for pattern in error_patterns):
                # Look for the path of the file that failed
                for line in content.splitlines():
                    if base_path in line and "Initiating request to open LHE file file:" in line:
                        # Extract only the path of the file
                        failed_file_path = line.split("file:")[-1].strip()
                        failed_files.append(failed_file_path)
                        # Print the name of the .err file and the associated .lhe file that failed
                        print(f"Found error in: {filename} -> Files that failed: {failed_file_path}")

# Write the files that failed to a .txt file
with open('failed_jobs.txt', 'w') as output_file:
    for failed_file in failed_files:
        output_file.write(failed_file + '\n')

print(f"\n{len(failed_files)} files failed. See 'failed_jobs.txt' for details.")
