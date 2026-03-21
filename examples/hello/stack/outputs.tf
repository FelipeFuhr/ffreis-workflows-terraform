output "greeting_path" {
  description = "Absolute path of the generated greeting file."
  value       = local_file.greeting.filename
}

output "greeting_content" {
  description = "Content written to the greeting file."
  value       = local_file.greeting.content
}
