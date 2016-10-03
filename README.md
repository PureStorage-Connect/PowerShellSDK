# Pure Storage PowerShell SDK Readme

The Pure Storage PowerShell SDK provides integration with the Purity Operating Environment and FlashArray. It provides functionalities of Purity's REST API as PowerShell cmdlets.

### DOWNLOADS
* [Installation Package](https://github.com/PureStorage-Connect/PowerShellSDK/blob/master/PurePowerShellSDKInstaller.msi)
* [Pure Storage PowerShell SDK](https://support.purestorage.com/Solutions/Programming_Interfaces/PowerShell)
* [Quick Start Guide PowerShell SDK Examples (ZIP)](https://github.com/PureStorage-Connect/PowerShellSDK/blob/master/SDK-Examples.zip)

### LATEST RELEASE
<<<<<<< HEAD
* [v1.6.6](https://github.com/PureStorage-Connect/PowerShellSDK/releases/tag/v1.6.6.0)

### OLDER RELEASES
* [v1.5.5](https://github.com/PureStorage-Connect/PowerShellSDK/releases/tag/v1.5.5.0)
* [v1.5.4](https://github.com/PureStorage-Connect/PowerShellSDK/releases/tag/v1.5.4.0)
=======
* Latest [v1.5.5](https://github.com/PureStorage-Connect/PowerShellSDK/releases/tag/v1.5.5.0)

### OLDER RELEASES
* [v1.5.4](https://github.com/PureStorage-Connect/PowerShellSDK/releases/tag/v1.5.4.0)

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
>>>>>>> master
