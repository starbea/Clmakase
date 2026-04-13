output "db_password" {
  description = "Generated database password"
  value       = random_password.db_password.result
  sensitive   = true
}