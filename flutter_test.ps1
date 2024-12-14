# Stop on any error
# $ErrorActionPreference = "Stop"

# Navigate to the project directory
Set-Location -Path "D:\Ain Shams University\Senior-2\Mobile Programming\Project\Github\Hedieaty\hedieaty"

# Install dependencies
flutter pub get

# Start screen recording in the background
Start-Process -NoNewWindow -FilePath adb -ArgumentList "shell screenrecord /sdcard/integration_test.mp4"

# Run all integration tests in the integration_test folder
try {
    flutter test integration_test > integration_test_output.log
} catch {
}

# Stop screen recording after tests complete
try {
    adb shell killall -2 screenrecord
    Write-Output "Screen recording stopped."
} catch {
}

# Wait for 10 seconds before pulling the MP4 file 
Start-Sleep -Seconds 10

# Pull the screen recording from the device/emulator
try {
    adb pull /sdcard/integration_test.mp4 ./integration_test.mp4
    Write-Output "Screen recording pulled successfully."
} catch {
}

# Run all normal tests in the test folder
try {
    flutter test > test_output.log
} catch {
}

# Push the logs to the device/emulator
try {
    adb push integration_test_output.log /sdcard/integration_test_output.log
    adb push test_output.log /sdcard/test_output.log
    Write-Output "Logs pushed to device successfully."
} catch {
}

# Pull the logs from the device/emulator
try {
    adb pull /sdcard/integration_test_output.log ./integration_test_output_on_device.log
    adb pull /sdcard/test_output.log ./test_output_on_device.log
    Write-Output "Logs pulled from device successfully."
} catch {
}

# Display a message
Write-Output "Tests completed, logs and screen recording are stored."

# Wait for user input to close
pause
