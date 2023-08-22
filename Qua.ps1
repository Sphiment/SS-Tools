$QuaVersion = '1.0.0'
function Test-InternetConnection {
    $webRequest = [System.Net.WebRequest]::Create("http://www.google.com")
    $webRequest.Timeout = 5000
    try {
        $response = $webRequest.GetResponse()
        $response.Close()
        Clear-Host
    } catch {
        Write-Host "Internet connection is not available. Check your connection and try again"
        Start-Sleep 5
        Exit
    }
}
Test-InternetConnection


$filePath = "$env:ProgramFiles\PowerShell\7\pwsh.exe"
$isAdmin = ([System.Security.Principal.WindowsPrincipal] [System.Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)

function Start-Pwsh {
    $scriptPath = $script:MyInvocation.MyCommand.Definition
    $arguments = "-NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`""
    Start-Process pwsh -ArgumentList $arguments -Verb RunAs
}

function Start-PowerShell {
    $scriptPath = $script:MyInvocation.MyCommand.Definition
    $arguments = "-NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`""
    Start-Process powershell -ArgumentList $arguments -Verb RunAs
}

function Get-PSVersion {
    if ($PSVersionTable.PSVersion -lt 7.1 ) {
        if (Test-Path $filePath -PathType Leaf) {
            Start-Pwsh
            Exit
        } else {
            if (-not $isAdmin) {
                Start-PowerShell
                Exit
            }
            Invoke-Expression "& { $(Invoke-RestMethod 'https://aka.ms/install-powershell.ps1') } -Destination '$env:ProgramFiles\PowerShell\7' -DoNotOverwrite -AddToPath "
            Write-Host "Done Installing latest stable version of PowerShell. Wait a few seconds"
            Start-Sleep 3
            Get-PSVersion
        }
    } else {
        if (-not $isAdmin) {
            Start-Pwsh
            Exit
        }
    }
}

if (Test-Path $filePath -PathType Leaf) {
    Get-PSVersion
    if (-not $isAdmin) {
        Start-Pwsh
        Pause
        Exit
    }
} else {
    Get-PSVersion
}


Import-Module -Name Appx -UseWindowsPowerShell -WarningAction SilentlyContinue
[Console]::BackgroundColor = "Black"
[console]::WindowWidth = 100
[console]::WindowHeight = 30
[console]::BufferWidth = [console]::WindowWidth

$White = [char]27 + "[38;2;255;255;255m"
$Pink = [char]27 + "[38;2;225;000;128m"
$Green = [char]27 + "[38;2;0;255;0m"
$Silver = [char]27 + "[38;2;128;128;128m"

function Write-Qua {
    param (
        [string]$Text,
        [string]$Color = $White,
        [string]$P = 0
    )

    $OriginalForegroundColor = [Console]::ForegroundColor
    $OriginalBackgroundColor = [Console]::BackgroundColor

    $maxLineLength = ($Text | Measure-Object -Property Length -Maximum).Maximum

    $fixedPadding = [Math]::Max(0, ((100 - $maxLineLength) / 2) +$P )

    foreach ($line in $Text) {
        $linePadding = (" " * $fixedPadding)
        $paddedLine = $linePadding + $line
    Write-Host "${Color}$paddedline${Color}"
}
    [Console]::ForegroundColor = $OriginalForegroundColor
    [Console]::BackgroundColor = $OriginalBackgroundColor
}

function Write-Log {
    param (
        [string]$Message,
        [string]$P = 0,
        [string]$S = 2,
        [string]$N = 0
    )

    $LogEntry = "$(Get-Date -Format 'yyyy/MM/dd HH:mm:ss') - $Message" 
    $LogEntry | Out-File -FilePath $LogPath -Append -Encoding utf8
    
    if ($N -eq 0) {
        Write-Qua -Text $Message -Color $Green -P $P
        Start-Sleep -Seconds $S
    } else {
    }
}


$Counter = 1
$TempFolderName = "Qua run-1"
do {
    $FolderExists = Test-Path -Path "$PSScriptRoot\$TempFolderName"
    if ($FolderExists) {
        $Counter++
        $TempFolderName = "Qua run-$Counter"
    }    
    else {
        $TempFolder = "$PSScriptRoot\$TempFolderName"
        New-Item -ItemType Directory -Path $TempFolder | Out-Null
        $LogPath = Join-Path -Path $TempFolder -ChildPath "Log.txt"
        Write-Log -Message "Check '$LogPath' if any error happens" -S 2
        Write-Log -Message "Please save and close oppen apps" -S 4
        Clear-Host
    }
} while ($FolderExists)

function QuaLogo {
    Clear-Host
    Invoke-Expression "& { $(Invoke-RestMethod 'https://raw.githubusercontent.com/Sphiment/Qua/main/Stuff/QuaTitle') }"
}

function Tweaks {
    $RegistryCSV = Invoke-RestMethod -Uri 'https://raw.githubusercontent.com/Sphiment/Qua/main/Stuff/Tweaks' | ConvertFrom-Csv

    $TotalChanges = $RegistryCSV.Count
    $CurrentChangeNumber = 0

    foreach ($Change in $RegistryCSV) {
        $CurrentChangeNumber++
        QuaLogo
        Write-Qua -Text "[$CurrentChangeNumber/$TotalChanges] $($Change.Comment)"
        Write-Qua -Text "Yes[Y], Skip[S], Menu[M], Apply All[A]"

        $ChoiceKey = $null
        while ($ChoiceKey -notin @("Y", "S", "M", "A")) {
            Write-Host "                                                >" -NoNewline
            $ChoiceKey = [System.Console]::ReadKey($true).KeyChar.ToString().ToUpper()
            if ($ChoiceKey -notin @("Y", "S", "M", "A")) {
                ""
            }
        }
        try {
            switch ($ChoiceKey) {
                "Y" {
                    $RegistryPath = "$($Change.Hive):\$($Change.Path)"
                    $RegistryName = $Change.Name
                    $RegistryValue = $Change.Value
                    $RegistryType = @{
                        "REG_SZ" = "String"
                        "REG_EXPAND_SZ" = "ExpandString"
                        "REG_BINARY" = "Binary"
                        "REG_DWORD" = "DWord"
                        "REG_QWORD" = "QWord"
                        "REG_MULTI_SZ" = "MultiString"
                    }[$Change.Type]

                    if (-not (Test-Path $RegistryPath)) {
                        New-Item -Path $RegistryPath -Force | Out-Null
                    }

                    Set-ItemProperty -Path $RegistryPath -Name $RegistryName -Value $RegistryValue -Type $RegistryType
                }
                "S" { }
                "M" {
                    ShowMenu
                }
                "A" {
                    foreach ($Change in $RegistryCSV) {
                    $RegistryPath = "$($Change.Hive):\$($Change.Path)"
                    $RegistryName = $Change.Name
                    $RegistryValue = $Change.Value
                    $RegistryType = @{
                        "REG_SZ" = "String"
                        "REG_EXPAND_SZ" = "ExpandString"
                        "REG_BINARY" = "Binary"
                        "REG_DWORD" = "DWord"
                        "REG_QWORD" = "QWord"
                        "REG_MULTI_SZ" = "MultiString"
                    }[$Change.Type]

                    if (-not (Test-Path $RegistryPath)) {
                        New-Item -Path $RegistryPath -Force | Out-Null
                    }

                    Set-ItemProperty -Path $RegistryPath -Name $RegistryName -Value $RegistryValue -Type $RegistryType
                }
                    Clear-Host
                    QuaLogo
                    Stop-Process -Name explorer -Force
                    Write-Log -Message "Tweaks Done!"
                    ShowMenu
                }
            }
        } catch {
            Write-Log -Message "An error occurred while applying a tweak: $($_.Exception.Message)" -S 2
        }

        Clear-Host
    }

    Clear-Host
    QuaLogo
    Stop-Process -Name explorer -Force
    Write-Log -Message "Tweaks Done!"
    ShowMenu
}

function Debloat {
    $NoneApps = @(
        "1527c705-839a-4832-9118-54d4Bd6a0c89",
        "c5e2524a-ea46-4f67-841f-6a9465d9d515",
        "E2A4F912-2574-4A75-9BB0-0D023378592B",
        "F46D4000-FD22-4DB4-AC8E-4E1DDDE828FE",
        "Microsoft.AAD.BrokerPlugin",
        "Microsoft.AccountsControl",
        "Microsoft.AsyncTextService",
        "Microsoft.BioEnrollment",
        "Microsoft.CredDialogHost",
        "Microsoft.ECApp",
        "Microsoft.LockApp",
        "Microsoft.MicrosoftEdgeDevToolsClient",
        "Microsoft.MicrosoftEdge",
        "Microsoft.Win32WebViewHost",
        "Microsoft.Windows.Apprep.ChxApp",
        "Microsoft.Windows.AssignedAccessLockApp",
        "Microsoft.Windows.CallingShellApp",
        "Microsoft.Windows.CapturePicker",
        "Microsoft.Windows.CloudExperienceHost",
        "Microsoft.Windows.ContentDeliveryManager",
        "Microsoft.Windows.NarratorQuickStart",
        "Microsoft.Windows.OOBENetworkCaptivePortal",
        "Microsoft.Windows.OOBENetworkConnectionFlow",
        "Microsoft.Windows.ParentalControls",
        "Microsoft.Windows.PeopleExperienceHost",
        "Microsoft.Windows.PinningConfirmationDialog",
        "Microsoft.Windows.Search",
        "Microsoft.Windows.SecHealthUI",
        "Microsoft.Windows.SecureAssessmentBrowser",
        "Microsoft.Windows.ShellExperienceHost",
        "Microsoft.Windows.StartMenuExperienceHost",
        "Microsoft.Windows.XGpuEjectDialog",
        "Microsoft.XboxGameCallableUI",
        "MicrosoftWindows.Client.CBS",
        "MicrosoftWindows.UndockedDevKit",
        "NcsiUwpApp",
        "Windows.CBSPreview",
        "windows.immersivecontrolpanel",
        "Windows.PrintDialog"
    )
    try {
        $Bloat = Get-AppxPackage -AllUsers | Select-Object -ExpandProperty Name
        $AppsToRemove = Compare-Object $Bloat $NoneApps | Where-Object { $_.SideIndicator -eq '<=' } | Select-Object -ExpandProperty InputObject

        $TotalApps = $AppsToRemove.Count
        $CurrentAppNumber = 0

        $AppsToRemove | ForEach-Object {
            $CurrentAppNumber++
            $App = $_
            QuaLogo
            Write-Qua -Text "[$CurrentAppNumber/$TotalApps] Do you want to uninstall $App ?"
            Write-Qua -Text "Yes[Y], No[N], Menu[M]"

            $ChoiceKey = $null
            while ($ChoiceKey -notin @("Y", "N", "M")) {
                Write-Host "                                                >" -NoNewline
                $ChoiceKey = [System.Console]::ReadKey($true).KeyChar.ToString().ToUpper()
                if ($ChoiceKey -notin @("Y", "N", "M")) {
                    " "
                }
            }

            $UserChoice = $ChoiceKey
            switch ($UserChoice) {
                "Y" {
                    " "
                    Write-Qua -Text "Uninstalling $App ..."
                    Set-Variable ProgressPreference SilentlyContinue 
                    Get-AppxPackage -AllUsers -Name $App | Remove-AppxPackage -ErrorAction SilentlyContinue | Out-Null
                    Get-AppxProvisionedPackage -Online | Where-Object DisplayName -Like $App | Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue | Out-Null
                }
                "N" {}
                "M" { ShowMenu }
            }
            Clear-Host
        }

        QuaLogo
        Stop-Process -Name explorer -Force
        Write-Log -Message "Debloat Done!" -S 3
    }
    catch {
        Write-Log -Message "An error occurred during debloating: $App" -S 5
    }
    Write-Log -Message "Reopening tool to refresh"
    Start-Pwsh
    Exit
}
function Info {
    QuaLogo
    Write-Qua -Text "This tool is made by Sphiment"
    Write-Qua -Text " "
    Write-Qua -Text "Twitter [${Pink}T${White}]          Instagram[${Pink}I${White}]          Github[${Pink}G${White}]" -Color $White -P 57
    Write-Qua -Text " "
    Write-Qua -Text "Menu[${Pink}M${White}]" -Color $White -P 19
    Write-Qua -Text " "
    Write-Host "                                                >" -NoNewline
    $ChoiceKey = [System.Console]::ReadKey($true).KeyChar.ToString().ToUpper()
    switch ($ChoiceKey) {
        "T" {Start-Process "https://twitter.com/Sphiment_" ; Info}
        "I" { Start-Process "https://www.instagram.com/km8x/" ;Info }
        "G" { Start-Process "https://github.com/Sphiment" ;Info }
        "M" { ShowMenu }
        Default { Info }
    }
}

function ShowMenu {
    QuaLogo
    Write-Qua -Text "Tweaks [${Pink}T${White}]          Debloat[${Pink}D${White}]          Info[${Pink}I${White}]" -Color $White -P 57
    Write-Qua -Text " "
    Write-Qua -Text "Storage Cleaner[${Pink}C${White}]          Exit[${Pink}E${White}]" -Color $White -P 38
    Write-Qua -Text " "
    Write-Qua -Text " "
    Write-Host "                                                >" -NoNewline
    $ChoiceKey = [System.Console]::ReadKey($true).KeyChar.ToString().ToUpper()
    switch ($ChoiceKey) {
        "T" { Tweaks }
        "D" { Debloat }
        "I" { Info }
        "C" { Write-Host "soon"; Start-Sleep 3; ShowMenu }
        "E" { Exit }
        Default { ShowMenu }
    }
}

ShowMenu