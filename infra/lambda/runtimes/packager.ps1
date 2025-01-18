# Navigate to the directory containing your Python code
Set-Location -Path .\infra\lambda\runtimes\

# Remove any existing 'package' directory or ZIP file to avoid stale artifacts
if (Test-Path -Path .\package) {
    Remove-Item -Recurse -Force .\package
}
if (Test-Path -Path .\lambda_function_payload.zip) {
    Remove-Item -Force .\lambda_function_payload.zip
}

# Install any dependencies to a new directory named 'package'
pip install --target .\package -r requirements.txt

# Copy your Python code to the 'package' directory
Copy-Item -Path .\config_emr_eks_job.py -Destination .\package\

# Navigate to the 'package' directory
Set-Location -Path .\package\

# Create a ZIP file from the contents of the 'package' directory
Compress-Archive -Path * -DestinationPath ..\lambda_function_payload.zip

# Return to the original directory
Set-Location -Path ..\
