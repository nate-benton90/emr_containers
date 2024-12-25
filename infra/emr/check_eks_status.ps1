# Variables
$ClusterName = "foo-emr-eks-cluster"
$MaxRetries = 20
$SleepInterval = 30 # seconds

# Poll for EKS cluster status
for ($i = 1; $i -le $MaxRetries; $i++) {
    $Status = (aws eks describe-cluster --name $ClusterName --query "cluster.status" --output text --region us-east-1)

    Write-Output "Attempt $($i): Cluster status is '${Status}'"

    if ($Status -eq "ACTIVE") {
        Write-Output "Cluster is ACTIVE. Proceeding with Terraform apply..."
        exit 0
    }

    Write-Output "Cluster is not ready. Retrying in $SleepInterval seconds..."
    Start-Sleep -Seconds $SleepInterval
}

Write-Error "ERROR: Cluster did not reach ACTIVE state within $($MaxRetries * $SleepInterval) seconds."
exit 1
