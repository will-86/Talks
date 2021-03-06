resource "azurerm_network_security_rule" "NetworkSecurityRule_AzureFabric" {
    name                        = "AzureFabric-${count.index + 1}"
    resource_group_name         = "${var.ResourceGroupName}"
    network_security_group_name = "${azurerm_network_security_group.NetworkSecurityGroup.*.name[count.index]}"
    description                 = "Ports required to allow communication between Azure fabric and AppGateways. Health probes will fail if this rule is removed or disabled."
    protocol                    = "TCP"
    source_port_range           = "*"
    destination_port_range      = "65503-65534"
    source_address_prefix       = "Internet"
    destination_address_prefix  = "${azurerm_subnet.subnet.*.address_prefix[count.index]}"
    access                      = "Allow"
    priority                    = "100"
    direction                   = "Inbound"
    count                       = "${length(var.Location)}"
}
resource "azurerm_network_security_rule" "NetworkSecurityRule_AppTraffic" {
    name                        = "AppTraffic-${count.index + 1}"
    resource_group_name         = "${var.ResourceGroupName}"
    network_security_group_name = "${azurerm_network_security_group.NetworkSecurityGroup.*.name[count.index]}"
    description                 = "Allows traffic destined for the backends to reach AppGateway. Without this rule the AppGateway will not be able to accept traffic."
    protocol                    = "TCP"
    source_port_range           = "*"
    destination_port_range      = "${var.AppGatewayMiscConfig["FrontendPort"]}"
    source_address_prefix       = "${var.AppGatewayPermittedServiceTag}"
    destination_address_prefix  = "${azurerm_subnet.subnet.*.address_prefix[count.index]}"
    access                      = "Allow"
    priority                    = "300"
    direction                   = "Inbound"
    count                       = "${var.Environment == "Prod" ? length(var.Location) : 0}"
}
resource "azurerm_network_security_rule" "NetworkSecurityRule_AppTraffic-Multi" {
    name                        = "AppTraffic-${count.index + 1}"
    resource_group_name         = "${var.ResourceGroupName}"
    network_security_group_name = "${azurerm_network_security_group.NetworkSecurityGroup.*.name[count.index]}"
    description                 = "Allows traffic destined for the backends to reach AppGateway. Without this rule the AppGateway will not be able to accept traffic."
    protocol                    = "TCP"
    source_port_range           = "*"
    destination_port_range      = "${var.AppGatewayMiscConfig["FrontendPort"]}"
    source_address_prefixes     = ["${concat(var.OfficeIps, var.ServiceIps)}"]
    destination_address_prefix  = "${azurerm_subnet.subnet.*.address_prefix[count.index]}"
    access                      = "Allow"
    priority                    = "300"
    direction                   = "Inbound"
    count                       = "${var.Environment == "Prod" ? 0 : length(var.Location) }"
}
resource "azurerm_network_security_rule" "NetworkSecurityRule_RedirectTraffic" {
    name                        = "RedirectTraffic-${count.index + 1}"
    resource_group_name         = "${var.ResourceGroupName}"
    network_security_group_name = "${azurerm_network_security_group.NetworkSecurityGroup.*.name[count.index]}"
    description                 = "Allows HTTP traffic to reach the AppGateway for the redirect listeners. Without this rule the AppGateway cannot accept HTTP traffic."
    protocol                    = "TCP"
    source_port_range           = "*"
    destination_port_range      = "${var.AppGatewayMiscConfig["RedirectPort"]}"
    source_address_prefix       = "${var.AppGatewayPermittedServiceTag}"
    destination_address_prefix  = "${azurerm_subnet.subnet.*.address_prefix[count.index]}"
    access                      = "Allow"
    priority                    = "350"
    direction                   = "Inbound"
    count                       = "${var.Environment == "Prod" ? length(var.Location) : 0}"
}
resource "azurerm_network_security_rule" "NetworkSecurityRule_RedirectTraffic-Multi" {
    name                        = "RedirectTraffic-${count.index + 1}"
    resource_group_name         = "${var.ResourceGroupName}"
    network_security_group_name = "${azurerm_network_security_group.NetworkSecurityGroup.*.name[count.index]}"
    description                 = "Allows HTTP traffic to reach the AppGateway for the redirect listeners. Without this rule the AppGateway cannot accept HTTP traffic."
    protocol                    = "TCP"
    source_port_range           = "*"
    destination_port_range      = "${var.AppGatewayMiscConfig["RedirectPort"]}"
    source_address_prefixes     = ["${concat(var.OfficeIps, var.ServiceIps)}"]
    destination_address_prefix  = "${azurerm_subnet.subnet.*.address_prefix[count.index]}"
    access                      = "Allow"
    priority                    = "350"
    direction                   = "Inbound"
    count                       = "${var.Environment == "Prod" ? 0 : length(var.Location) }"
}

# Section for 3rd Party Access
resource "azurerm_network_security_rule" "NetworkSecurityRule_ThirdParty-0" {
    name                        = "${element(keys(var.ThirdPartyIps),0)}"
    resource_group_name         = "${var.ResourceGroupName}"
    network_security_group_name = "${azurerm_network_security_group.NetworkSecurityGroup.*.name[count.index]}"
    description                 = "Allows HTTPS traffic from ${element(keys(var.ThirdPartyIps),0)}."
    protocol                    = "TCP"
    source_port_range           = "*"
    destination_port_range      = "${var.AppGatewayMiscConfig["FrontendPort"]}"
    source_address_prefixes     = ["${var.ThirdPartyIps[element(keys(var.ThirdPartyIps),0)]}"]
    destination_address_prefix  = "${azurerm_subnet.subnet.*.address_prefix[count.index]}"
    access                      = "Allow"
    priority                    = "400"
    direction                   = "Inbound"
    count                       = "${var.ThirdParties == "Yes" ? length(var.Location) : 0}"
}

resource "azurerm_network_security_rule" "NetworkSecurityRule_LoadBalancers" {
    name                        = "LoadBalancers-${count.index + 1}"
    resource_group_name         = "${var.ResourceGroupName}"
    network_security_group_name = "${azurerm_network_security_group.NetworkSecurityGroup.*.name[count.index]}"
    description                 = "Allow connectivity from Azure Load Balancers. If this rule is removed or disabled, the AppGateway will not recieve traffic."
    protocol                    = "TCP"
    source_port_range           = "*"
    destination_port_range      = "*"
    source_address_prefix       = "AzureLoadBalancer"
    destination_address_prefix  = "${azurerm_subnet.subnet.*.address_prefix[count.index]}"
    access                      = "Allow"
    priority                    = "4000"
    direction                   = "Inbound"
    count                       = "${length(var.Location)}"
}
resource "azurerm_network_security_rule" "NetworkSecurityRule_DenyAll" {
    name                        = "DenyAll-${count.index + 1}"
    resource_group_name         = "${var.ResourceGroupName}"
    network_security_group_name = "${azurerm_network_security_group.NetworkSecurityGroup.*.name[count.index]}"
    description                 = "This rule blocks all other inbound traffic to the AppGateway vnet. Removing or disabling this rule will re-enable the Azure default rules."
    protocol                    = "TCP"
    source_port_range           = "*"
    destination_port_range      = "*"
    source_address_prefix       = "*"
    destination_address_prefix  = "VirtualNetwork"
    access                      = "Deny"
    priority                    = "4096"
    direction                   = "Inbound"
    count                       = "${length(var.Location)}"
}
