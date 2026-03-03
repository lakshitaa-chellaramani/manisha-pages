param(
    [string]$PublicRepo = 'https://github.com/lakshitaa-chellaramani/manisha-pages.git',
    [string]$TempDir = $(Join-Path -Path ([System.IO.Path]::GetTempPath()) -ChildPath ("manisha_deploy_" + [System.Guid]::NewGuid().ToString()))
)

Write-Host "Cloning public repo into $TempDir"

# ensure the directory doesn't already exist
if (Test-Path $TempDir) { Remove-Item -Recurse -Force $TempDir }

git clone $PublicRepo $TempDir
if ($LASTEXITCODE -ne 0) {
    Write-Error "Failed to clone $PublicRepo.  Does the repository exist and is the URL correct?"
    exit 1
}

Write-Host "Clone succeeded; remote configuration:"
Push-Location $TempDir
git remote -v
Pop-Location

# determine source directory (where script was invoked from)
$SourceDir = (Get-Location).Path

Write-Host "Preparing destination (keeping existing .git)..."
Get-ChildItem -Path $TempDir -Force | Where-Object { $_.Name -ne '.git' } | ForEach-Object { Remove-Item -Recurse -Force $_.FullName }

Write-Host "Synchronizing files from $SourceDir to $TempDir (excluding .git and temp-test)..."
# use robocopy for reliable mirroring and exclusion
robocopy $SourceDir $TempDir /MIR /XD ".git" "temp-test"

# now work inside destination repo
Set-Location $TempDir

git add --all
try {
    git commit -m "Publish site $(Get-Date -Format g)" | Out-Null
} catch {
    Write-Host "Nothing to commit"
}

git push origin main
Write-Host "Deployment complete."