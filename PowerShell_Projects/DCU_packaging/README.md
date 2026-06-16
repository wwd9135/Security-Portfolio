# Intune Firmware & Driver Patching Template

This repository provides a standardized template for deploying firmware, drivers, and software updates via Microsoft Intune as a Win32 application. It is designed to handle complex updates that require specific execution logic or manual file placement.

## How It Works

1.  **Staging:** Place all update binaries, installers, or `.cab` files in the `Files` folder.
2.  **Configuration:** Modify the `invoke-app.ps1` script to match your specific filenames and silent install switches.
3.  **Packaging:** Use the Microsoft Win32 Content Prep Tool to wrap the folder into an `.intunewin` package.
4.  **Deployment:** Upload to Intune and set the install command to trigger the `invoke-app.ps1` script.

## Repository Structure

* `Files/` - Directory for all source update files (MSIs, EXEs, Drivers).
* `Scripts/` - Contains `invoke-app.ps1`, the main execution entry point.
* `Build/` - Recommended output location for the compiled `.intunewin` file.

## Technical Requirements

* **Execution Policy:** The script must be run with `-ExecutionPolicy Bypass`.
* **Privileges:** Must be deployed in the **System** context for firmware/driver writes.
* **Compilation:** Designed to be used with the PowerShell App Deployment Toolkit (PSADT) or standalone `Invoke-AppDeployToolkit` commands to compile into a portable `.exe` if required for Company Portal self-service.

## Key Implementation Notes

* **Path Logic:** The template uses relative pathing to ensure the Intune Management Extension (IME) can locate files within the local cache (`C:\Windows\IMECache`).
* **Detection Rules:** When deploying, it is recommended to use **File** or **Registry** detection rules to verify the driver version or firmware revision post-installation.
* **Error Handling:** The `invoke-app.ps1` is structured to pass exit codes back to Intune to trigger appropriate "Reboot Pending" or "Success" states in the endpoint manager console.

## Usage Example

```powershell
# Example Install Command for Intune
powershell.exe -ExecutionPolicy Bypass -File ".\Scripts\invoke-app.ps1"
