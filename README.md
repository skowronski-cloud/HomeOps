# HomeOps

TF/TG stack for managing my home/lab network.

## Project architecture

- `../HomeOpsData` - external encrypted repository containing input variables, as well as offline tfstate
- `terragrunt.hcl` - Terragrunt entrypoint to a single environment
- `HomeOpsTerraformRoot` - root Terraform module
  - `NetCore` - submodule for handling core network configuration like ISP connection, LAN IPs, users etc.
  - `NetWiFiCAPsMAN` - submodule for handling Wi-Fi configuration including CAPsMAN
  - `NetClients` - submodule for deploying DHCP server leases (this one is going to be used most often) - TBD


## Infrastructure architecture

### Network devices

- one RouterOS device acting as main Ethernet router without modern wireless stack (MMIPS hEX)
  - with `wireless` package >= 7.16beta2, it's possible to have CAPsMAN there and manage Wi-Fi 6 radios (ax)
- several RouterOS devices acting as APs with modern wireless stack (Wi-Fi 6 capable, e.g. hAP ax²)
