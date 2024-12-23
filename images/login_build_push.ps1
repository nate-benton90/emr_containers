param (
    [string]$Region,
    [string]$AccountId,
    [string]$RepositoryUrl,
    [string]$ImagePath
)

aws ecr get-login-password --region $Region | docker login --username AWS --password-stdin $AccountId.dkr.ecr.$Region.amazonaws.com
docker build -t $RepositoryUrl:latest $ImagePath
docker push $RepositoryUrl:latest
