output "app_id" {
  description = "The application created"
  value       = awscc_resiliencehub_app.app.id
}

output "policy_id" {
  description = "The policy created"
  value       = awscc_resiliencehub_resiliency_policy.policy.id
}