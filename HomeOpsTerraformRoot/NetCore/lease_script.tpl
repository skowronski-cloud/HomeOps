:if ($leaseActIP ~ "${dhcp_notify_match}" && $leaseBound=1) do={
    :log info ("IP: $leaseActIP, MAC: $leaseActMAC, Host: $"lease-hostname"")
    :tool e-mail send to="${tool_email_to}" subject="[MikroTik] New DHCP client in the network - $leaseActMAC" body=("_MAC: $leaseActMAC\r\n__IP: $leaseActIP\r\nHOST: $"lease-hostname"")
}