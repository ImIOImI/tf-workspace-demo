<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_global"></a> [global](#module\_global) | ./modules/global | n/a |

## Resources

| Name | Type |
|------|------|
| [azurerm_network_interface.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface) | resource |
| [azurerm_resource_group.rg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_subnet.compute-subnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_subnet.data-subnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_virtual_machine.compute](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine) | resource |
| [azurerm_virtual_network.vnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network) | resource |

## Inputs

No inputs.

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_country"></a> [country](#output\_country) | n/a |
| <a name="output_env-timezone"></a> [env-timezone](#output\_env-timezone) | n/a |
| <a name="output_environment"></a> [environment](#output\_environment) | n/a |
| <a name="output_hub-subnet"></a> [hub-subnet](#output\_hub-subnet) | n/a |
| <a name="output_k8s-max-nodes"></a> [k8s-max-nodes](#output\_k8s-max-nodes) | n/a |
| <a name="output_network"></a> [network](#output\_network) | n/a |
| <a name="output_organisation-id"></a> [organisation-id](#output\_organisation-id) | n/a |
| <a name="output_region"></a> [region](#output\_region) | n/a |
| <a name="output_subnet"></a> [subnet](#output\_subnet) | n/a |
| <a name="output_time-offset"></a> [time-offset](#output\_time-offset) | n/a |
| <a name="output_timezone"></a> [timezone](#output\_timezone) | n/a |
| <a name="output_workspace"></a> [workspace](#output\_workspace) | n/a |
<!-- END_TF_DOCS -->