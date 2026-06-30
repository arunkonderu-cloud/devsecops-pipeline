# Security Incident Response Runbook

Any event with data exposure potential is automatically Sev1.
Response SLA: Acknowledge in 5 minutes, contain in 30 minutes.

## Sev1 Triggers
- Active credential compromise
- Container escape or host access
- Unauthorized API server access
- Falco CRITICAL alert
- Unexpected outbound data transfer
- CloudTrail: root account usage

## Step 1 - Contain FIRST, investigate second

Isolate the compromised pod by applying a deny-all NetworkPolicy:

  kubectl apply -f isolate-pod-networkpolicy.yaml
  kubectl cordon NODE_NAME  # if host-level compromise suspected
  # Do NOT delete the node - preserve forensic evidence

## Step 2 - Preserve evidence BEFORE any changes

  kubectl describe pod POD_NAME -n NAMESPACE > pod-state.txt
  kubectl logs POD_NAME -n NAMESPACE --all-containers > pod-logs.txt
  kubectl logs POD_NAME -n NAMESPACE --all-containers --previous >> pod-logs.txt

## Step 3 - Rotate compromised credentials

  # Disable AWS access key immediately
  aws iam update-access-key --access-key-id KEY_ID --status Inactive

  # Emergency deny-all for the IAM role
  aws iam put-role-policy --role-name ROLE_NAME \
    --policy-name EmergencyDenyAll \
    --policy-document '{"Version":"2012-10-17","Statement":[{"Effect":"Deny","Action":"*","Resource":"*"}]}'

  # Revoke Vault leases for the affected service
  vault lease revoke -prefix secret/SERVICE_PATH

## Step 4 - Restore from known-good image

  # Never restart the compromised version - deploy fresh from registry
  kubectl set image deployment/APP container=REGISTRY/IMAGE:KNOWN_GOOD_SHA

## Postmortem (required for all Sev1/Sev2 security events)

1. Timeline with exact timestamps
2. Root cause - what was the actual vulnerability?
3. Blast radius - what was accessed or exposed?
4. Detection gap - how long before we noticed and why?
5. Systemic fix - what policy change prevents this class of event?
6. Compliance - does this require regulatory notification?

Same blameless format as operational incidents.
The finding becomes a sprint ticket, not a document nobody reads.
