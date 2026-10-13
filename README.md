# Mini Project 3: Automated Cloud Infrastructure Using Terraform

Automates provisioning of a small AWS environment — a VPC, public subnet,
internet gateway, security group, and an EC2 instance running a basic web
server — entirely through Terraform.

## Architecture

```
                         Internet
                             |
                      [Internet Gateway]
                             |
                      [Route Table] --- 0.0.0.0/0 -> IGW
                             |
                    VPC (10.0.0.0/16)
                             |
                 Public Subnet (10.0.1.0/24)
                             |
                  [Security Group: SSH:22, HTTP:80]
                             |
                    [EC2 Instance: t2.micro]
                     (Amazon Linux 2023,
                      Apache httpd via user_data)
```

| Component | Resource | Purpose |
|---|---|---|
| VPC | `aws_vpc.main` | Isolated network for the project |
| Internet Gateway | `aws_internet_gateway.main` | Gives the VPC internet access |
| Public Subnet | `aws_subnet.public` | Hosts the EC2 instance, auto-assigns public IPs |
| Route Table | `aws_route_table.public` | Routes outbound traffic to the IGW |
| Security Group | `aws_security_group.web` | Firewall: allows SSH (22) and HTTP (80) inbound |
| EC2 Instance | `aws_instance.web` | The compute instance, bootstrapped with Apache |

## File Structure

```
.
├── provider.tf               # AWS provider + Terraform version constraints
├── variables.tf               # All configurable input variables
├── network.tf                 # VPC, subnet, IGW, route table
├── security.tf                # Security group (firewall rules)
├── main.tf                    # EC2 instance + AMI data source
├── outputs.tf                 # Output values (IP, DNS, IDs, SSH command)
├── terraform.tfvars.example   # Template for your own variable values
├── .gitignore
└── README.md
```

## Prerequisites

1. **Terraform** >= 1.6.0 installed (`terraform -version` to check)
2. **AWS CLI** configured with credentials (`aws configure`) — this project
   does not hardcode credentials; Terraform reads them from your AWS CLI
   config / environment.
3. **An existing EC2 key pair** in your target AWS region (create one in the
   EC2 console under *Key Pairs*, or via `aws ec2 create-key-pair`) — needed
   for SSH access.
4. **Free Tier safety net set up** (see "Staying at $0" below) — do this
   before your first `apply`.

## Setup

1. Copy the example variables file and fill in your own values:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```
2. Edit `terraform.tfvars`:
   - `key_pair_name` — the name of your existing EC2 key pair
   - `ssh_allowed_cidr` — **your own IP** in `/32` form (find it with
     `curl ifconfig.me`), not `0.0.0.0/0`. Leaving SSH open to the world is
     a real security risk, free tier or not.

## Usage: init, plan, apply, destroy

```bash
# 1. Initialize — downloads the AWS provider plugin
terraform init

# 2. Format and validate the config (optional but recommended)
terraform fmt
terraform validate

# 3. Preview what will be created — review this before applying
terraform plan

# 4. Create the infrastructure
terraform apply
# Type "yes" when prompted

# 5. View outputs any time
terraform output

# 6. When you're done testing — ALWAYS tear it down
terraform destroy
# Type "yes" when prompted
```

**Tear down after every session.** Leaving the instance running past your
testing window is the most common way free tier usage turns into a bill.

## Staying at $0 (AWS Free Tier)

- This config defaults to `t2.micro`, which is free-tier eligible. The
  `instance_type` variable has a validation rule that blocks anything else.
- Root EBS volume is capped at 8GB (free tier covers up to 30GB total).
- No NAT Gateway is used — NAT Gateways are **not** free-tier eligible and
  are a common source of surprise charges. This project uses a public
  subnet with a security group instead.
- No Elastic IP is allocated — the instance uses its auto-assigned public IP,
  which costs nothing while the instance is running.
- Before you start: in the AWS Console, go to **Billing → Billing
  Preferences** and enable "Free Tier usage alerts," and set up a **zero-spend
  budget** under **AWS Budgets** so you get emailed if anything ever
  approaches $0.01.
- Always run `terraform destroy` when you're done — free tier limits are
  monthly allowances, not a guarantee against charges if something is left
  running indefinitely or exceeds the limit.

## Variables Reference

| Variable | Default | Description |
|---|---|---|
| `aws_region` | `ap-south-1` | AWS region to deploy into |
| `project_name` | `mini-project-3` | Prefix used in resource names/tags |
| `environment` | `dev` | Environment tag |
| `vpc_cidr` | `10.0.0.0/16` | VPC CIDR block |
| `public_subnet_cidr` | `10.0.1.0/24` | Public subnet CIDR block |
| `availability_zone` | `ap-south-1a` | AZ for the subnet |
| `instance_type` | `t2.micro` | EC2 instance type (restricted to free-tier types) |
| `ssh_allowed_cidr` | `0.0.0.0/0` | CIDR allowed to SSH — **override this** |
| `key_pair_name` | *(required)* | Existing EC2 key pair name |
| `root_volume_size` | `8` | Root EBS volume size in GB |

## Outputs Reference

| Output | Description |
|---|---|
| `instance_id` | EC2 instance ID |
| `instance_public_ip` | Public IP of the instance |
| `instance_public_dns` | Public DNS name |
| `vpc_id` | VPC ID |
| `subnet_id` | Public subnet ID |
| `security_group_id` | Security group ID |
| `ssh_connection_command` | Ready-to-use SSH command |

## Verifying it worked

After `apply` completes:

```bash
# Check the web server responds
curl http://$(terraform output -raw instance_public_ip)

# SSH into the instance
terraform output -raw ssh_connection_command
```

## Security Notes

- SSH access is restricted to `var.ssh_allowed_cidr` — set this to your own
  IP, never leave it as `0.0.0.0/0` in practice.
- No hardcoded credentials anywhere in this repo — Terraform uses your local
  AWS CLI credentials chain.
- `terraform.tfvars` is gitignored since it may contain your IP and key pair
  name — don't force-commit it.
- State files (`*.tfstate`) are also gitignored since they can contain
  sensitive resource attributes in plain text. For a real team project,
  state would normally be moved to a remote backend (e.g. S3 + DynamoDB
  locking) rather than kept locally.
