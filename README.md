# zpa-iot-edge-terraform
Terraform Script for Onboarding an IoT Edge for Zscaler Private Access

## Install Terraform Provider for Zscaler Private Access

Follow instructions here: https://github.com/willguibr/terraform-provider-zpa 

## Provide locals information

Update main.tf to provide information specific to you tenant and the IoT Edge you want to deploy:

```main.tf
# Populate the locals
locals {
  ## ZPA Authentication Information
  ## See: https://help.zscaler.com/zpa/getting-started-zpa-api 
  client_id        = "<ZPA_CLIENT_ID>"
  client_secret    = "<ZPA_CLIENT_SECRET>"
  customerid      = "<ZPA_CUSTOMER_ID>"

  ## IoT Edge Information
  edge_name       = "402-201745002"
  edge_fqdn       = "402-201745002.local"
  #edge_ip         = ""
  edge_latitude   = "0.1807"
  edge_longitude  = "78.4678"
  edge_location   = "Quito, Ecuador"
  edge_country    = "EC"
}
```

Run Terraform init, plan and apply

```
terraform init
terraform plan
terraform apply
```
