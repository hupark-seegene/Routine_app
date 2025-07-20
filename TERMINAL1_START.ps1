# Terminal 1: Performance Optimization & Memory Management
# 성능 최적화 및 메모리 관리 작업 시작 스크립트

Write-Host "===== Terminal 1: Performance Optimization =====" -ForegroundColor Cyan
Write-Host "Focus: Memory optimization, Animation improvement, Rendering performance" -ForegroundColor Yellow

# 작업 디렉토리 설정
$WorkDir = "SquashTrainingApp/android/app/src/main/java/com/squashtrainingapp"
Set-Location $WorkDir

Write-Host "`n[Tasks for Terminal 1]" -ForegroundColor Green
Write-Host "1. Optimize MascotView rendering performance"
Write-Host "2. Implement bitmap caching for mascot"
Write-Host "3. Add hardware acceleration"
Write-Host "4. Achieve 60fps animations"
Write-Host "5. Reduce memory footprint"

Write-Host "`n[First Task]: Edit MascotView.java" -ForegroundColor Yellow
Write-Host "Add the following optimizations:"
Write-Host "- Bitmap caching"
Write-Host "- Hardware layer type"
Write-Host "- Efficient onDraw method"

Write-Host "`n[Commands to run]:" -ForegroundColor Cyan
Write-Host "cd mascot"
Write-Host "code MascotView.java"
Write-Host ""
Write-Host "After editing, test with:"
Write-Host "cd /mnt/c/Git/Routine_app/SquashTrainingApp"
Write-Host "./gradlew assembleDebug"

Write-Host "`n[Progress tracking]:" -ForegroundColor Magenta
Write-Host "Update TERMINAL1_PROGRESS.md after each task completion"
Write-Host "Commit frequently with: git commit -m 'perf(terminal-1): description'"

# 진행 상황 파일 생성
@"
# Terminal 1 Progress

## 작업 영역: Performance Optimization & Memory Management

### 진행 상황
- [ ] MascotView 렌더링 최적화
- [ ] 비트맵 캐싱 구현
- [ ] 하드웨어 가속 활성화
- [ ] 60fps 애니메이션 달성
- [ ] 메모리 사용량 감소

### 완료된 작업
(작업 완료 시 여기에 기록)

### 이슈 및 해결
(문제 발생 시 여기에 기록)
"@ | Out-File -FilePath "../../../../../../../TERMINAL1_PROGRESS.md" -Encoding UTF8

Write-Host "`nTerminal 1 ready to start!" -ForegroundColor Green