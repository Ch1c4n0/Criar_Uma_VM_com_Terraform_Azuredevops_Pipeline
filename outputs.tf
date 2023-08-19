output "resource_group_name" {
  value = azurerm_resource_group.rg_adds.name
}

output "public_ip_address" {
  value = azurerm_windows_virtual_machine.adds_vm.public_ip_address
}
