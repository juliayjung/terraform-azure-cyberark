resource_group_name = "rg-dsoa-cyberark-terraform-lab-cc"
subscription_id     = "13e3da75-e81b-4d8f-a621-c2e5534597fb"
location_id         = "canadacentral"

common_tags = {
  "Owner"      = "Jung, Julia"
  "Department" = "dsoa"
  "Project"    = "cyberark-terraform"
}
//tags_owner          = "Jung, Julia"
//tags_department     = "dsoa"
//tags_project        = "cyberark-terraform"

vnet_name   = "vnet-dsoa-cyberark-terraform-lab-cc"
subnet_name = "default"