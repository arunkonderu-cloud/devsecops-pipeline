package kubernetes.admission

# Block :latest image tags - not reproducible, cannot audit what ran
deny[msg] {
  input.kind == "Pod"
  container := input.spec.containers[_]
  endswith(container.image, ":latest")
  msg := sprintf("Container %v uses :latest tag. Pin to a specific version.", [container.name])
}

# Block privileged containers - can escape to host kernel
deny[msg] {
  input.kind == "Pod"
  container := input.spec.containers[_]
  container.securityContext.privileged == true
  msg := sprintf("Container %v is privileged. Breaks container isolation.", [container.name])
}

# Block hostNetwork - exposes all host network interfaces
deny[msg] {
  input.kind == "Pod"
  input.spec.hostNetwork == true
  msg := "Pod uses hostNetwork: true. Use a NetworkPolicy instead."
}

# Require memory limits - prevent resource exhaustion
deny[msg] {
  input.kind == "Pod"
  container := input.spec.containers[_]
  not container.resources.limits.memory
  msg := sprintf("Container %v has no memory limit. Required to prevent resource exhaustion.", [container.name])
}

# Require CPU limits
deny[msg] {
  input.kind == "Pod"
  container := input.spec.containers[_]
  not container.resources.limits.cpu
  msg := sprintf("Container %v has no CPU limit.", [container.name])
}

# Block root containers - least-privilege means non-root
deny[msg] {
  input.kind == "Pod"
  container := input.spec.containers[_]
  not container.securityContext.runAsNonRoot
  msg := sprintf("Container %v does not set runAsNonRoot: true.", [container.name])
}

# Block privilege escalation
deny[msg] {
  input.kind == "Pod"
  container := input.spec.containers[_]
  container.securityContext.allowPrivilegeEscalation == true
  msg := sprintf("Container %v allows privilege escalation. Set to false.", [container.name])
}
