# Build l'application
Write-Host "Building application..." -ForegroundColor Green
./gradlew.bat shadowJar

if ($?) {
    Write-Host "Deployment files created successfully!" -ForegroundColor Green
    Write-Host ""
    Write-Host "To deploy to Google App Engine:" -ForegroundColor Yellow
    Write-Host "1. Make sure you have gcloud CLI installed and authenticated"
    Write-Host "2. Run: gcloud app deploy"
    Write-Host "3. To view your app: gcloud app browse"
} else {
    Write-Host "Build failed!" -ForegroundColor Red
    exit 1
}
