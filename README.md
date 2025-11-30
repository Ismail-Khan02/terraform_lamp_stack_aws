# AWS LAMP Stack with Terraform

This project automates the deployment of a LAMP stack (Linux, Apache, MariaDB, PHP) on AWS using Terraform. It provisions a custom VPC network and deploys an Amazon Linux 2023 instance pre-configured with a dynamic PHP application connected to a database.

## 🏗 Architecture

* **Provider:** AWS (Region: `us-east-1` by default)
* **OS:** Amazon Linux 2023 (AL2023)
* **Network:**
    * Custom VPC (`10.0.0.0/16`)
    * Public Subnet (`10.0.1.0/24`)
    * Internet Gateway & Route Table (Public Access)
* **Compute:** `t2.micro` Instance
* **Security:** Security Group allowing HTTP (80) and SSH (22) from anywhere (`0.0.0.0/0`).
* **Software Stack:** Apache (httpd), MariaDB 10.5, PHP 8.x.

## 📂 Project Structure

| File | Description |
| :--- | :--- |
| `main.tf` | Defines the EC2 instance and links the User Data script. |
| `vpc.tf` | Defines the VPC, Internet Gateway, and Route Table. |
| `subnet.tf` | Defines the Public Subnet. |
| `sg.tf` | Defines the Security Group (Ports 80 & 22). |
| `variables.tf` | Configurable variables (Region, CIDRs, Key Name). |
| `outputs.tf` | Displays the EC2 Public IP and the Web App URL. |
| `provider.tf` | AWS Provider definition and AMI Data Source (AL2023). |
| `install_lamp.sh` | **User Data Script:** Installs software, configures DB, and embeds the PHP app. |
| `my-app.php` | The source code for the PHP demo app (embedded via the script). |

## 📋 Prerequisites

1.  **Terraform:** Installed on your local machine.
2.  **AWS CLI:** Configured with valid credentials (`aws configure`).
3.  **SSH Key Pair:** You must have an existing Key Pair in AWS `us-east-1` named **`my-key-pair`**.
    * *To create one via CLI:*
        ```bash
        aws ec2 create-key-pair --key-name my-key-pair --query 'KeyMaterial' --output text > my-key-pair.pem
        chmod 400 my-key-pair.pem
        ```

## 🚀 Deployment Instructions

1.  **Initialize Terraform**
    Download the required AWS providers.
    ```bash
    terraform init
    ```

2.  **Review the Plan**
    See what resources will be created.
    ```bash
    terraform plan
    ```

3.  **Apply Configuration**
    Confirm the build.
    ```bash
    terraform apply
    ```
    *Type `yes` when prompted.*

## 🔍 Verification

Once `terraform apply` completes:

1.  **Wait ~2-3 Minutes:** The instance needs time to boot, run `dnf update`, install packages, and start Apache.
2.  **Check the Output:** Look for the `webserver_url` in your terminal:
    ```
    webserver_url = "http://<PUBLIC-IP>/my-app.php"
    ```
3.  **Visit the URL:** Open the link in your browser.
    * You should see the **"🚀 LAMP Stack Status"** page.
    * Refresh the page multiple times to see new "Visit" records added to the MariaDB database automatically.

## 🧹 Cleanup

To avoid ongoing AWS charges, destroy the resources when you are finished:

```bash
terraform destroy