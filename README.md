# Pure Storage PowerShell SDK 1.5 Release Notes

The Pure Storage PowerShell SDK provides integration with the Purity Operating Environment and FlashArray. It provides functionalities of Purity's REST API as PowerShell cmdlets.

### Downloads
* [Installation Package](../blob/master/PurePowerShellSDKInstaller.msi)
* [Quick Start Guide for Pure Storage PowerShell SDK (PDF)](../blob/master/Quick%20Start%20Guide%20for%20Pure%20Storage%20PowerShell%20SDK.pdf)
* [Quick Start Guide PowerShell SDK Examples (ZIP)](../blob/master/SDK-Examples.zip)

### RELEASE COMPATIBILITY

* This release requires PowerShell 3.0 or higher.
* This release requires .NET 4.5.
* This release is compatible with Purity FlashArrays that support Pure Storage REST API 1.0, 1.1, 1.2, 1.3, or 1.4.
* This release requires a 64-bit operating system.
* This release requires an operating system that supports the TLS 1.1/1.2 protocols such as Windows 7 & up or Windows Server 2008 R2 or higher.

### INSTALLATION AND UNINSTALLATION

To install the PowerShell SDK, extract and run PurePowerShellSDKInstaller.msi, and follow the instructions. Administrator privilege is required to install. To verify the installation, run "Get-Command -Module PureStoragePowerShellSDK" in a new PowerShell prompt. The newly installed cmdlets should be listed. The PowerShell SDK can be uninstalled from "Programs and Features" of the Control Panel.

### KNOWN ISSUES

* `Get-PfaProtectionGroupVolumeSnapshots` does not work if the array is connected using REST API 1.4.
* `Get-PfaVolumeSpaceMetrics` does not return the "size" property of a volume if the array is connected using REST API 1.0 or 1.1.

### PERFORMANCE TESTING

No performance testing was done for this release.

### OPEN SOURCE LICENSES

Json.NET:
> The MIT License (MIT)
Copyright (c) 2007 James Newton-King
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
