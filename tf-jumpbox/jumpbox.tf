# Create a resource group if it doesn’t exist
resource "azurerm_resource_group" "deployment_resourcegroup" {
    name     = "${var.resource_group}"
    location = "${var.region}"

    tags {
        environment = "${var.resource_group}"
    }
}

# Create virtual network
resource "azurerm_virtual_network" "jumpboxnetwork" {
    name                = "jumpboxVnet"
    address_space       = ["10.0.0.0/16"]
    location            = "${var.region}"
    resource_group_name = "${azurerm_resource_group.deployment_resourcegroup.name}"

    tags {
        environment = "${var.resource_group}"
    }
}

# Create subnet
resource "azurerm_subnet" "jumpboxsubnet" {
    name                 = "jumpboxSubnet"
    resource_group_name  = "${azurerm_resource_group.deployment_resourcegroup.name}"
    virtual_network_name = "${azurerm_virtual_network.jumpboxnetwork.name}"
    address_prefix       = "10.0.1.0/24"
}

# Create public IPs
resource "azurerm_public_ip" "jumpboxpublicip" {
    name                         = "jumpboxPublicIP"
    location                     = "${var.region}"
    resource_group_name          = "${azurerm_resource_group.deployment_resourcegroup.name}"
    public_ip_address_allocation = "dynamic"

    tags {
        environment = "${var.resource_group}"
    }
}


# Create Network Security Group and rule
resource "azurerm_network_security_group" "jumpboxnsg" {
    name                = "myNetworkSecurityGroup"
    location            = "${var.region}"
    resource_group_name = "${azurerm_resource_group.deployment_resourcegroup.name}"

    security_rule {
        name                       = "SSH"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    tags {
        environment = "${var.resource_group}"
    }
}

# Create network interface
resource "azurerm_network_interface" "jumpboxnic" {
    name                      = "myNIC"
    location                  = "${var.region}"
    resource_group_name       = "${azurerm_resource_group.deployment_resourcegroup.name}"
    network_security_group_id = "${azurerm_network_security_group.jumpboxnsg.id}"

    ip_configuration {
        name                          = "myNicConfiguration"
        subnet_id                     = "${azurerm_subnet.jumpboxsubnet.id}"
        private_ip_address_allocation = "dynamic"
        public_ip_address_id          = "${azurerm_public_ip.jumpboxpublicip.id}"
    }

    tags {
        environment = "${var.resource_group}"
    }
}

# Generate random text for a unique storage account name
resource "random_id" "randomId" {
    keepers = {
        # Generate a new ID only when a new resource group is defined
        resource_group = "${azurerm_resource_group.deployment_resourcegroup.name}"
    }

    byte_length = 8
}

# Create storage account for boot diagnostics
resource "azurerm_storage_account" "mystorageaccount" {
    name                        = "diag${random_id.randomId.hex}"
    resource_group_name         = "${azurerm_resource_group.deployment_resourcegroup.name}"
    location                    = "${var.region}"
    account_tier                = "Standard"
    account_replication_type    = "LRS"

    tags {
        environment = "${var.resource_group}"
    }
}

# Create virtual machine
resource "azurerm_virtual_machine" "jumpboxvm" {
    name                  = "jbox-pcf"
    location              = "${var.region}"
    resource_group_name   = "${azurerm_resource_group.deployment_resourcegroup.name}"
    network_interface_ids = ["${azurerm_network_interface.jumpboxnic.id}"]
    vm_size               = "Standard_DS1_v2"

    storage_os_disk {
        name              = "jumpboxOsDisk"
        caching           = "ReadWrite"
        create_option     = "FromImage"
        managed_disk_type = "Premium_LRS"
    }

    storage_image_reference {
        publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "18.04-LTS"
        version   = "latest"
    }

    os_profile {
        computer_name  = "jumpbox"
        admin_username = "ubuntu"
    }

    os_profile_linux_config {
        disable_password_authentication = true
        ssh_keys {
            path     = "/home/ubuntu/.ssh/authorized_keys"
            key_data = "${var.ssh_public_key}"
        }
    }

    boot_diagnostics {
        enabled = "true"
        storage_uri = "${azurerm_storage_account.mystorageaccount.primary_blob_endpoint}"
    }

    tags {
        environment = "${var.resource_group}"
    }

    provisioner "file" {
        source      = "../scripts"
        destination = "/home/ubuntu"

        connection {
                type = "ssh"
                user = "ubuntu"
                private_key = "${file("azurejumpbox_rsa")}"
        }
    }

    provisioner "remote-exec" {
        inline = [
        "chmod +x /home/ubuntu/scripts/*.sh",
        ". /home/ubuntu/scripts/init-jumpbox.sh"
        ]

        connection {
                type = "ssh"
                user = "ubuntu"
                private_key = "${file("azurejumpbox_rsa")}"
        }
    }
}
