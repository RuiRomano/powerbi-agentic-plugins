param (    
    <#
    .PARAMETER models
    Specifies the path to the TMDL (Tabular Model Definition Language) definition of a semantic model or a server database.    
    #>
    $models = @("localhost:50106 5d60b0e7-5a0f-45ba-8be2-1d38f59032a8", "C:\temp\202602\NewModel_CLI\HttpSource\SalesAnalysis\SalesAnalysis.SemanticModel") 
    ,
    $rulesFilePath = $null
)
  
$currentFolder = (Split-Path $MyInvocation.MyCommand.Definition -Parent)

# Download tabular editor

$toolsPath = "$currentFolder\_tools"

$tools = @(
    @{"tool" = "TabularEditor"; "downloadUrl" = "https://github.com/TabularEditor/TabularEditor/releases/latest/download/TabularEditor.Portable.zip"; "rulesUrl" = "https://raw.githubusercontent.com/microsoft/Analysis-Services/master/BestPracticeRules/BPARules.json" }    
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

$tabularEditorEXE = "$toolsPath\TabularEditor\TabularEditor.exe"

if ($rulesFilePath -eq $null) {
    $rulesFilePath = "$currentFolder\bpa-rules-semanticmodel.json"
}

if (!(Test-Path $rulesFilePath)) {
    throw "Cannot find BPA rules file at path: '$rulesFilePath'. Please provide a valid path to the BPA rules file"    
}

foreach ($model in $models) {

    Write-Host "Running Tabular Editor BPA rules for: '$model'"

    $process = Start-Process -FilePath $tabularEditorEXE -ArgumentList "$model -A ""$rulesFilePath"" -G" -NoNewWindow -Wait -PassThru    

    if ($process.ExitCode -ne 0) {
        #throw "Detected critical errors for model: '$model'"

        Write-Host "Detected critical errors for model '$model'"
    }           

}
