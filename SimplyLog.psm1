Set-StrictMode -Version Latest
<#
.synopsis
    Writes log information to the console and appends to a file.

.description
    The Write-PSLog function writes the input to a host and also appends the
    input to a file.  The input is formatted into a custom format that includes
    timestamp, type, section (if included) and the message.

    TYPE: [yyyy-MM-dd HH:mm:ss][LogSection] message

.parameter Message
    Message(s) to be logged.

.parameter Path
    Path to the file.  If not specified, uses previously specified path.
    If one was not previously specified, fails.

.parameter LogSection
    Descriptor to identify the message.

.parameter LogType
    Determines which type of message is being logged (Info, Warn, Error).
    Info is the default, Warn will display as the "WARNING" colors and
    Error will display as the "ERROR" colors.

.parameter NoTimestamp
    Removes the timestamp from the message.

.parameter ClearLog
    Clears the file prior to appending.

.parameter Quiet
    Do not output to console (host/screen).

#>
Function Write-PSLog
{
    [cmdletbinding(DefaultParameterSetName="None")]
    Param([Parameter(Mandatory,ValueFromPipeline,ValueFromPipelineByPropertyName)][string[]]$Message
            , [Parameter(Mandatory,ParameterSetName="Path")][string]$Path
            , [Parameter(ParameterSetName="Path")][switch]$ClearLog
            , [Parameter(ValueFromPipelineByPropertyName)][string]$LogSection
            , [Parameter(ValueFromPipelineByPropertyName)][ValidateSet("Info","Warn","Error")][string]$LogType = "Info"
            , [Parameter(ValueFromPipelineByPropertyName)][switch]$NoTimestamp
            , [Parameter(ValueFromPipelineByPropertyName)][switch]$Quiet
        )
    
    Begin
    {
        $ErrorActionPreference = "Stop"
        If($PSCmdlet.ParameterSetName -eq "Path") {
            If(-not (Test-Path $Path -PathType Leaf)) { New-Item -ItemType File -Path $Path -Force | Out-Null }
            ElseIf($ClearLog) { Clear-Content -Path $Path -Force }
            $Script:PSLogPath = $Path
        }
        ElseIf(-not (Get-Variable -Scope Script | Where-Object Name -eq PSLogPath)) {
            Throw "Path has not been specified.  Rerun Write-PSLog and include the 'Path' parameter."
        }
        ElseIf(-not (Test-Path $Script:PSLogPath -PathType Leaf)) {
            Throw "The Path is not a valid file.  Rerun Write-PSLog and include the 'Path' parameter."
        }
    }

    Process
    {
        ForEach($m in $Message)
        {
            [string]$logMessage = $null
            If($NoTimestamp -and -not $LogSection) { $logMessage = "{0}: {1}" -f $LogType.ToUpper(), $m }
            ElseIf($NoTimestamp -and $LogSection) { $logMessage = "{0}: [{1}] {2}" -f $LogType.ToUpper(), $LogSection, $m }
            ElseIf(-not $LogSection) { $logMessage = "{0}: [{1:yyyy-MM-dd HH-mm-ss}] {2}" -f $LogType.ToUpper(), (Get-Date), $m }
            Else { $logMessage = "{0}: [{1:yyyy-MM-dd HH-mm-ss}] [{2}] {3}" -f $LogType.ToUpper(), (Get-Date), $LogSection, $m }

            Add-Content -Path $Script:PSLogPath -Value $logMessage
            
            If(-not $Quiet)
            {
                Switch ($LogType)
                {
                    "Info"{ Write-Host $logMessage }
                    "Warn" { Write-Host $logMessage -ForegroundColor $host.PrivateData.WarningForegroundColor -BackgroundColor $host.PrivateData.WarningBackgroundColor }
                    "Error" { Write-Host $logMessage -ForegroundColor $host.PrivateData.ErrorForegroundColor -BackgroundColor $host.PrivateData.ErrorBackgroundColor }
                }
            }
        }
    }
}

Export-ModuleMember -Function Write-PSLog