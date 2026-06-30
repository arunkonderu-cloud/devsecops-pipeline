# DevSecOps Security Pipeline — Compliance-by-Design on Kubernetes

Security embedded at the pipeline level, not bolted on afterward.
Built to demonstrate shift-left security discipline practiced in production
at enterprise scale — where compliance is enforced in code, not checked in audits.

## Why this exists
The most common approach to security in infrastructure pipelines is audit-first:
build the thing, then check whether it is secure. This project implements
compliance-by-design — security controls that run at merge time, block
non-compliant changes before they reach production, and produce an auditable
record of every check.

## Five Security Gates (all automated, all blocking)
1. Secret Detection - gitleaks and truffleHog prevent credentials entering the repo
2. IaC Security Scan - tfsec, checkov, OPA catch Terraform misconfigs before apply
3. Container CVE Scan - Trivy blocks known vulnerabilities, generates SBOM
4. Kubernetes Policy Validation - OPA Gatekeeper, kube-score enforce security posture
5. Compliance Attestation - signed timestamped record of every check for every merge

## Runtime Security (Falco)
Custom rules detect: credential theft, privilege escalation, container escape,
unexpected outbound connections, package managers in production containers.

## Stack
- OPA Gatekeeper 3.15 - Admission control
- Falco 0.38 - Runtime security
- Trivy 0.50 - CVE scanning and SBOM
- HashiCorp Vault 1.15 - Secrets management
- tfsec 1.28 - IaC security scanning
- checkov 3.2 - IaC policy checks
- gitleaks 8.18 - Secret detection
- Terraform >= 1.5 - IaC provisioning
- Kubernetes 1.28+ - Orchestration
- Prometheus and Grafana - Security observability

## Compliance Mapping
Controls mapped to ISO 27001 Annex A and NIST SP 800-53.
See docs/compliance-mapping.md for full mapping.

## Author
Arun Kumar Konderu - Site Reliability Engineer | DevOps and Cloud Platform Engineering
CKA | AWS Certified DevOps Engineer
linkedin.com/in/arun-kumar-konderu-3b1373207 | github.com/arunkonderu-cloud
