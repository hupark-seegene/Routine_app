# Claude Code Project Development Instructions

## Primary Objective
Develop and deploy a complete Android application using PowerShell-only workflow, with continuous testing cycles until achieving a stable, fully-functional build. **Complete all baseline features first, then enhance with additional advanced functionality.**

## Reference Documents (Use as Guidelines)
- `project_plan.md` - Main project roadmap and specifications
- `claude.md` - Development guidelines and standards
- `FILE_INVENTORY_ANALYSIS.md` - File structure analysis
- `FILE_MANAGEMENT_SYSTEM.md` - File organization protocols

## Core Requirements

### 1. Build Management
- **Version Control**: Increment build number (ddd+1) for each new build
- **Installation Process**: Generate fresh installation for every build iteration
- **PowerShell Scripts**: Create NEW PowerShell scripts for each cycle (do not reuse previous .ps1 files)

### 2. Development Environment
- **Platform**: Android development exclusively through PowerShell CLI
- **No Android Studio**: Use command-line tools only (gradle, adb, etc.)
- **Complete Automation**: All processes must be scriptable and repeatable

### 3. Continuous Development & Refinement Process
**Two-Phase Iterative Enhancement Approach (Additional 200 cycles from current version)**

**Starting Point**: Continue from current completed ddd(number) version
**Target**: Complete additional 200 enhancement cycles

**Phase A: Core Feature Implementation (Priority 1)**
- Implement ALL baseline features specified in reference documents
- Ensure each core feature works correctly and reliably
- Focus on meeting original project requirements first

**Phase B: Advanced Feature Enhancement (Priority 2)**
- Add advanced functionality beyond baseline requirements
- Implement quality-of-life improvements and user experience enhancements
- Add innovative features that make the app stand out
- Optimize performance and add professional polish

**Continuous Improvement Cycle with Git Integration (TODO List Format):**

**CYCLE CHECKLIST - Execute sequentially for each iteration:**

```
[ ] 1. VERSION CHECK
    - Identify current ddd(number) 
    - Increment to next version (ddd+1)
    - Update version in build files

[ ] 2. BUILD APK
    - Clean previous build artifacts
    - Execute PowerShell/Gradle build commands
    - Verify APK generation successful
    - Check APK file size and integrity

[ ] 3. EMULATOR SETUP
    - Start Android emulator if not running
    - Verify emulator is ready and responsive
    - Clear previous app data if exists

[ ] 4. INSTALL APK TO EMULATOR
    - Use ADB to install APK: `adb install app-debug.apk`
    - Verify installation success
    - Check app appears in emulator app list

[ ] 5. EXECUTE APP
    - Launch app on emulator
    - Wait for app to fully load
    - Navigate through main features
    - Test implemented functionality

[ ] 6. CAPTURE SCREENSHOT
    - Execute: `adb shell screencap -p /sdcard/screenshot_buildXXX.png`
    - Pull screenshot: `adb pull /sdcard/screenshot_buildXXX.png`
    - Rename with build number and timestamp
    - Verify screenshot saved correctly

[ ] 7. DEBUG & EVALUATE
    - Document current functionality status
    - Identify bugs, issues, or improvements needed
    - Assess Phase A (core) vs Phase B (advanced) priorities
    - Plan next enhancement target

[ ] 8. UNINSTALL APK FROM EMULATOR
    - Use ADB: `adb uninstall [package.name]`
    - Verify complete removal
    - Clean emulator state

[ ] 9. ENHANCE & MODIFY CODE
    - Implement planned improvements/fixes
    - Add new features based on evaluation
    - Update code comments and documentation
    - Create new PowerShell scripts (no reuse)

[ ] 10. GIT WORKFLOW
    - Stage changes: `git add .`
    - Commit: `git commit -m "Build ddd(number): [specific changes]"`
    - Push: `git push origin main`
    - Verify commit appears on GitHub

[ ] 11. DOCUMENTATION UPDATE
    - Update project_plan.md with cycle results
    - Document new features added
    - Note any issues encountered
    - Update feature completion status

[ ] 12. CYCLE COMPLETION
    - Mark current cycle as complete
    - Prepare for next cycle
    - Update cycle counter (X/200)
    - Brief reflection on progress
```

**CYCLE EXECUTION RULES:**
- Complete ALL 12 steps before moving to next cycle
- Do NOT skip steps even if they seem unnecessary
- If any step fails, fix the issue before proceeding
- Document every decision and change made
- Maintain consistent naming conventions throughout

**Enhancement Requirements:**
- **Version Management**: Increment from current ddd version (ddd+1, ddd+2, etc.)
- **Install/Uninstall**: APK installation and removal on Android emulator via ADB
- **Screenshot Capture**: Take screenshot of first app screen using ADB screencap command
- **Screenshot Management**: Save screenshots with build version/cycle number for comparison
- **Git Integration**: Use GitHub CLI for every cycle:
  - `gh repo clone` or work with existing repository
  - `git add .` to stage all changes
  - `git commit -m "Build ddd(number): [description of changes]"`
  - `git push origin main` to upload changes
- **Core Features First**: Prioritize completing all baseline functionality
- **Advanced Features Second**: Add sophisticated enhancements after core completion
- **Efficient AI Integration**: Implement targeted OpenAI API features with minimal usage but maximum user value
- **API Optimization**: Focus on user-centric AI features (memo analysis, personalized recommendations, feedback processing)
- **Continuous Quality**: Improve UI/UX, performance, and stability throughout
- Document improvements and issues in `project_plan.md`
- **Goal**: Achieve baseline completion + practical AI-enhanced features within additional 200 cycles

### 4. Success Criteria
- **Complete, polished Android application** achieved through continuous refinement
- Successfully builds, installs, and runs flawlessly on Android emulator
- All planned features implemented, tested, and optimized
- **High-quality user experience**: Smooth performance, intuitive UI, stable functionality
- APK installs/uninstalls cleanly on emulator without any issues
- Full automation through PowerShell scripts
- **Comprehensive documentation**: All improvements and final state documented in `project_plan.md`
- **Production-ready quality**: App ready for real-world deployment

## Task Execution Steps

1. **Initialize**: Analyze reference documents and establish project structure
2. **Setup**: Configure Android development environment via PowerShell
3. **Git Setup**: Initialize or connect to existing GitHub repository using GitHub CLI
4. **Version Assessment**: Identify current completed ddd(number) version as starting point
5. **Extended Two-Phase Enhancement Cycle** (additional 200 iterations from current version):

   **Phase A: Core Implementation**
   - Focus on implementing ALL baseline features from reference documents
   - Ensure core functionality works correctly before moving to enhancements
   
   **Phase B: Advanced Enhancement**
   - Add sophisticated features beyond original requirements
   - Implement premium functionality and optimizations
   - **Integrate practical OpenAI API capabilities** for user-focused intelligent features
   - Focus on efficient AI usage that provides maximum user value with minimal API calls
   
   **Each Cycle Must Follow Complete TODO Checklist:**
   - **12-Step Process**: Complete all checklist items sequentially
   - **No Step Skipping**: Every step must be completed before moving to next
   - **Progress Tracking**: Maintain cycle counter (X/200) 
   - **Failure Handling**: If any step fails, fix issue before proceeding
   - **Documentation**: Record results of each cycle step

6. **Document**: Update `project_plan.md` with feature completion status, enhancement details, and git commit references
7. **Visual & Version Tracking**: Maintain screenshot archive and git history showing progression from current version
8. **Feature Tracking**: Clearly mark when core features are complete and advanced features begin
9. **Achieve Excellence**: Complete all baseline features + advanced enhancements within additional 200 cycles

**Philosophy**: Follow the 12-step TODO checklist religiously for each cycle. Continue from existing progress, fulfill all original requirements completely, then exceed expectations with innovative additional features and professional polish, all while maintaining comprehensive version control and systematic documentation.

## Output Requirements
- Functional Android APK
- Complete PowerShell automation scripts
- Updated project documentation
- Detailed test cycle reports
- Final deployment-ready application

**Note**: Think systematically and thoroughly about each step. Focus on creating robust, repeatable processes that can handle multiple iteration cycles without manual intervention.