# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## System Rules and Guidelines

This repository contains a React Native project. Always follow these guidelines when working with the codebase:

- project_plan.md와 claude.md, FILE_INVENTORY_ANALYSIS.md, FILE_MANAGEMENT_SYSTEM.md를 지침으로 하여 project를 진행해줘
- 새로운 build를 할 때마다 ddd를 업데이트 해서 설치를 진행해줘
- 이전에 만든 ps1를 사용하지말고 새로운 ps1를 생성해서 진행해줘
- 현재 완성된 app을 생성하여 구동하는게 목표이며, emulator에 (설치 -실행 -모든기능 디버그- 앱삭제- 수정) 이 사이클을 fail/issue가 없을 때까지 계속 반복(x50회 이상)해서 수행해줘

## Project Management Rules

Always manage the project_plan.md file:
- Review the project plan before executing any user commands
- Update the project plan after completing significant tasks
- The project_plan.md contains the complete development history and current status

## File Management System (2025-07-12)

### File Creation Guard
**ALWAYS use the file creation guard before creating new PowerShell scripts or documentation:**

```powershell
# Check before creating new scripts
cd SquashTrainingApp/scripts/utility
.\UTIL-FILE-GUARD.ps1 -FileName "NEW-SCRIPT.ps1" -FileType "script" -Category "BUILD" -Description "Brief description"
```

### Script Categories (Use for -Category parameter)
- **BUILD**: Android/APK build automation
- **RUN**: App execution and deployment  
- **SETUP**: Environment configuration
- **FIX**: Problem resolution
- **DEPLOY**: APK installation and distribution
- **UTIL**: Utility and helper functions

### Document Categories
- **GUIDE**: Step-by-step instructions
- **REFERENCE**: Technical documentation and status

### Naming Conventions
- PowerShell scripts: `CATEGORY-PURPOSE.ps1` (e.g., `BUILD-APK.ps1`)
- Documentation: `PURPOSE_TYPE.md` (e.g., `BUILD_GUIDE.md`)
- Avoid version suffixes: Use directories instead of `-v2`, `-v3`

### Directory Structure
```
SquashTrainingApp/
├── scripts/
│   ├── production/     # Core working scripts (6 files)
│   └── utility/        # Helper tools (2 files)
├── docs/
│   ├── guides/         # User documentation (4 files)
│   └── reference/      # Technical docs (2 files)
└── archive/
    ├── scripts/experimental/  # Historical/learning files
    └── docs/historical/        # Legacy documentation
```

### File Creation Rules
1. **Check existing files first**: Use file guard to prevent duplicates
2. **Follow naming conventions**: Match established patterns
3. **Use appropriate directories**: Place files in correct categories
4. **Log creation**: All file creation is logged automatically
5. **Avoid experimental scripts in production**: Use archive/scripts/experimental/

### Example Usage
```powershell
# ✅ Correct: Check before creating
.\UTIL-FILE-GUARD.ps1 -FileName "SETUP-EMULATOR.ps1" -FileType "script" -Category "SETUP"

# ❌ Wrong: Direct creation without check
New-Item "random-script.ps1"
```

## Git Workflow - IMPORTANT

**ALWAYS commit and push changes after completing any task or set of changes.**

### 1. Quick Git Commands
```bash
# Check status
git status

# Add all changes
git add .

# Commit with descriptive message
git commit -m "your commit message"

# Push to GitHub
git push origin main
```

### 2. Automated Git Workflow (RECOMMENDED)
After any significant task completion, automatically run:

```bash
# One-liner for quick commits
git add . && git commit -m "task: brief description of changes" && git push origin main
```

### 3. Commit Message Format
Use conventional commit format:
- `feat: add new feature`
- `fix: resolve bug in component`
- `docs: update documentation`
- `refactor: restructure code without functionality change`
- `style: formatting and style changes`
- `test: add or update tests`
- `build: changes to build configuration`

### 4. When to Commit & Push
**ALWAYS commit after:**
- Completing any user-requested task
- Adding new features or components
- Fixing bugs or issues
- Updating documentation
- Refactoring code
- Build configuration changes
- Any file modifications

### 5. GitHub CLI Integration
If GitHub CLI is available, can also use:
```bash
# Check authentication
gh auth status

# Quick push with PR creation
gh repo sync
```

**Remember: Version control is critical - commit early, commit often!**

## Code Management Guidelines

- Keep files under 400 lines - split into modules if exceeded
- Use TypeScript strict mode
- Follow existing project design patterns
- Test thoroughly before deployment
- Maintain consistent coding standards
- Always use proper error handling
- Document complex logic and algorithms
- Follow the existing file structure and organization
- Ensure cross-platform compatibility where applicable