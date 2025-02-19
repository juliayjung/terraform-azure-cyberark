# Deploy infrastructure and Provide Continuous Delivery with GitHub and Terraform Cloud for Azure

## Introduction 
This is linked to [Git Hub repository](https://github.com/juliayjung/terraform-azure-cyberark)
- Create infrastructure to create Azure storage in Resource Group
- Provide Continuous Delivery with GitHub and Terraform Cloud for Azure
- release tag created by github / registry terraform

## Quick Run
1.  Login to [Azure portal](portal.azure.com) using by account username and password
2.  Check if Terraform cloud name is correct 
    *ie.* Azure-CyberArk is **cloud organization** and TerraformAzureTest is **cloud name** 
3.  Navigate to [Workspace > Variables](https://app.terraform.io/app/Azure-CyberArk/workspaces/TerraformAzureTest/variables)
    and apply values as below
    ```
    ARM_CLIENT_ID = Application Client ID
    ARM_CLIENT_SECRET = Secret
    ARM_SUBSCRIPTION_ID = Azure Portal > Resource group > Subscription ID
    ARM_TENANT_ID = Azure Portal > Microsoft Entra ID > Tenant ID
    ```
4.  Apply *resource_group_name, subscription_id, and location_id* in **terraform.tfvars**
5.  in Terminal, run
    ```
    az login --use-device-code      -> enter code and login using azure username and pwd
    terraform login                 -> generate Token > copy value and paste by clicking mouse right button
    terraform init -upgrade
    terraform import azurerm_resource_group.rg [get resource ID from settings > properties]
    ```
6.  git check out    (shift+control+p) to your branch \
    staged changes > git commit > git push \
7.  Navigate to [Github Actions](https://github.com/juliayjung/terraform-azure-cyberark/actions) to review workflow, \
    Navigate to [Terraform Runs](https://app.terraform.io/app/Azure-CyberArk/workspaces/TerraformAzureTest/runs) to review, \
    Navigate to [Azure Portal](https://portal.azure.com/#home) to verify storage has been created

## Errors
###   Error Resource already managed by Terraform
        terraform state list    ->verify if it already exists \
            azurerm_resource_group.rg \
        terraform state rm azurerm_resource_group.rg \

###   Error publishing module. Validation failed: Name, Provider is invalid
        Name of module must be in the format "terraform-<PROVIDER>-<NAME>" \
        Make sure your github repository is named in this ie. terraform-azure-cyberark \

###   Error reading the state of AzureRM Storage Account : Status=403 Code="AuthorizationFailed" the scope is invalid.
        terraform state list    ->verify if it already exists, if so \
            azurerm_storage_account.storageaccount \
        terraform state rm azurerm_storage_account.storageaccount \

> [!NOTE]
> MD file syntax referred to https://docs.github.com/en/get-started/writing-on-github/getting-started-with-writing-and-formatting-on-github/basic-writing-and-formatting-syntax