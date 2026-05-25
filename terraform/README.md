# AWS Infrastructure with Terraform
## 🏗 아키텍처 개요
### 전체 구조
```text
┌─────────────────────────────────────────────────────────────┐
│                         AWS Account                         │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌──────────────────────┐    ┌──────────────────────┐       │
│  │       Dev VPC        │    │      Prod VPC        │       │
│  │     10.0.0.0/16      │    │     10.1.0.0/16      │       │
│  │                      │    │                      │       │
│  │  ┌──────────────┐    │    │  ┌──────────────┐    │       │
│  │  │ EKS Cluster  │    │    │  │ EKS Cluster  │    │       │
│  │  │   (Spot)     │    │    │  │ (On-Demand)  │    │       │
│  │  └──────────────┘    │    │  └──────────────┘    │       │
│  │                      │    │                      │       │
│  │     RDS MySQL        │    │    Aurora MySQL      │       │
│  │                      │    │  ElastiCache Redis   │       │ 
│  └──────────────────────┘    └──────────────────────┘       │
│                                                             │
│  ┌───────────────────────────────────────────────────────┐  │
│  │           Terraform Remote State Backend              │  │
│  │  • S3 Bucket (tfstate 저장)                           │  │
│  │  • DynamoDB Table (state lock)                        │  │
│  └───────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```
### 네트워크 구성
**Dev VPC (10.0.0.0/16)**
- Public Subnets
  - 10.0.1.0/24 (AZ-a), 10.0.2.0/24 (AZ-c)
  - ALB, NAT Gateway 배치
- Private Subnets
  - 10.0.11.0/24 (AZ-a), 10.0.12.0/24 (AZ-c)
  - EKS Cluster / Worker Node 배치
- Private Data Subnets
  - 10.0.21.0/24 (AZ-a), 10.0.22.0/24 (AZ-c)
  - RDS MySQL 배치

**Prod VPC (10.1.0.0/16)**
- Public Subnets
  - 10.1.1.0/24 (AZ-a), 10.1.2.0/24 (AZ-c)
  - ALB, NAT Gateway 배치
- Private Subnets
  - 10.1.11.0/24 (AZ-a), 10.1.12.0/24 (AZ-c)
  - EKS Cluster / Worker Node 배치
- Private Data Subnets
  - 10.1.21.0/24 (AZ-a), 10.1.22.0/24 (AZ-c)
  - Aurora MySQL, ElastiCache Redis 배치

## ✨ 주요 특징
### 1. 환경 분리
- Dev / Prod를 서로 다른 VPC로 분리
- 환경별 보안 그룹 및 IAM 역할
### 2. 비용 최적화
- Dev
  - EKS Node Group: Spot Instance
  - RDS MySQL 단일 인스턴스
  - Single NAT 구조
- Prod
  - EKS Node Group: On-Demand
  - Aurora MySQL
  - Multi-AZ NAT Gateway
- VPC Endpoint를 통한 NAT 트래픽 절감
### 3. 확장성
- EKS 기반 컨테이너 오케스트레이션
- ALB Controller 기반 Ingress 자동화
- Redis Replication Group 기반 캐시 계층 분리
- 환경별 Node Group scaling 설정 분리
### 4. 보안
- EKS Worker Node를 Private Subnet에 배치
- DB / Redis를 Private Data Subnet에 격리
- AWS 서비스 접근은 VPC Endpoint 사용
- SSM Bastion을 사용하여 SSH 포트 오픈 없이 접근
- Secrets Manager로 DB Credential 관리
### 5. 운영 편의성
- Terraform remote state를 S3 + DynamoDB lock으로 관리
- bootstrap 스택으로 backend 리소스 선행 생성
- 환경별 root module 구조로 dev / prod 독립 배포 가능

## 📁 프로젝트 구조
```text
terraform/
├── bootstrap/                     # Terraform backend 리소스 생성
│   ├── main.tf                    # S3 Bucket, DynamoDB Table
│   ├── provider.tf
│   ├── variables.tf
│   └── versions.tf
│
├── env/
│   ├── dev/                       # Dev 환경 root module
│   │   ├── backend.hcl            # dev backend 설정
│   │   ├── main.tf                # dev 환경 모듈 조합
│   │   ├── provider.tf            # aws / helm / kubernetes provider
│   │   ├── variables.tf
│   │   └── versions.tf
│   │
│   └── prod/                      # Prod 환경 root module
│       ├── backend.hcl            # prod backend 설정
│       ├── main.tf                # prod 환경 모듈 조합
│       ├── provider.tf
│       ├── variables.tf
│       └── versions.tf
│
└── modules/                       # 재사용 가능한 공통 모듈
    ├── vpc/                       # VPC / Subnet / Route / NAT
    ├── security-group/            # 보안 그룹
    ├── ecr/                       # ECR Repository / Lifecycle
    ├── eks/                       # EKS Cluster / Node Group / IAM
    ├── alb-controller/            # AWS Load Balancer Controller
    ├── rds/                       # Dev: RDS MySQL / Prod: Aurora MySQL
    ├── redis/                     # ElastiCache Redis
    ├── vpc_endpoint/              # S3, ECR, STS, SSM, Logs Endpoint
    ├── secrets/                   # Secrets Manager
    └── ssm-bastion/               # SSM Bastion EC2
```

## 배포 순서
1. Bootstrap
```bash
cd bootstrap
terraform init
terraform plan
terraform apply
```
2. Dev 환경 배포
```bash
cd env\dev
terraform init -reconfigure -backend-config="./backend.hcl"
terraform plan -var-file="terraform.tfvars"
terraform apply -var-file="terraform.tfvars"
```
3. Prod 환경 배포
```bash
cd env\prod
terraform init -reconfigure -backend-config="./backend.hcl"
terraform plan -var-file="terraform.tfvars"
terraform apply -var-file="terraform.tfvars"
```
