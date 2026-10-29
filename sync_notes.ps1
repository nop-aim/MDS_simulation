# Define the repo path (current folder)
$repoPath = "D:\OneDrive - RMIT University\HCMUTE_stu_robot_control"

# Function to sync the GitHub repository
function Sync-Repo {
    param ([string]$Path)

    if (Test-Path $Path) {
        Write-Host "------ Syncing: $Path ------" -ForegroundColor Cyan
        Set-Location $Path

        git pull
        git add -A
        $commitMessage = "note on $(Get-Date -Format 'yyyy-MM-dd HH:mm')"
        git commit -m "$commitMessage"
        git push

        Write-Host "Synced successfully" -ForegroundColor Green
    } else {
        Write-Host "Directory $Path does not exist" -ForegroundColor Red
    }
}

Sync-Repo -Path $repoPath
