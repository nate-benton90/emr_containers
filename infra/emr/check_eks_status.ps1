# Variables and hard-coded values
# TODO: add global vars somehow to this or replace with using TF resource dependencies, if possible
$ClusterName = "foo-emr-eks-cluster"
$NodeGroupName = "emr-eks-node-group"
$Region = "us-east-1"
$MaxRetries = 100
$SleepInterval = 30 # seconds

# Poll for EKS cluster and node group readiness
for ($i = 1; $i -le $MaxRetries; $i++) {
    $ClusterStatus = (aws eks describe-cluster --name $ClusterName --query "cluster.status" --output text --region $Region)
    $NodeGroupStatus = (aws eks describe-nodegroup --cluster-name $ClusterName --nodegroup-name $NodeGroupName --query "nodegroup.status" --output text --region $Region)

    Write-Output "Attempt $($i): Cluster status is '${ClusterStatus}', Node group status is '${NodeGroupStatus}'"

    if ($ClusterStatus -eq "ACTIVE" -and $NodeGroupStatus -eq "ACTIVE") {
        Write-Output "Cluster and Node group are ACTIVE. Proceeding with Terraform apply in 60 seconds..."
        Start-Sleep -Seconds 60
        exit 0
    }

    Write-Output "Cluster or Node group is not ready. Retrying in $SleepInterval seconds..."
    Start-Sleep -Seconds $SleepInterval
}

Write-Error "ERROR: Cluster or Node group did not reach ACTIVE state within $($MaxRetries * $SleepInterval) seconds."
exit 1
