# SimplyLog
## Introduction
Simple PowerShell Logger that outputs to the screen and to a file.  


    Write-PSLog -Path {somepath} -Message {firstMessage}
    Write-PSLog -Message {SecondMessage}


Though the 'Path' parameter is not used the second time, the second invocation of 
Write-PSLog will write to the same path.  In order to log to a different path, rerun 
Write-PSLog with a new 'Path' parameter.

Also, when using LogType ERROR or WARN, the console coloring will match the same 
coloring as if you used Write-Error or Write-Warning.

## Installation
Module is up on http://www.powershellgallery.com

    Install-Module SimplyLog

## Parameter Options

|Parameter Name|Data Type|Description|
|:---|:---:|:---|
|Message|[string[]]|Messages to be logged|
|LogType|[string]|Valid Values: INFO, WARN, ERROR|
|LogSection|[string]|Optional prefix to the message|
|NoTimestamp|[switch]|Prevents a timestamp from being included|
|Quiet|[switch]|Only outputs to the file, not to the console|
|Path|[string]|Path to the file for logging|
|ClearLog|[switch|Clears the file before logging (requires -Path)|

## Log Output
**Format**

    <LogType>: [<Timestmap>] [<LogSection>] <Message>

**Examples**

    INFO: [2017-02-24 14-45-40] Message without a section
    INFO: [2017-02-24 14-46-11] [somesection] Message with a section
    ERROR: [2017-02-24 14-46-11] [somesection] Error Message with a section
    WARN: [2017-02-24 14-46-11] [somesection] Warn Message with a section
    INFO: [somesection] Message with a section but no timestamp
    INFO: Message, no section, no timestamp
    