param (    
    <#
    .PARAMETER models
    Specifies the path to the PBIR (Power BI Report) file or folder to analyze with BPA.    
    #>
    $reports = @("C:\temp\202602\PBIP\Sales.Report\definition") 
    ,
    $rulesFilePath = $null
)
  
$currentFolder = (Split-Path $MyInvocation.MyCommand.Definition -Parent)

# Download tabular editor

$toolsPath = "$currentFolder\_tools"

$tools = @(
    @{"tool" = "PBIInspector"; "downloadUrl" = "https://github.com/NatVanG/PBI-InspectorV2/releases/latest/download/win-x64-CLI.zip"; "rulesUrl" = "https://raw.githubusercontent.com/NatVanG/PBI-InspectorV2/refs/heads/main/Rules/Base-rules.json" }    
)

foreach ($tool in $tools) {

    $toolName = $tool.tool
    $downloadUrl = $tool.downloadUrl
    $rulesUrl = $tool.rulesUrl

    $destinationPath = "$toolsPath\$toolName"

    if (!(Test-Path $destinationPath)) {

        New-Item -ItemType Directory -Path $destinationPath -ErrorAction SilentlyContinue | Out-Null            

        Write-Host "Downloading $toolName"

        $zipFile = "$destinationPath\$toolName.zip"

        Invoke-WebRequest -Uri $downloadUrl -OutFile $zipFile

        Expand-Archive -Path $zipFile -DestinationPath $destinationPath -Force     

        Remove-Item $zipFile        

        # Downloading default rules

        Invoke-WebRequest -Uri $rulesUrl -OutFile "$destinationPath\defaultRules.json"
    }    
}

$pbiInspectorEXE = "$toolsPath\PBIInspector\win-x64\CLI\PBIRInspectorCLI.exe"

if ($rulesFilePath -eq $null) {
    $rulesFilePath = "$currentFolder\bpa-rules-report.json"
}

if (!(Test-Path $rulesFilePath)) {
    throw "Cannot find PBI Inspector rules file at path: '$rulesFilePath'. Please provide a valid path to the BPA rules file"    
}

foreach ($report in $reports) {

    Write-Host "Running PBI Inspector BPA rules for: '$model'"

    $process = Start-Process -FilePath $pbiInspectorEXE -ArgumentList "-pbipreport ""$report"" -rules ""$rulesFilePath"" -formats ""GitHub""" -NoNewWindow -Wait -PassThru    

    if ($process.ExitCode -ne 0) {
    
        Write-Host "Detected critical errors for report '$report'"
    }           

}
