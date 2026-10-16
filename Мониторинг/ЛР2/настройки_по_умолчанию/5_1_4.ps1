<#
.SYNOPSIS
    Заполняет таблицу «Журнал | Макс. размер, байт | Факт. размер, байт»
    для журналов из раздела 3.3.
.DESCRIPTION
    Для каждого канала берёт MaximumSizeInBytes и FileSize через
    Get-WinEvent -ListLog. Если канал не найден или отключён — пишет
    «не найден» / «отключён».
#>

# --- Список журналов (как в таблице 3.3) ---
$logs = @(
    'Directory Service'
    'Security'
    'Microsoft-Windows-GroupPolicy/Operational'
    'DNS Server'
    'Microsoft-Windows-DNSServer/Audit'
    'Microsoft-Windows-Dhcp-Server/AuditLog'
    'Microsoft-Windows-Dhcp-Server/Operational'
    'Microsoft-Windows-Dhcp-Server/DebugLogs'
    'Microsoft-Windows-RemoteAccess-RemoteAccessServer/Operational'
    'Microsoft-Windows-RemoteAccess-RemoteAccessServer/Admin'
    'Microsoft-Windows-RasRoutingProtocols/Operational'
    'Microsoft-Windows-WinNat/Operational'
    'Microsoft-Windows-WFP/Operational'
    'Microsoft-Windows-Windows Firewall With Advanced Security/Firewall'
    'System'
    'Microsoft-Windows-NTLM/Operational'
    'Microsoft-Windows-SMBServer/Operational'
    'Microsoft-Windows-SMBServer/Security'
    'Microsoft-Windows-SMBServer/Audit'
    'Microsoft-Windows-SMBClient/Operational'
    'Microsoft-Windows-SMBClient/Security'
    'Microsoft-Windows-PowerShell/Operational'
    'Microsoft-Windows-TaskScheduler/Operational'
)

# --- Сбор данных ---
$rows = foreach ($log in $logs) {
    $info = Get-WinEvent -ListLog $log -ErrorAction SilentlyContinue
    if ($null -eq $info) {
        [PSCustomObject]@{
            'Журнал'            = $log
            'Макс. размер, байт' = 'не найден'
            'Факт. размер, байт' = 'не найден'
        }
        continue
    }

    if (-not $info.IsEnabled) {
        [PSCustomObject]@{
            'Журнал'            = $log
            'Макс. размер, байт' = [int64]$info.MaximumSizeInBytes
            'Факт. размер, байт' = 'отключён'
        }
        continue
    }

    [PSCustomObject]@{
        'Журнал'            = $log
        'Макс. размер, байт' = [int64]$info.MaximumSizeInBytes
        'Факт. размер, байт' = [int64]$info.FileSize
    }
}

# --- Вывод в консоль ---
$rows | Format-Table -AutoSize

# --- Сохранение в CSV ---
$outCsv = 'C:\AuditResearch\Baseline\logs_size.csv'
$rows | Export-Csv -Path $outCsv -NoTypeInformation -Encoding UTF8
Write-Host "`nРезультат сохранён: $outCsv" -ForegroundColor Green