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
      "${get_original_terragrunt_dir()}/../HomeOpsData/common.tfvars",
      "${get_original_terragrunt_dir()}/../HomeOpsData/ros.tfvars",
      "${get_original_terragrunt_dir()}/../HomeOpsData/wan.tfvars",
      "${get_original_terragrunt_dir()}/../HomeOpsData/lan.tfvars",
      "${get_original_terragrunt_dir()}/../HomeOpsData/wifi.tfvars",
      "${get_original_terragrunt_dir()}/../HomeOpsData/yig.tfvars",
    ]
  }

  before_hook "tfstate_snapshot_before" {
    commands = ["apply","import","destroy","state"]
    execute  = ["bash", "-lc", "${get_original_terragrunt_dir()}/tools/tfstate_snapshot.sh before"]
  }

  after_hook "tfstate_snapshot_after" {
    commands = ["apply","import","destroy","state"]
    execute  = ["bash", "-lc", "${get_original_terragrunt_dir()}/tools/tfstate_snapshot.sh after"]
  }

}


inputs = {
  repo_root = get_terragrunt_dir()
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
