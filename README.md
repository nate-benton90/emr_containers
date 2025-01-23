# EMR Containers (i.e. EMR on EKS)

Using **AWS EMR on EKS** (also known as *EMR Containers*), this repository provides practical examples and detailed explanations for using this specific service.

![Main AWS Resource Image](misc/emr_eks.png)

Although this service is relatively new and less commonly used than the traditional EMR service, it is a powerful tool for users already leveraging EKS who want to run Spark jobs on their EKS cluster. While there are other examples available online, most lack a comprehensive start-to-finish guide for setting up and using this service, including building infrastructure and configuring policies from scratch.

---

## Assumptions for Local Machine Setup

Before proceeding with this project, ensure the following prerequisites are met on your local machine:

1. **AWS CLI**: Installed and configured with valid credentials (I used this version/setup: `aws-cli/2.4.5 Python/3.8.8 Windows/10 exe/AMD64 prompt/off`). Have a specific profile name ready if required (other than so-called `default`).
2. **Terraform**: Version `v0.14.7` was used. If issues arise with versioning, use [tfenv](https://github.com/tfutils/tfenv) to manage multiple Terraform versions.
3. **PowerShell**: Version `5.1.22621.2506` was used to run scripts.
4. **Docker**: Configuration may vary depending on your OS and use case (solo vs. company). Below is the setup used for this project (Windows 11, solo setup):
    ```plaintext
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
5. **eksctl**: Installed via Chocolatey (`choco install eksctl`), version `0.179.0`.

---

## Disclosures

- Deploying and using the resources in this project will incur AWS costs, especially in production environments. The default setup is configured to minimize costs (~$75/month for the cheapest EKS cluster). 
- To avoid unnecessary charges, destroy the resources when not in use (e.g., using the `terraform destroy` command).

---

## Tutorial: Initial Setup

Follow these steps to set up the necessary resources for EMR on EKS:

1. Clone the repository and switch to the `main` branch.
2. Run `terraform init` from the root directory.
3. Run `terraform apply` and confirm the changes. Ensure you have:
    - Proper AWS profile permissions and CLI configuration.
    - Installed Docker, PowerShell, and eksctl as mentioned in the [Assumptions](#assumptions-for-local-machine-setup).
4. Wait for the resources to be created (10–30 minutes, depending on your AWS region and resources).

---

## Appendix

### Useful Links
- [Managing EMR on EKS with Terraform](https://cevo.com.au/post/manage-emr-on-eks-with-terraform/)
- [AWS EMR on EKS Development Guide](https://docs.aws.amazon.com/emr/latest/EMR-on-EKS-DevelopmentGuide/setting-up.html)
- [Guide to Securely Upgrading EKS Clusters](https://www.fairwinds.com/blog/guide-securely-upgrading-eks-clusters)
