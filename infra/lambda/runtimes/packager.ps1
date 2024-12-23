# TODO: add variable fixes here too
# Navigate to the directory containing your Python code
Set-Location -Path .\infra\lambda\runtimes\

# Install any dependencies to a new directory named 'package'
pip install --target .\package -r requirements.txt

# Copy your Python code to the 'package' directory
Copy-Item -Path .\config_emr_eks_job.py -Destination .\package\

# Navigate to the 'package' directory
Set-Location -Path .\package\

# Create a ZIP file from the contents of the 'package' directory
Compress-Archive -Path * -DestinationPath ..\lambda_function_payload.zip