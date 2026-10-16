<#
.SYNOPSIS
    Измерение фоновой активности журналирования (расширенная версия + Event ID).
.DESCRIPTION
    Для каждого источника фиксирует:
      T  — длительность интервала, с
      N  — количество событий за интервал
      V  — прирост размера журнала, байт (корректно при перезаписи)
      λ  — N / T, событий/с
      R  — V / T, байт/с
      s̄  — V / N, байт/событие
    Дополнительно выводит список Event ID с количеством.
    Длительность задаётся параметром $DurationSec.
#>

# --- Параметры ---
$OutputDir   = 'C:\AuditResearch\Baseline'
$DurationSec = 600                        # длительность наблюдения, с (10 минут)
$Timestamp   = Get-Date -Format 'yyyyMMdd_HHmmss'

if (-not (Test-Path $OutputDir)) {
    New-Item -Path $OutputDir -ItemType Directory -Force | Out-Null
}

# --- Список каналов ---
$channels = @(
    # --- Базовые ---
    @{ Source = 'Security';                    LogName = 'Security' }
    @{ Source = 'System';                      LogName = 'System' }
    @{ Source = 'Application';                 LogName = 'Application' }

    # --- AD DS / GPO ---
    @{ Source = 'Directory Service';           LogName = 'Directory Service' }
    @{ Source = 'GroupPolicy/Operational';     LogName = 'Microsoft-Windows-GroupPolicy/Operational' }

    # --- DNS ---
    @{ Source = 'DNS Server';                  LogName = 'DNS Server' }
    @{ Source = 'DNSServer/Audit';             LogName = 'Microsoft-Windows-DNSServer/Audit' }

    # --- DHCP ---
    @{ Source = 'Dhcp-Server/AuditLog';        LogName = 'Microsoft-Windows-Dhcp-Server/AuditLog' }
    @{ Source = 'Dhcp-Server/Operational';     LogName = 'Microsoft-Windows-Dhcp-Server/Operational' }

    # --- RRAS ---
    @{ Source = 'RemoteAccess/Operational';    LogName = 'Microsoft-Windows-RemoteAccess-RemoteAccessServer/Operational' }
    @{ Source = 'RemoteAccess/Admin';          LogName = 'Microsoft-Windows-RemoteAccess-RemoteAccessServer/Admin' }
    @{ Source = 'RasRoutingProtocols/Operational'; LogName = 'Microsoft-Windows-RasRoutingProtocols/Operational' }

    # --- NAT / WFP / Firewall ---
    @{ Source = 'WFP/Operational';             LogName = 'Microsoft-Windows-WFP/Operational' }
    @{ Source = 'Firewall';                    LogName = 'Microsoft-Windows-Windows Firewall With Advanced Security/Firewall' }

    # --- NTLM ---
    @{ Source = 'NTLM/Operational';            LogName = 'Microsoft-Windows-NTLM/Operational' }

    # --- SMB (сервер) ---
    @{ Source = 'SMBServer/Operational';       LogName = 'Microsoft-Windows-SMBServer/Operational' }
    @{ Source = 'SMBServer/Security';          LogName = 'Microsoft-Windows-SMBServer/Security' }
    @{ Source = 'SMBServer/Audit';             LogName = 'Microsoft-Windows-SMBServer/Audit' }

    # --- SMB (клиент) ---
    @{ Source = 'SMBClient/Operational';       LogName = 'Microsoft-Windows-SMBClient/Operational' }
    @{ Source = 'SMBClient/Security';          LogName = 'Microsoft-Windows-SMBClient/Security' }

    # --- PowerShell / TaskScheduler ---
    @{ Source = 'PowerShell/Operational';      LogName = 'Microsoft-Windows-PowerShell/Operational' }
    @{ Source = 'TaskScheduler/Operational';   LogName = 'Microsoft-Windows-TaskScheduler/Operational' }
)

# --- Замер "до" ---
$start = Get-Date
"$($start.ToString('yyyy-MM-dd HH:mm:ss'))" |
    Out-File "$OutputDir\background_start.txt" -Encoding UTF8
Write-Host "Старт наблюдения: $($start.ToString('yyyy-MM-dd HH:mm:ss'))" -ForegroundColor Cyan

$before = @{}
foreach ($ch in $channels) {
    $info = Get-WinEvent -ListLog $ch.LogName -ErrorAction SilentlyContinue
    if ($info -and $info.IsEnabled) {
        $before[$ch.LogName] = [PSCustomObject]@{
            Enabled   = $true
            FileSize  = [int64]$info.FileSize
            RecordCnt = [int64]$info.RecordCount
        }
    } else {
        $before[$ch.LogName] = [PSCustomObject]@{
            Enabled   = $false
            FileSize  = $null
            RecordCnt = $null
        }
    }
}

# --- Ожидание с фиксированной длительностью ---
Write-Host "Мониторинг начался" -ForegroundColor Green
Write-Host "Длительность наблюдения: $DurationSec с ($([math]::Round($DurationSec/60,2)) мин)" -ForegroundColor Yellow
Write-Host "Ожидание..." -ForegroundColor Yellow

$deadline = (Get-Date).AddSeconds($DurationSec)
while ((Get-Date) -lt $deadline) {
    $left = [math]::Round(($deadline - (Get-Date)).TotalSeconds, 0)
    Write-Progress -Activity "Измерение фоновой активности" `
                   -Status "Осталось: $left с" `
                   -PercentComplete ([math]::Min(100, (($DurationSec - $left) / $DurationSec) * 100))
    Start-Sleep -Seconds 5
}
Write-Progress -Activity "Измерение фоновой активности" -Completed

# --- Замер "после" ---
$end = Get-Date
"$($end.ToString('yyyy-MM-dd HH:mm:ss'))" |
    Out-File "$OutputDir\background_end.txt" -Encoding UTF8
Write-Host "Конец наблюдения: $($end.ToString('yyyy-MM-dd HH:mm:ss'))" -ForegroundColor Cyan

$duration = [math]::Round(($end - $start).TotalSeconds, 0)

$after = @{}
foreach ($ch in $channels) {
    $info = Get-WinEvent -ListLog $ch.LogName -ErrorAction SilentlyContinue
    if ($info -and $info.IsEnabled) {
        $after[$ch.LogName] = [PSCustomObject]@{
            Enabled   = $true
            FileSize  = [int64]$info.FileSize
            RecordCnt = [int64]$info.RecordCount
        }
    } else {
        $after[$ch.LogName] = [PSCustomObject]@{
            Enabled   = $false
            FileSize  = $null
            RecordCnt = $null
        }
    }
}

# --- Сбор событий и их ID по каждому каналу ---
$eventIdRows = New-Object System.Collections.Generic.List[object]
$eventsByChannel = @{}

foreach ($ch in $channels) {
    $b = $before[$ch.LogName]
    $a = $after[$ch.LogName]

    if (-not $b.Enabled -and -not $a.Enabled) {
        $eventsByChannel[$ch.LogName] = @()
        continue
    }

    try {
        $evts = @(Get-WinEvent -FilterHashtable @{
            LogName   = $ch.LogName
            StartTime = $start
            EndTime   = $end
        } -ErrorAction Stop)
    }
    catch {
        $evts = @()
    }

    $eventsByChannel[$ch.LogName] = $evts

    if ($evts.Count -gt 0) {
        $evts |
            Group-Object Id |
            ForEach-Object {
                $sampleLvl = ($_.Group | Select-Object -First 1).LevelDisplayName
                $eventIdRows.Add([PSCustomObject]@{
                    Источник   = $ch.Source
                    Канал      = $ch.LogName
                    EventID    = $_.Name
                    Уровень    = $sampleLvl
                    Количество = $_.Count
                })
            }
    }
}

# --- Расчёт по каналам ---
$details = foreach ($ch in $channels) {
    $b = $before[$ch.LogName]
    $a = $after[$ch.LogName]
    $evts = $eventsByChannel[$ch.LogName]

    if (-not $b.Enabled -and -not $a.Enabled) {
        [PSCustomObject]@{
            Источник            = $ch.Source
            Канал               = $ch.LogName
            T_с                 = $duration
            N_шт                = 'журналирование отсутствует'
            V_байт              = 'журналирование отсутствует'
            V_xml_байт          = 'журналирование отсутствует'
            'λ_событий/с'       = 'журналирование отсутствует'
            R_байт_с            = 'журналирование отсутствует'
            's̄_байт/событие'    = 'журналирование отсутствует'
            EventIDs            = 'журналирование отсутствует'
            Статус              = 'журналирование отсутствует (канал отключён или не найден)'
        }
        continue
    }

    $N = $evts.Count
    $Vfile = $a.FileSize - $b.FileSize

    $Vxml = 0
    if ($N -gt 0) {
        foreach ($e in $evts) {
            try   { $Vxml += $e.ToXml().Length }
            catch { }
        }
    }

    if ($Vfile -gt 0) {
        $V = $Vfile
    }
    elseif ($N -gt 0) {
        $V = $Vxml
    }
    else {
        $V = 0
    }

    $lambda = if ($duration -gt 0) { [math]::Round($N / $duration, 6) } else { 0 }
    $R      = if ($duration -gt 0) { [math]::Round($V / $duration, 2) } else { 0 }
    $sbar   = if ($N -gt 0)        { [math]::Round($V / $N, 2) }        else { '—' }

    $idSummary = if ($N -gt 0) {
        ($evts | Group-Object Id | Sort-Object Count -Descending |
            ForEach-Object { "$($_.Name)×$($_.Count)" }) -join '; '
    } else { '—' }

    [PSCustomObject]@{
        Источник            = $ch.Source
        Канал               = $ch.LogName
        T_с                 = $duration
        N_шт                = $N
        V_байт              = $V
        V_xml_байт          = $Vxml
        'λ_событий/с'       = $lambda
        R_байт_с            = $R
        's̄_байт/событие'    = $sbar
        EventIDs            = $idSummary
        Статус              = 'OK'
    }
}

# --- Сводка по источникам ---
$summary = $details |
    Group-Object Источник |
    ForEach-Object {
        $numeric = $_.Group | Where-Object { $_.N_шт -is [int] -or $_.N_шт -is [int64] }
        if ($numeric.Count -eq 0) {
            [PSCustomObject]@{
                Источник            = $_.Name
                T_с                 = $duration
                N_шт                = 'журналирование отсутствует'
                V_байт              = 'журналирование отсутствует'
                'λ_событий/с'       = 'журналирование отсутствует'
                R_байт_с            = 'журналирование отсутствует'
                's̄_байт/событие'    = 'журналирование отсутствует'
                EventIDs            = 'журналирование отсутствует'
                Каналы              = ($_.Group.Канал -join '; ')
            }
            return
        }

        $Nsum  = ($numeric | Measure-Object N_шт -Sum).Sum
        $Vsum  = ($numeric | Measure-Object V_байт -Sum).Sum
        $lam   = if ($duration -gt 0) { [math]::Round($Nsum / $duration, 6) } else { 0 }
        $Rsum  = if ($duration -gt 0) { [math]::Round($Vsum / $duration, 2) } else { 0 }
        $sbar  = if ($Nsum -gt 0)     { [math]::Round($Vsum / $Nsum, 2) }     else { '—' }
        $ids   = (($_.Group | Where-Object { $_.EventIDs -and $_.EventIDs -ne '—' }).EventIDs) -join '; '

        [PSCustomObject]@{
            Источник            = $_.Name
            T_с                 = $duration
            N_шт                = $Nsum
            V_байт              = $Vsum
            'λ_событий/с'       = $lam
            R_байт_с            = $Rsum
            's̄_байт/событие'    = $sbar
            EventIDs            = if ($ids) { $ids } else { '—' }
            Каналы              = ($_.Group.Канал -join '; ')
        }
    }

# --- Сохранение ---
$detailCsv   = Join-Path $OutputDir "background_details_$Timestamp.csv"
$summaryCsv  = Join-Path $OutputDir "background_summary_$Timestamp.csv"
$eventIdCsv  = Join-Path $OutputDir "background_eventids_$Timestamp.csv"

$details      | Export-Csv -Path $detailCsv  -NoTypeInformation -Encoding UTF8
$summary      | Export-Csv -Path $summaryCsv -NoTypeInformation -Encoding UTF8
$eventIdRows  | Export-Csv -Path $eventIdCsv -NoTypeInformation -Encoding UTF8

# --- Сообщение об окончании ---
Write-Host "Измерения закончены." -ForegroundColor Magenta