# Compliance Control Mapping - ISO 27001 and NIST SP 800-53

## A.9 Access Control
| Control | Reference | Implementation |
|---------|-----------|----------------|
| RBAC least-privilege | A.9.4.1 / NIST AC-6 | kubernetes/rbac/roles.yaml |
| No privileged containers | A.9.4.1 | security/opa/policies/admission-policies.rego |
| Default-deny NetworkPolicy | A.9.4.1 / NIST AC-4 | kubernetes/network-policies/default-deny.yaml |

## A.10 Cryptography
| Control | Reference | Implementation |
|---------|-----------|----------------|
| KMS encryption of EKS secrets | A.10.1.1 / NIST SC-28 | terraform/modules/eks-secure/main.tf |
| Image signing (cosign) | A.10.1.2 / NIST SR-4 | .github/workflows/devsecops-pipeline.yml |

## A.12 Operations Security
| Control | Reference | Implementation |
|---------|-----------|----------------|
| Trivy CVE scanning | A.12.6.1 / NIST SI-2 | Pipeline Gate 3 |
| tfsec + checkov IaC scanning | A.12.6.1 | Pipeline Gate 2 |
| CloudTrail with log validation | A.12.4.1 / NIST AU-9 | terraform/modules/eks-secure/main.tf |
| Falco runtime detection | A.12.4.1 / NIST SI-4 | security/falco/custom-rules.yaml |
| SBOM generation | A.12.5.1 / NIST SR-4 | Pipeline Gate 3 |

## A.14 System Development
| Control | Reference | Implementation |
|---------|-----------|----------------|
| OPA admission control | A.14.2.5 / NIST CM-7 | security/opa/policies |
| Secret detection in pipeline | A.14.2.1 / NIST IA-5 | Pipeline Gate 1 |
| IaC-only changes | A.14.2.2 / NIST CM-3 | Terraform + GitHub Actions |

## A.16 Incident Management
| Control | Reference | Implementation |
|---------|-----------|----------------|
| Security incident runbook | A.16.1.5 / NIST IR-4 | docs/runbook-security-incident.md |
| Falco alerting | A.16.1.2 / NIST IR-5 | security/falco/custom-rules.yaml |
| Compliance attestation | A.16.1.7 / NIST AU-10 | Pipeline Gate 5 |

## Key Principle
Controls enforced at build time cost minutes.
Controls enforced after a breach cost weeks of investigation,
credential rotation, regulatory disclosure, and customer notification.
Compliance-by-design is not just best practice - it is economically rational.
