# This script opens PS console to execute NLedger test interactively.
[CmdletBinding()]
Param()

[string]$Script:ScriptPath = Split-Path $MyInvocation.MyCommand.Path

# Detects the deployment profile (prod, dev/debug, dev/release) and adds an appropriate path to NLedger binaries
[string]$Script:nLedgerPath = ".."
if (!(Test-Path "$Script:ScriptPath\$Script:nLedgerPath\NLedger-cli.exe" -PathType Leaf)) { 
    [string]$Script:debugNLedgerPath = "..\..\Source\NLedger.CLI\bin\Debug"
    [bool]$debugExists = Test-Path "$Script:ScriptPath\$Script:debugNLedgerPath\NLedger-cli.exe" -PathType Leaf
    [string]$Script:releaseNLedgerPath = "..\..\Source\NLedger.CLI\bin\Release"
    [bool]$releaseExists = Test-Path "$Script:ScriptPath\$Script:releaseNLedgerPath\NLedger-cli.exe" -PathType Leaf
    if (!$debugExists -and !$releaseExists) { throw "Cannot find NLedger-cli.exe" }
    if ($debugExists -and $releaseExists) {
        $debugDate = (Get-Item  "$Script:ScriptPath\$Script:debugNLedgerPath\NLedger-cli.exe").LastWriteTime
        $releaseDate = (Get-Item  "$Script:ScriptPath\$Script:releaseNLedgerPath\NLedger-cli.exe").LastWriteTime
        if ($debugDate -gt $releaseDate) { $Script:nLedgerPath = $Script:debugNLedgerPath } else { $Script:nLedgerPath = $Script:releaseNLedgerPath }
    } else { if ($debugExists) { $Script:nLedgerPath = $Script:debugNLedgerPath } else { $Script:nLedgerPath = $Script:releaseNLedgerPath } }
}
Write-Verbose "Detected NLedger binaries are: $Script:nLedgerPath"
$env:nledgerExePath = "$Script:nLedgerPath\NLedger-cli.exe"

cd $Script:ScriptPath

function run {
[CmdletBinding()]
Param(
    [Parameter(Mandatory=$False)][AllowEmptyString()][string]$filterRegex = ""
)
    if ([string]::IsNullOrWhiteSpace($filterRegex)) {
        .\nltest.ps1 -showReport
    } else {
        .\nltest.ps1 -showReport -filterRegex $filterRegex
    }
}

function xrun {
[CmdletBinding()]
Param(
    [Parameter(Mandatory=$False)][AllowEmptyString()][string]$filterRegex = ""
)
    if ([string]::IsNullOrWhiteSpace($filterRegex)) {
        .\nltest.ps1
    } else {
        .\nltest.ps1 -filterRegex $filterRegex
    }
}

function all {
[CmdletBinding()]
Param(
    [Parameter(Mandatory=$False)][AllowEmptyString()][string]$filterRegex = ""
)
    if ([string]::IsNullOrWhiteSpace($filterRegex)) {
        .\nltest.ps1 -disableIgnoreList
    } else {
        .\nltest.ps1 -disableIgnoreList -filterRegex $filterRegex
    }
}

function help {
[CmdletBinding()]
Param()
     write-host "Interactive testing console helps you execute NLedger test files that are available on the disk.`r`n"
     write-host -NoNewline "It supports several short commands that perform typical activities:`r`n PS>"
     write-host -NoNewline -ForegroundColor Yellow "run"
     write-host -NoNewline "            execute all test files and show a report in the browser;`r`n PS>"
     write-host -NoNewline -ForegroundColor Yellow "run CRITERIA"
     write-host -NoNewline "   execute tests that match the criteria and show a report;`r`n PS>"
     write-host -NoNewline -ForegroundColor Yellow "xrun"
     write-host -NoNewline "           execute all test files and show a summary in the console;`r`n PS>"
     write-host -NoNewline -ForegroundColor Yellow "xrun CRITERIA"
     write-host -NoNewline "  execute matched test files and show a summary in the console;`r`n PS>"
     write-host -NoNewline -ForegroundColor Yellow "all"
     write-host -NoNewline "            execute all test including disabled by the ignore list; the summary is in the console;`r`n PS>"
     write-host -NoNewline -ForegroundColor Yellow "all CRITERIA"
     write-host -NoNewline "   execute matched test files including disabled; the summary is in the console;`r`n PS>"
     write-host -NoNewline -ForegroundColor Yellow "help"
     write-host -NoNewline "           show help page again.`r`n"
     write-host -NoNewline "`r`nTesting script can be called directly:`r`n PS>"
     write-host -ForegroundColor Yellow ".\nltest.ps1 OPTIONAL ARGUMENTS"
     write-host -NoNewline "Use 'get-help' to get detail information about testing script arguments:`r`n PS>"
     write-host -ForegroundColor Yellow "get-help .\nltest.ps1"
     write-host -NoNewline "`r`nType '"
     write-host -NoNewline -ForegroundColor Yellow "exit"
     write-host "' or close the console window when you finish.`r`n"
}


write-host -ForegroundColor White "NLedger Testing Toolkit - Interactive console"
write-host ""
help
