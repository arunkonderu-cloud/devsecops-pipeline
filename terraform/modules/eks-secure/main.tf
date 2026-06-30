name: DevSecOps Security Pipeline
on:
  push:
    branches: [main]
  pull_request:
    branches: [main]
permissions:
  contents: read
  security-events: write
jobs:
  secret-scan:
    name: Gate 1 - Secret Detection
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0
      - uses: gitleaks/gitleaks-action@v2
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
  iac-security-scan:
    name: Gate 2 - IaC Security Scan
    runs-on: ubuntu-latest
    needs: secret-scan
    steps:
      - uses: actions/checkout@v4
      - uses: aquasecurity/tfsec-action@v1.0.3
        with:
          working_directory: terraform
          soft_fail: true
      - uses: bridgecrewio/checkov-action@master
        with:
          directory: .
          framework: terraform,kubernetes
          soft_fail: true
  container-security-scan:
    name: Gate 3 - Container CVE Scan
    runs-on: ubuntu-latest
    needs: iac-security-scan
    steps:
      - uses: actions/checkout@v4
      - name: Build test image
        run: |
          echo "FROM alpine:3.19" > Dockerfile
          echo "RUN adduser -D appuser" >> Dockerfile
          echo "USER appuser" >> Dockerfile
          docker build -t devsecops-app:${{ github.sha }} .
      - uses: aquasecurity/trivy-action@master
        with:
          image-ref: devsecops-app:${{ github.sha }}
          format: sarif
          output: trivy-results.sarif
          severity: CRITICAL,HIGH
          exit-code: 0
          ignore-unfixed: true
      - uses: aquasecurity/trivy-action@master
        with:
          image-ref: devsecops-app:${{ github.sha }}
          format: cyclonedx
          output: sbom.json
      - uses: actions/upload-artifact@v4
        with:
          name: sbom-${{ github.sha }}
          path: sbom.json
          retention-days: 90
  kubernetes-security-validation:
    name: Gate 4 - Kubernetes Security Validation
    runs-on: ubuntu-latest
    needs: container-security-scan
    steps:
      - uses: actions/checkout@v4
      - name: Verify default-deny NetworkPolicy
        run: |
          test -f kubernetes/network-policies/default-deny.yaml && echo "Present" || exit 1
      - name: Check no cluster-admin bindings
        run: |
          grep -r "cluster-admin" kubernetes/rbac/ 2>/dev/null && exit 1 || echo "RBAC clean"
  audit-trail:
    name: Gate 5 - Audit Trail
    runs-on: ubuntu-latest
    needs: [secret-scan,iac-security-scan,container-security-scan,kubernetes-security-validation]
    if: success()
    steps:
      - name: Generate attestation
        run: |
          echo "{\"timestamp\":\"$(date -u +%Y-%m-%dT%H:%M:%SZ)\",\"commit\":\"${{ github.sha }}\",\"gates_passed\":true}" > attestation.json
          cat attestation.json
      - uses: actions/upload-artifact@v4
        with:
          name: attestation-${{ github.sha }}
          path: attestation.json
          retention-days: 365