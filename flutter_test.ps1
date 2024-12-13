# Stop on any error
$ErrorActionPreference = "Stop"

# Navigate to the project directory
Set-Location -Path "D:\Ain Shams University\Senior-2\Mobile Programming\Project\Github\Hedieaty\hedieaty"

# Install dependencies
flutter pub get

# Run Flutter tests
flutter test > test_output.log

# Push the log to the device/emulator
try {
    adb push test_output.log /sdcard/test_output.log
    Write-Output "Log pushed to device successfully."
} catch {
}

# Pull the log from the device/emulator
try {
    adb pull /sdcard/test_output.log ./test_output_on_device.log
    Write-Output "Log pulled from device successfully."
} catch {
}

# Display a message
Write-Output "Tests completed and logs are stored in test_output.log and test_output_on_device.log"

# Wait for user input to close
pause
