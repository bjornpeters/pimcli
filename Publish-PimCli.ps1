$moduleManifest = Get-ChildItem -Path . -Filter '*.psd1' | Select-Object -First 1
Publish-Module -Path \$moduleManifest.Directory.FullName -NuGetApiKey \$env:NUGET_API_KEY -Verbose