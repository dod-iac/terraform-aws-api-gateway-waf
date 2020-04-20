output "web_acl_id" {
  description = "The ID of the WAF WebACL."
  value       = aws_wafregional_web_acl.main.id
}
