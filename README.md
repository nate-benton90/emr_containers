# EMR Containers (i.e. EMR on EKS)

* Using AWS resource for EMR on EKS (i.e. *EMR Containers*), I provide grounded, applicable examples (and explanations) for using this specific service.

![main aws resource image](misc/emr_eks.png)

Although this service is still somewhat new and not as widely used as the traditional EMR service, it is a powerful tool for those who are already using EKS and want to run Spark jobs on their EKS cluster. At this
points, you can find other examples online but most don't provide a start-to-finish guide on not only how to use this service but build it from nothing (infastructure and policy included).

## Assumptions of local machine setup

Before trying to do anything related to this project (other than reading this file), you shoud have the following installed on your local machine:
1] AWS CLI (with valid credentials and a specific profile name in-mind as needed)
2] Terraform (this project was developed and run entirely on this version: `v0.14.7`).
3] If you have an issue with #2, try leveraging the `tfenv` tool to manage multiple versions of Terraform.
4] PowerShell (to run various scripts in this project), the version that was used start-to-finish was this: `5.1.22621.2506`
5] Docker (this setup will vary depending on your OS and if you're working solo vs. associated with a company that will leverage this technology and thereby require the absurd liscensing component). As for my machine and setup, I'm on Windows 11 and working solo, so my entire Docker configuration is this:
```
Client:
 Cloud integration: v1.0.35+desktop.11
 Version:           25.0.3
 API version:       1.44
 Go version:        go1.21.6
 Git commit:        4debf41
 Built:             Tue Feb  6 21:13:02 2024
 OS/Arch:           windows/amd64
 Context:           default

Server: Docker Desktop 4.28.0 (139021)
 Engine:
  Version:          25.0.3
  API version:      1.44 (minimum version 1.24)
  Go version:       go1.21.6
  Git commit:       f417435
  Built:            Tue Feb  6 21:14:25 2024
  OS/Arch:          linux/amd64
  Experimental:     false
 containerd:
  Version:          1.6.28
  GitCommit:        ae07eda36dd25f8a1b98dfbf587313b99c0190bb
 runc:
  Version:          1.1.12
  GitCommit:        v1.1.12-0-g51d5e94
 docker-init:
  Version:          0.19.0
  GitCommit:        de40ad0
```
6] eksctl (I install this with choco on my Windows machine) with version `0.179.0`.

## Appendix

Useful links:
1] https://cevo.com.au/post/manage-emr-on-eks-with-terraform/
2] https://docs.aws.amazon.com/emr/latest/EMR-on-EKS-DevelopmentGuide/setting-up.html
3] https://www.fairwinds.com/blog/guide-securely-upgrading-eks-clusters
