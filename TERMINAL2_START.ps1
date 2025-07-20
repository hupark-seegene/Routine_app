# Terminal 2: Database & Data Management
# 데이터베이스 최적화 및 데이터 관리 작업 시작 스크립트

Write-Host "===== Terminal 2: Database Optimization =====" -ForegroundColor Cyan
Write-Host "Focus: Database indexing, Backup/Restore, Data analytics" -ForegroundColor Yellow

# 작업 디렉토리 설정
$WorkDir = "SquashTrainingApp/android/app/src/main/java/com/squashtrainingapp"
Set-Location $WorkDir

Write-Host "`n[Tasks for Terminal 2]" -ForegroundColor Green
Write-Host "1. Add database indexes for performance"
Write-Host "2. Implement backup/restore functionality"
Write-Host "3. Create data export feature"
Write-Host "4. Build statistics calculator"
Write-Host "5. Optimize database queries"

Write-Host "`n[First Task]: Edit DatabaseHelper.java" -ForegroundColor Yellow
Write-Host "Add indexes to:"
Write-Host "- exercises table (category, date)"
Write-Host "- records table (userId, date)"
Write-Host "- sessions table (programId, date)"

Write-Host "`n[Commands to run]:" -ForegroundColor Cyan
Write-Host "cd database"
Write-Host "code DatabaseHelper.java"
Write-Host ""
Write-Host "Create new classes:"
Write-Host "code BackupManager.java"
Write-Host "code DataAnalyzer.java"

Write-Host "`n[Progress tracking]:" -ForegroundColor Magenta
Write-Host "Update TERMINAL2_PROGRESS.md after each task completion"
Write-Host "Commit frequently with: git commit -m 'feat(terminal-2): description'"

# 진행 상황 파일 생성
@"
# Terminal 2 Progress

## 작업 영역: Database & Data Management

### 진행 상황
- [ ] 데이터베이스 인덱스 추가
- [ ] 백업/복원 기능 구현
- [ ] 데이터 내보내기 기능
- [ ] 통계 계산기 구현
- [ ] 쿼리 최적화

### 완료된 작업
(작업 완료 시 여기에 기록)

### 이슈 및 해결
(문제 발생 시 여기에 기록)
"@ | Out-File -FilePath "../../../../../../../TERMINAL2_PROGRESS.md" -Encoding UTF8

Write-Host "`nTerminal 2 ready to start!" -ForegroundColor Green