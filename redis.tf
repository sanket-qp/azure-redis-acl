resource "azurerm_redis_cache" "this" {
  name                = "${local.prefix}-redis-server"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  capacity            = 1
  family              = "C"
  sku_name            = "Standard"
  enable_non_ssl_port = false
  minimum_tls_version = "1.2"

  redis_configuration {
  }
}

resource "azapi_update_resource" "redis" {
  type          = "Microsoft.Cache/Redis@2023-05-01-preview"
  resource_id   = azurerm_redis_cache.this.id

  body = jsonencode({
    properties = {
      redisConfiguration = {
        maxmemory-policy = "volatile-lru"
        aad-enabled =  "True"
      }
    }
  })
}

resource "azapi_resource" "access_policy_cache_only" {
  type      = "Microsoft.Cache/Redis/accessPolicies@2023-05-01-preview"
  name      = "CacheOnly"
  parent_id = azurerm_redis_cache.this.id

  body = jsonencode({
    properties = {
      permissions = "+@read +@write -@stream -@pubsub -@dangerous ~*"
    }
  })
}

resource "azapi_resource" "access_policy_admin" {
  type      = "Microsoft.Cache/Redis/accessPolicies@2023-05-01-preview"
  name      = "RedisAdmin"
  parent_id = azurerm_redis_cache.this.id

  body = jsonencode({
    properties = {
      permissions = "+@all allkeys"
    }
  })
}

resource "azapi_resource" "access_policy_assignment_user" {
  depends_on = [
    azapi_resource.access_policy_cache_only
  ]
  type        = "Microsoft.Cache/Redis/accessPolicyAssignments@2023-05-01-preview"
  name        = azurerm_user_assigned_identity.user.principal_id
  parent_id   = azurerm_redis_cache.this.id

  body = jsonencode({
    name = azurerm_user_assigned_identity.user.principal_id,
    properties = {
      accessPolicyName = "CacheOnly",
      objectId = azurerm_user_assigned_identity.user.principal_id
      objectIdAlias = azurerm_user_assigned_identity.user.name
    }
  })
}

resource "azapi_resource" "access_policy_assignment_admin" {
  depends_on = [
    azapi_resource.access_policy_admin
  ]
  type        = "Microsoft.Cache/Redis/accessPolicyAssignments@2023-05-01-preview"
  name        = azurerm_user_assigned_identity.admin.principal_id
  parent_id   = azurerm_redis_cache.this.id

  body = jsonencode({
    name = azurerm_user_assigned_identity.admin.principal_id,
    properties = {
      accessPolicyName = "RedisAdmin",
      objectId = azurerm_user_assigned_identity.admin.principal_id
      objectIdAlias = azurerm_user_assigned_identity.admin.name
    }
  })
}

