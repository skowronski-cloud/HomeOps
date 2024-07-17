terraform {
  source = "./HomeOpsTerraformRoot/"

  extra_arguments "vars" {
    commands = [
      "apply",
      "plan",
      "import",
      "push",
      "refresh",
      "destroy"
    ]
    required_var_files = [
      "${get_original_terragrunt_dir()}/../HomeOpsData/ros.tfvars",
      "${get_original_terragrunt_dir()}/../HomeOpsData/wan.tfvars",
      "${get_original_terragrunt_dir()}/../HomeOpsData/lan.tfvars",
      "${get_original_terragrunt_dir()}/../HomeOpsData/wifi.tfvars",
    ]
  }
}

remote_state {
  backend = "local"
  config = {
    path = "${get_original_terragrunt_dir()}/../HomeOpsData/terraform.tfstate" 
  }  
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite"
  }
}
