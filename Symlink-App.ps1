# Copyright 2020 Rennie Glen Software LLC

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at

# Traverses an app bundle, looking for executables and dynamic libraries in the
# Contents/Resources directory.  Then, it moves the binaries to the Contents/MacOS
# and Contents/Frameworks directories, and leaves symlinks in their original locations.
param($AppPath)

$resourcesPath = Join-Path $AppPath 'Contents' 'Resources'
$macosPath = Join-Path $AppPath 'Contents' 'MacOS'
$frameworksPath = Join-Path $AppPath 'Contents' 'Frameworks'

mkdir -p $frameworksPath
mkdir -p $macosPath

# Returns true if the file's executable bit is set.
function Test-UnixExecutable($Path) {
    $permissions = [string] (stat -f "%Sp" "$Path")
    return $permissions.Contains("x")
}

function MakePath-Relative($Path, $BaseDir) {
    $homePath = Get-Location
    try {
        Set-Location $BaseDir
        return Resolve-Path $Path -Relative
    } finally {
        Set-Location $homePath
    }
}

# Moves a file to destination directory, leaving a symlink to the destination directory
# in its old location.
function Move-File($SourcePath, $DestDir) {
    $fileDir = Split-Path -Parent $sourcePath
    $fileName = Split-Path -Leaf $sourcePath
    $relPath = Join-Path (MakePath-Relative $DestDir $fileDir) $fileName
    Write-Host "Moving $filePath to $relPath"
    mv $sourcePath (Join-Path $DestDir $fileName)
    ln -s $relPath $sourcePath
}

foreach ($filePath in (Get-ChildItem -Recurse $resourcesPath)) {    
    if (Test-Path -Path $filePath -PathType Container) {
        continue  # Ignore directories.
    }
    $file = Get-Item $filePath
    if ($file.LinkType) {
        # Ignore symbolic links.
    } elseif ($filePath -like "*.dylib") {
        Move-File $filePath $frameworksPath
    } elseif (Test-UnixExecutable $filePath) {
        Move-File $filePath $macosPath
    }
}