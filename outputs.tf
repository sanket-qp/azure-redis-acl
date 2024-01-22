output "resource_group_id" {
  value = azurerm_resource_group.this.id
}

output "identity_redis_admin_client_id" {
  value = azurerm_user_assigned_identity.admin.client_id
}

output "identity_redis_admin_object_id" {
  value = azurerm_user_assigned_identity.admin.principal_id
}

output "identity_redis_user_client_id" {
  value = azurerm_user_assigned_identity.user.client_id
}

output "identity_redis_user_object_id" {
  value = azurerm_user_assigned_identity.user.principal_id
}

output "redist_host" {
  value = azurerm_redis_cache.this.hostname
}

