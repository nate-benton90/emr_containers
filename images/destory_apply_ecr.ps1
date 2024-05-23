# TODO: again, add variables for entire repo - specifically name, account id, and region
$repoName = "foo-emr-eks-spark-image"
$accountId = "640048293282"
$region = "us-east-1"

$images = (aws ecr list-images --repository-name $repoName --region $region | ConvertFrom-Json).imageIds

if ($images.Count -gt 0) {
    $imageIds = $images | ForEach-Object { @{ imageDigest = $_.imageDigest } }
    aws ecr batch-delete-image --repository-name $repoName --region $region --image-ids (ConvertTo-Json $imageIds)
}
