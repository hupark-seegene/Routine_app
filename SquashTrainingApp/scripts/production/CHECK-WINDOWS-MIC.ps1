# CHECK-WINDOWS-MIC.ps1
# Script to check and configure Windows microphone settings

Write-Host "======================================" -ForegroundColor Cyan
Write-Host "Windows Microphone Configuration Check" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan

# Check if running as Administrator
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
if (-not $isAdmin) {
    Write-Host "`nNote: Some checks require Administrator privileges" -ForegroundColor Yellow
}

# Function to check microphone privacy settings
function Check-MicrophonePrivacy {
    Write-Host "`n1. Checking Windows Microphone Privacy..." -ForegroundColor Yellow
    
    try {
        # Check if microphone access is allowed
        $micAccess = Get-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\microphone" -Name "Value" -ErrorAction SilentlyContinue
        
        if ($micAccess.Value -eq "Allow") {
            Write-Host "✓ Microphone access is ALLOWED" -ForegroundColor Green
        } else {
            Write-Host "✗ Microphone access is DENIED" -ForegroundColor Red
            Write-Host "  To fix: Settings > Privacy & Security > Microphone > Enable" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "Could not check microphone privacy settings" -ForegroundColor Yellow
    }
}

# Function to list audio input devices
function Check-AudioDevices {
    Write-Host "`n2. Checking Audio Input Devices..." -ForegroundColor Yellow
    
    try {
        Add-Type -TypeDefinition @"
        using System;
        using System.Runtime.InteropServices;
        using System.Collections.Generic;
        
        public class AudioDevice {
            [DllImport("winmm.dll", SetLastError = true)]
            public static extern uint waveInGetNumDevs();
            
            [DllImport("winmm.dll", SetLastError = true, CharSet = CharSet.Auto)]
            public static extern uint waveInGetDevCaps(uint uDeviceID, ref WAVEINCAPS pwic, uint cbwic);
            
            [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Auto)]
            public struct WAVEINCAPS {
                public ushort wMid;
                public ushort wPid;
                public uint vDriverVersion;
                [MarshalAs(UnmanagedType.ByValTStr, SizeConst = 32)]
                public string szPname;
                public uint dwFormats;
                public ushort wChannels;
                public ushort wReserved1;
            }
            
            public static List<string> GetInputDevices() {
                var devices = new List<string>();
                uint numDevs = waveInGetNumDevs();
                
                for (uint i = 0; i < numDevs; i++) {
                    WAVEINCAPS caps = new WAVEINCAPS();
                    if (waveInGetDevCaps(i, ref caps, (uint)Marshal.SizeOf(caps)) == 0) {
                        devices.Add(caps.szPname);
                    }
                }
                return devices;
            }
        }
"@
        
        $devices = [AudioDevice]::GetInputDevices()
        if ($devices.Count -gt 0) {
            Write-Host "Found $($devices.Count) audio input device(s):" -ForegroundColor Green
            $devices | ForEach-Object { Write-Host "  - $_" -ForegroundColor White }
        } else {
            Write-Host "No audio input devices found!" -ForegroundColor Red
        }
    } catch {
        Write-Host "Could not enumerate audio devices" -ForegroundColor Yellow
    }
}

# Function to check default recording device
function Check-DefaultMicrophone {
    Write-Host "`n3. Checking Default Recording Device..." -ForegroundColor Yellow
    
    try {
        # Use PowerShell audio cmdlets if available
        $audioDevices = Get-PnpDevice -Class AudioEndpoint -Status OK | Where-Object { $_.FriendlyName -like "*Microphone*" }
        
        if ($audioDevices) {
            Write-Host "Active microphone devices:" -ForegroundColor Green
            $audioDevices | ForEach-Object { 
                Write-Host "  - $($_.FriendlyName)" -ForegroundColor White 
            }
        } else {
            Write-Host "No active microphone devices found" -ForegroundColor Red
        }
    } catch {
        Write-Host "Could not check default microphone" -ForegroundColor Yellow
    }
}

# Function to open sound settings
function Open-SoundSettings {
    Write-Host "`n4. Opening Windows Sound Settings..." -ForegroundColor Yellow
    Start-Process "ms-settings:sound"
    Write-Host "Sound settings opened. Please check:" -ForegroundColor Green
    Write-Host "  - Default input device is selected" -ForegroundColor White
    Write-Host "  - Input volume is not muted" -ForegroundColor White
    Write-Host "  - Test your microphone" -ForegroundColor White
}

# Function to check app permissions
function Check-AppPermissions {
    Write-Host "`n5. Checking App Microphone Permissions..." -ForegroundColor Yellow
    
    Write-Host "Opening microphone app permissions..." -ForegroundColor Cyan
    Start-Process "ms-settings:privacy-microphone"
    
    Write-Host "`nPlease ensure:" -ForegroundColor Green
    Write-Host "  - 'Let apps access your microphone' is ON" -ForegroundColor White
    Write-Host "  - 'Let desktop apps access your microphone' is ON" -ForegroundColor White
    Write-Host "  - Android Studio/Emulator has permission" -ForegroundColor White
}

# Main execution
Write-Host "`nPerforming Windows microphone checks..." -ForegroundColor Cyan

Check-MicrophonePrivacy
Check-AudioDevices
Check-DefaultMicrophone

Write-Host "`n======================================" -ForegroundColor Green
Write-Host "Quick Fix Actions:" -ForegroundColor Green
Write-Host "======================================" -ForegroundColor Green

Write-Host "`n1. Test microphone in Windows:" -ForegroundColor Yellow
Write-Host "   Press Win+H to test Windows speech recognition" -ForegroundColor White

Write-Host "`n2. Configure microphone settings:" -ForegroundColor Yellow
$response = Read-Host "Open Windows Sound Settings? (y/n)"
if ($response -eq 'y') {
    Open-SoundSettings
}

Write-Host "`n3. Check app permissions:" -ForegroundColor Yellow
$response = Read-Host "Open Microphone Privacy Settings? (y/n)"
if ($response -eq 'y') {
    Check-AppPermissions
}

Write-Host "`n4. For Android Emulator:" -ForegroundColor Yellow
Write-Host "   - Use x86/x86_64 images (better audio support)" -ForegroundColor White
Write-Host "   - Try Google APIs image (not Google Play)" -ForegroundColor White
Write-Host "   - Cold boot emulator if audio issues persist" -ForegroundColor White

Write-Host "`nPress any key to exit..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")