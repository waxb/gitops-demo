package main

import data.tags_validation

module_address[i] = address {
    changeset := input.resource_changes[i]
    address := changeset.address
}

tags_pascal_case[i] = resources {
    changeset := input.resource_changes[i]
    tags  := changeset.change.after.tags
    resources := [resource | resource := module_address[i]; val := tags[key]; not tags_validation.key_val_valid_pascal_case(key, val)]
}

tags_contain_minimum_set[i] = resources {
    changeset := input.resource_changes[i]
    tags := changeset.change.after.tags
    resources := [resource | resource := module_address[i]; not tags_validation.tags_contain_proper_keys(changeset.change.after.tags)]
}

warn[msg] {
    resources := tags_contain_minimum_set[_]
    resources != []
    msg := sprintf("Invalid tags (missing minimum required tags) for the following resources: %v", [resources])
}

warn[msg] {
    resources := tags_pascal_case[_]
    resources != []
    msg := sprintf("Invalid tags (not pascal case) for the following resources: %v", [resources])
}

#TODO: organize reusable code to the registry, this is just for testing purposes only!!!
# Checks whether the plan will cause resources with certain prefixes to change
check_resources(resources, disallowed_prefixes) {
  startswith(resources[_].type, disallowed_prefixes[_])
}

destroy_whitelist = [
  "null_resource"
]

blacklist = [
  "azurerm_public_ip",
  "azurerm_virtual_network"
]

warnlist = [
  "azurerm_resource_group",
  "azurerm_virtual_machine"
]

whitelist = [
  "azurerm_virtual_machine"
]

deny[msg] {
  check_resources(input.resource_changes, blacklist)
  banned := concat(", ", blacklist)
  msg = sprintf("Terraform plan will change prohibited resources in the following namespaces: %v", [banned])
}

warn[msg] {
  check_resources(input.resource_changes, warnlist)
  notice := concat(", ", warnlist)
  msg = sprintf("Terraform plan will change resources in the following warning namespaces: %v", [notice])
}

allow[msg] {
  check_resources(input.resource_changes, whitelist)
  allowed := concat(", ", whitelist)
  msg = sprintf("Terraform plan will change resources in the following allowed namespaces: %v", [allowed])
}

#allow[msg] {
#  check_resources(input.resource_changes, destroy_whitelist)
#  allowed := concat(", ", destroy_whitelist)
#  actions :=
#  allowed.change.actions == "delete"
#  msg = sprintf("Terraform plan will delete resources in the following namespaces: %v", [allowed])
#}
