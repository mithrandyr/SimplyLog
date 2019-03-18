<#
https://stackoverflow.com/questions/1988833/converting-color-to-consolecolor
public static System.ConsoleColor FromColor(System.Drawing.Color c) {
    int index = (c.R > 128 | c.G > 128 | c.B > 128) ? 8 : 0; // Bright bit
    index |= (c.R > 64) ? 4 : 0; // Red bit
    index |= (c.G > 64) ? 2 : 0; // Green bit
    index |= (c.B > 64) ? 1 : 0; // Blue bit
    return (System.ConsoleColor)index;
}



Public Shared Function FromColor(c As System.Drawing.Color) As System.ConsoleColor
	Dim index As Integer = If((c.R > 128 Or c.G > 128 Or c.B > 128), 8, 0)
	' Bright bit
	index = index Or If((c.R > 64), 4, 0)
	' Red bit
	index = index Or If((c.G > 64), 2, 0)
	' Green bit
	index = index Or If((c.B > 64), 1, 0)
	' Blue bit
	Return DirectCast(index, System.ConsoleColor)
End Function


#>
Function ConvertColor($Color) {
    [int]$Index = 0
    If($Color.R -gt 128 -or $Color.G -gt 128 -or $Color.B -gt 128) { $index = 8 }

    If($Color.R -gt 64) { $index = $index -bor 4 }
    If($Color.G -gt 64) { $index = $index -bor 2 }
    If($Color.B -gt 64) { $index = $index -bor 1 }

    Return [System.ConsoleColor]$index    
}


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

        
        [ConsoleColor]$WarnFront, [ConsoleColor]$WarnBack, [ConsoleColor]$ErrFront, [ConsoleColor]$ErrBack = 0, 0, 0, 0
        If($host.PrivateData.WarningBackgroundColor) {
            if($host.PrivateData.WarningBackgroundColor -is [ConsoleColor]) {
                [ConsoleColor]$WarnFront = $host.PrivateData.WarningForegroundColor
                [ConsoleColor]$WarnBack = $host.PrivateData.WarningBackgroundColor
                [ConsoleColor]$ErrFront = $host.PrivateData.ErrorForegroundColor
                [ConsoleColor]$ErrBack = $host.PrivateData.ErrorBackgroundColor
            }
            Else {
                [ConsoleColor]$WarnFront = ConvertColor -Color $host.PrivateData.WarningForegroundColor
                [ConsoleColor]$WarnBack = ConvertColor -Color $host.PrivateData.WarningBackgroundColor
                [ConsoleColor]$ErrFront = ConvertColor -Color $host.PrivateData.ErrorForegroundColor
                [ConsoleColor]$ErrBack = ConvertColor -Color $host.PrivateData.ErrorBackgroundColor
            }
        }
        Else {
            $WarnFront, $WarnBack = "Yellow", "Black"
            $ErrFront, $ErrBack = "Red", "Black"
        }
    }

    Process
    {
        ForEach($m in $Message)
        {
            [string]$logMessage = $null
            If($NoTimestamp -and -not $LogSection) { $logMessage = "{0}: {1}" -f $LogType.ToUpper(), $m }
            ElseIf($NoTimestamp -and $LogSection) { $logMessage = "{0}: [{1}] {2}" -f $LogType.ToUpper(), $LogSection, $m }
            ElseIf(-not $LogSection) { $logMessage = "{0}: [{1:yyyy-MM-dd HH:mm:ss}] {2}" -f $LogType.ToUpper(), (Get-Date), $m }
            Else { $logMessage = "{0}: [{1:yyyy-MM-dd HH:mm:ss}] [{2}] {3}" -f $LogType.ToUpper(), (Get-Date), $LogSection, $m }

            Add-Content -Path $Script:PSLogPath -Value $logMessage
            
            If(-not $Quiet)
            {
                Switch ($LogType)
                {
                    "Info"{ Write-Host $logMessage }
                    "Warn" { Write-Host $logMessage -ForegroundColor $WarnFront -BackgroundColor $WarnBack }
                    "Error" { Write-Host $logMessage -ForegroundColor $ErrFront -BackgroundColor $ErrBack }
                }
            }
        }
    }
}

Export-ModuleMember -Function Write-PSLog