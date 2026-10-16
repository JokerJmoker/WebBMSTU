$ExportDir = 'C:\AuditResearch\Baseline\Exports'
if (-not (Test-Path $ExportDir)) {
    New-Item -Path $ExportDir -ItemType Directory -Force | Out-Null
}

$logs = @{
    'Security'                                                          = 'Security_after_tests.evtx'
    'System'                                                            = 'System_after_tests.evtx'
    'Application'                                                       = 'Application_after_tests.evtx'
    'Directory Service'                                                 = 'DirectoryService.evtx'
    'Microsoft-Windows-GroupPolicy/Operational'                         = 'GroupPolicy.evtx'
    'DNS Server'                                                        = 'DNS_Server.evtx'
    'Microsoft-Windows-DNSServer/Audit'                                 = 'DNS_Audit.evtx'
    'Microsoft-Windows-Dhcp-Server/AuditLog'                            = 'DHCP_Audit.evtx'
    'Microsoft-Windows-Dhcp-Server/Operational'                         = 'DHCP_Operational.evtx'
    'Microsoft-Windows-RemoteAccess-RemoteAccessServer/Operational'     = 'RRAS_Operational.evtx'
    'Microsoft-Windows-RemoteAccess-RemoteAccessServer/Admin'           = 'RRAS_Admin.evtx'
    'Microsoft-Windows-RasRoutingProtocols/Operational'                 = 'RasRoutingProtocols.evtx'
    'Microsoft-Windows-WFP/Operational'                                 = 'WFP.evtx'
    'Microsoft-Windows-Windows Firewall With Advanced Security/Firewall'= 'Firewall.evtx'
    'Microsoft-Windows-NTLM/Operational'                                = 'NTLM.evtx'
    'Microsoft-Windows-SMBServer/Operational'                           = 'SMBServer_Operational.evtx'
    'Microsoft-Windows-SMBServer/Security'                              = 'SMBServer_Security.evtx'
    'Microsoft-Windows-SMBServer/Audit'                                 = 'SMBServer_Audit.evtx'
    'Microsoft-Windows-SMBClient/Operational'                           = 'SMBClient_Operational.evtx'
    'Microsoft-Windows-SMBClient/Security'                              = 'SMBClient_Security.evtx'
    'Microsoft-Windows-PowerShell/Operational'                          = 'PowerShell.evtx'
    'Microsoft-Windows-TaskScheduler/Operational'                       = 'TaskScheduler.evtx'
}

foreach ($log in $logs.Keys) {
    $out = Join-Path $ExportDir $logs[$log]
    wevtutil epl $log $out
}