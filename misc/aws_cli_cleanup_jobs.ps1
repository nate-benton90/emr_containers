# Set AWS CLI profile and region
$AWSProfile = "default"
$AWSRegion = "us-east-1"

Write-Output "Fetching list of EMR container virtual clusters..."

# List all EMR container virtual clusters
$RawVirtualClusters = aws emr-containers list-virtual-clusters `
    --profile $AWSProfile `
    --region $AWSRegion `
    --query 'virtualClusters[*].id' `
    --output text

if ([string]::IsNullOrEmpty($RawVirtualClusters)) {
    Write-Output "No virtual clusters found in region $AWSRegion."
    return
}

# Split the raw output into individual cluster IDs
$VirtualClusters = $RawVirtualClusters -split "\s+"

# Loop through each virtual cluster
foreach ($ClusterId in $VirtualClusters) {
    Write-Output "Processing virtual cluster ID: $ClusterId"

    # List all jobs in the virtual cluster
    $RawJobs = aws emr-containers list-job-runs `
        --virtual-cluster-id $ClusterId `
        --profile $AWSProfile `
        --region $AWSRegion `
        --query 'jobRuns[*].id' `
        --output text

    if ([string]::IsNullOrEmpty($RawJobs)) {
        Write-Output "No jobs found in virtual cluster ID: $ClusterId"
    } else {
        # Split the raw output into individual job IDs
        $Jobs = $RawJobs -split "\s+"

        # Loop through and delete each job
        foreach ($JobId in $Jobs) {
            Write-Output "Deleting job ID: $JobId in virtual cluster ID: $ClusterId"
            aws emr-containers cancel-job-run `
                --virtual-cluster-id $ClusterId `
                --id $JobId `
                --profile $AWSProfile `
                --region $AWSRegion
        }
    }
}

Write-Output "Script execution completed."
