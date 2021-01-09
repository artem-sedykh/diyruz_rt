param ($name)

if ([string]::IsNullOrWhiteSpace($name)) {
    Write-Error "Project name not set, use -name ProjectName"
    return
}
$templateProject = "GenericApp"
$templateProjectPath = Join-Path -Path "." -ChildPath $templateProject

function UpdateContent($params) { 
    $project = $params[1]
    $content = $params[0]
    return $content.Replace('GenericApp', $project).Replace('genericapp', $project.ToLowerInvariant()).Replace('GENERICAPP', $project.ToUpperInvariant())
}

if(!(Test-Path -Path $templateProjectPath)){
    Write-Error "template project(${templateProjectPath}) not found"
    return
}

if((Test-Path -Path (Join-Path -Path "." -ChildPath $name))){
    Write-Error "Project ${name} already exists"
    return
}

Get-ChildItem $templateProjectPath -Filter "*" -Recurse | ForEach-Object {
    if(![string]::IsNullOrEmpty($_.DirectoryName)) {
        $path = ($_.DirectoryName + "\") -Replace [Regex]::Escape($templateProject), $name
        $newFileName = UpdateContent($_.Name, $name)
        $newPath = Join-Path -Path $Path -ChildPath $newFileName
        Copy-Item $_.FullName $newPath -Force

        UpdateContent((Get-Content $newPath), $name)| Set-Content $newPath
    } else{
        $path = $_.FullName -Replace [Regex]::Escape($templateProject), $name
        
        If(!(Test-Path $path)) { 
            New-Item -ItemType Directory -Path $path -Force | Out-Null
        }
    }
}