<#PSScriptInfo
.VERSION 1.2.0
.GUID 3e63f459-74c5-4487-bccb-dc10363214f5
.AUTHOR asherto
.COMPANYNAME asheroto
.TAGS PowerShell, Windows, exe, set, run, remove, unset, administrator, add, compatibility, admin
.PROJECTURI https://github.com/asheroto/SetExeToRunAsAdmin
.RELEASENOTES
- [Version 0.0.1] Initial Release.
- [Version 0.0.2] Fixed example.
- [Version 0.0.3] Added option to unset the exe to run as Administrator and refactored function code.
- [Version 0.0.4] Fixed bug in version specification and improved examples.
- [Version 0.0.5] Added project link and improved tags.
- [Version 0.0.6] Fixed version specification.
- [Version 0.0.7] Final version specification fix.
- [Version 0.0.8] Improved description.
- [Version 1.0] Added RegJump option. Removed patch from version specification.
- [Version 1.1] Added support to detect if UnsetInstead doesn't exist. Optimized code.
- [Version 1.2.0] Improved parameter usage. Added checks for invalid commands. Improved examples. Optimized code. Added back patch in version specification.
#>

<#
.SYNOPSIS
Sets or unsets an EXE file or multiple EXE files to run as Administrator.

.DESCRIPTION
This script allows you to set or unset an EXE file or multiple EXE files to run as Administrator. The script modifies the compatibility settings of the EXE file(s) to ensure they run with elevated privileges.

.PARAMETER Path
Specifies the path to the folder containing the EXE file(s) to modify, or the path to a specific EXE file. This parameter is required unless the RegJump switch is used.

.PARAMETER RegJump
A switch to use RegJump to jump to the application's registry key.

.PARAMETER CurrentUser
A switch to set the EXE file(s) to run as Administrator for the current user.

.PARAMETER AllUsers
A switch to set the EXE file(s) to run as Administrator for all users. Requires administrator privileges.

.PARAMETER UnsetInstead
A switch to unset the EXE file(s) to run as Administrator. If not provided, the EXE file(s) will be set to run as Administrator.

.EXAMPLE
SetExeToRunAsAdmin -Path "C:\Program Files\Application\app.exe"

Sets the "app.exe" file to run as Administrator.

.EXAMPLE
SetExeToRunAsAdmin -Path "C:\Program Files\Application\app.exe" -AllUsers

Sets the "app.exe" file to run as Administrator for all users.

.EXAMPLE
SetExeToRunAsAdmin -Path "C:\Program Files\Application\app.exe" -UnsetInstead

Unsets the "app.exe" file to run as Administrator.

.EXAMPLE
SetExeToRunAsAdmin -Path "C:\Program Files\Application\" -AllUsers

Sets all EXE files in the "C:\Program Files\Application" folder to run as Administrator.

.EXAMPLE
SetExeToRunAsAdmin -RegJump

Jumps to the user's run as Administrator registry key.

.EXAMPLE
SetExeToRunAsAdmin -RegJump

Jumps to the run as Administrator registry key for all users.
#>

[CmdletBinding()]
param (
	[string]$Path,
	[Switch]$UnsetInstead,
	[Switch]$CurrentUser,
	[Switch]$AllUsers,
	[Switch]$RegJump
)

# Ensure that -RegJump is not used with -Path or -UnsetInstead
if ($RegJump -and ($Path -or $UnsetInstead)) {
	Write-Error "-RegJump cannot be used with -Path or -UnsetInstead simultaneously."
	return
}

# If Path is not specified and -RegJump is not used, explain that -Path is required
if (-not $Path -and -not $RegJump) {
	Write-Error "-Path is required unless -RegJump is used."
	return
}

# If -Path is used without -CurrentUser or -AllUsers, default to -CurrentUser
if ($Path -and -not ($CurrentUser -or $AllUsers)) {
	$CurrentUser = $true
}

function Get-CompatibilityKey {
	param([Switch]$AllUsers)
	if ($AllUsers) {
		return "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers"
	} else {
		return "HKCU:\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers"
	}
}

function AddRunAsAdministrator {
	param (
		[Parameter(Mandatory = $true)]
		[String]$ExePath,

		[Parameter(Mandatory = $false)]
		[Switch]$UnsetInstead
	)

	if ($UnsetInstead) {
		# If we want to unset the EXE from running as Administrator
		# Remove the item property, if it exists
		if ((Get-Item $CompatbilityKey).Property -Contains $ExePath) {
			Remove-ItemProperty $CompatbilityKey -Name $ExePath | Out-Null
			return $ExePath
		} else {
			Write-Warning "The registry key doesn't exist for:`n$ExePath`n"
			return $null
		}
	} else {
		# If we want to set the EXE to run as Administrator
		if ((Get-Item $CompatbilityKey).Property -Contains $ExePath) {
			# If the key's value does not contain RUNASADMIN, then append it, prefixed by space
			$Value = Get-ItemPropertyValue $CompatbilityKey -Name $ExePath
			if (!($Value.Contains("RUNASADMIN"))) {
				Set-ItemProperty $CompatbilityKey -Name $ExePath -Value ($Value + " RUNASADMIN") | Out-Null
			}
		} else {
			# Create a new key with the RUNASADMIN value (with tilde)
			New-ItemProperty $CompatbilityKey -Name $ExePath -Value "~ RUNASADMIN" | Out-Null
		}
		return $ExePath
	}
}

function Get-ExeFiles {
	param ([Parameter(Mandatory = $true)][string]$Path)

	if (Test-Path $Path -PathType Leaf) {
		# If $Path is a file, return the specified EXE file
		return Get-Item -Path $Path
	} elseif (Test-Path $Path -PathType Container) {
		# If $Path is a folder, return all EXE files inside the folder
		return Get-ChildItem -Path $Path -Filter "*.exe"
	} else {
		# Invalid path specified
		Write-Warning "Invalid path specified: $Path"
		return $null
	}
}

# Default to CurrentUser
$CompatbilityKey = Get-CompatibilityKey

# If AllUsers is specified
if ($AllUsers) {
	# Check if the current user is an administrator
	$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
	if (!$isAdmin) {
		Write-Warning "Insufficient permissions to run this script. Open the PowerShell console as an administrator and run this script again."
		Exit
	}
	$CompatbilityKey = Get-CompatibilityKey -AllUsers
}

# If RegJump is specified, then jump to the registry key
if ($RegJump) {
	# If the RegJump command is not found, let the user know
	if (!(Get-Command -Name regjump -ErrorAction SilentlyContinue)) {
		Write-Output ""
		Write-Warning "RegJump is not installed."
		Write-Output ""
		Write-Output "Please download it from https://docs.microsoft.com/en-us/sysinternals/downloads/regjump and place it in your PATH."
		Write-Output ""
		Write-Output "If you have Chocolatey, you can install it by running 'choco install regjump'."
		Write-Output ""
		exit
	}
	regjump "$CompatbilityKey"
	exit
}

# Extra line
Write-Output ""

# Create Layers key if it does not exist
if (!(Test-Path $CompatbilityKey)) {
	New-Item $CompatbilityKey -Force | Out-Null
}


# Get list of EXE files
$exes = Get-ExeFiles -Path $Path

# Get current user or all user verbiage
if ($AllUsers) {
	$UserVerbiage = "all users"
} else {
	$UserVerbiage = "the current user"
}

# Perform the action on each EXE file
if ($UnsetInstead) {
	$exes | ForEach-Object {
		$updatedExe = AddRunAsAdministrator -ExePath $_.FullName -UnsetInstead
		if ($updatedExe) {
			Write-Output "Unset app to run as Administrator for ${UserVerbiage}: $updatedExe"
		}
	}
} else {
	$exes | ForEach-Object {
		$updatedExe = AddRunAsAdministrator -ExePath $_.FullName
		if ($updatedExe) {
			Write-Output "Set app to run as Administrator for ${UserVerbiage}: $updatedExe"
		}
	}
}

# Extra line
Write-Output ""
# SIG # Begin signature block
# MIIpMQYJKoZIhvcNAQcCoIIpIjCCKR4CAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCD+wgLawX6BrAjI
# r4XQLnkwGYtC3bl7QuEbAXqH1/mjLqCCDh8wggawMIIEmKADAgECAhAIrUCyYNKc
# TJ9ezam9k67ZMA0GCSqGSIb3DQEBDAUAMGIxCzAJBgNVBAYTAlVTMRUwEwYDVQQK
# EwxEaWdpQ2VydCBJbmMxGTAXBgNVBAsTEHd3dy5kaWdpY2VydC5jb20xITAfBgNV
# BAMTGERpZ2lDZXJ0IFRydXN0ZWQgUm9vdCBHNDAeFw0yMTA0MjkwMDAwMDBaFw0z
# NjA0MjgyMzU5NTlaMGkxCzAJBgNVBAYTAlVTMRcwFQYDVQQKEw5EaWdpQ2VydCwg
# SW5jLjFBMD8GA1UEAxM4RGlnaUNlcnQgVHJ1c3RlZCBHNCBDb2RlIFNpZ25pbmcg
# UlNBNDA5NiBTSEEzODQgMjAyMSBDQTEwggIiMA0GCSqGSIb3DQEBAQUAA4ICDwAw
# ggIKAoICAQDVtC9C0CiteLdd1TlZG7GIQvUzjOs9gZdwxbvEhSYwn6SOaNhc9es0
# JAfhS0/TeEP0F9ce2vnS1WcaUk8OoVf8iJnBkcyBAz5NcCRks43iCH00fUyAVxJr
# Q5qZ8sU7H/Lvy0daE6ZMswEgJfMQ04uy+wjwiuCdCcBlp/qYgEk1hz1RGeiQIXhF
# LqGfLOEYwhrMxe6TSXBCMo/7xuoc82VokaJNTIIRSFJo3hC9FFdd6BgTZcV/sk+F
# LEikVoQ11vkunKoAFdE3/hoGlMJ8yOobMubKwvSnowMOdKWvObarYBLj6Na59zHh
# 3K3kGKDYwSNHR7OhD26jq22YBoMbt2pnLdK9RBqSEIGPsDsJ18ebMlrC/2pgVItJ
# wZPt4bRc4G/rJvmM1bL5OBDm6s6R9b7T+2+TYTRcvJNFKIM2KmYoX7BzzosmJQay
# g9Rc9hUZTO1i4F4z8ujo7AqnsAMrkbI2eb73rQgedaZlzLvjSFDzd5Ea/ttQokbI
# YViY9XwCFjyDKK05huzUtw1T0PhH5nUwjewwk3YUpltLXXRhTT8SkXbev1jLchAp
# QfDVxW0mdmgRQRNYmtwmKwH0iU1Z23jPgUo+QEdfyYFQc4UQIyFZYIpkVMHMIRro
# OBl8ZhzNeDhFMJlP/2NPTLuqDQhTQXxYPUez+rbsjDIJAsxsPAxWEQIDAQABo4IB
# WTCCAVUwEgYDVR0TAQH/BAgwBgEB/wIBADAdBgNVHQ4EFgQUaDfg67Y7+F8Rhvv+
# YXsIiGX0TkIwHwYDVR0jBBgwFoAU7NfjgtJxXWRM3y5nP+e6mK4cD08wDgYDVR0P
# AQH/BAQDAgGGMBMGA1UdJQQMMAoGCCsGAQUFBwMDMHcGCCsGAQUFBwEBBGswaTAk
# BggrBgEFBQcwAYYYaHR0cDovL29jc3AuZGlnaWNlcnQuY29tMEEGCCsGAQUFBzAC
# hjVodHRwOi8vY2FjZXJ0cy5kaWdpY2VydC5jb20vRGlnaUNlcnRUcnVzdGVkUm9v
# dEc0LmNydDBDBgNVHR8EPDA6MDigNqA0hjJodHRwOi8vY3JsMy5kaWdpY2VydC5j
# b20vRGlnaUNlcnRUcnVzdGVkUm9vdEc0LmNybDAcBgNVHSAEFTATMAcGBWeBDAED
# MAgGBmeBDAEEATANBgkqhkiG9w0BAQwFAAOCAgEAOiNEPY0Idu6PvDqZ01bgAhql
# +Eg08yy25nRm95RysQDKr2wwJxMSnpBEn0v9nqN8JtU3vDpdSG2V1T9J9Ce7FoFF
# UP2cvbaF4HZ+N3HLIvdaqpDP9ZNq4+sg0dVQeYiaiorBtr2hSBh+3NiAGhEZGM1h
# mYFW9snjdufE5BtfQ/g+lP92OT2e1JnPSt0o618moZVYSNUa/tcnP/2Q0XaG3Ryw
# YFzzDaju4ImhvTnhOE7abrs2nfvlIVNaw8rpavGiPttDuDPITzgUkpn13c5Ubdld
# AhQfQDN8A+KVssIhdXNSy0bYxDQcoqVLjc1vdjcshT8azibpGL6QB7BDf5WIIIJw
# 8MzK7/0pNVwfiThV9zeKiwmhywvpMRr/LhlcOXHhvpynCgbWJme3kuZOX956rEnP
# LqR0kq3bPKSchh/jwVYbKyP/j7XqiHtwa+aguv06P0WmxOgWkVKLQcBIhEuWTatE
# QOON8BUozu3xGFYHKi8QxAwIZDwzj64ojDzLj4gLDb879M4ee47vtevLt/B3E+bn
# KD+sEq6lLyJsQfmCXBVmzGwOysWGw/YmMwwHS6DTBwJqakAwSEs0qFEgu60bhQji
# WQ1tygVQK+pKHJ6l/aCnHwZ05/LWUpD9r4VIIflXO7ScA+2GRfS0YW6/aOImYIbq
# yK+p/pQd52MbOoZWeE4wggdnMIIFT6ADAgECAhAN0Uk2zX4f3m8X7HdlwxBNMA0G
# CSqGSIb3DQEBCwUAMGkxCzAJBgNVBAYTAlVTMRcwFQYDVQQKEw5EaWdpQ2VydCwg
# SW5jLjFBMD8GA1UEAxM4RGlnaUNlcnQgVHJ1c3RlZCBHNCBDb2RlIFNpZ25pbmcg
# UlNBNDA5NiBTSEEzODQgMjAyMSBDQTEwHhcNMjMwMzE3MDAwMDAwWhcNMjQwMzE2
# MjM1OTU5WjBvMQswCQYDVQQGEwJVUzERMA8GA1UECBMIT2tsYWhvbWExETAPBgNV
# BAcTCE11c2tvZ2VlMRwwGgYDVQQKExNBc2hlciBTb2x1dGlvbnMgSW5jMRwwGgYD
# VQQDExNBc2hlciBTb2x1dGlvbnMgSW5jMIICIjANBgkqhkiG9w0BAQEFAAOCAg8A
# MIICCgKCAgEA081RwO7808Fuab0RP0L2gthlZB8fiiGUBpnqJhsD1Bzpk+45B2LA
# qmrUp+nZIXNwr5me/55enGI9CkhaxmZoFhBxoM1u5lODNp8GaAYzIEi0IJldzZ9y
# PAQMfhTkHRiOwKBqTGO3h/gSZtaZ+8F+ltCmlXvv2vpqFpt5JL+uJm9SRIN5WLiP
# QM/isjYR+eIcaZxQeHLfbnemNcaT4cXOMChUsmG6WsoHZO1o76dCN+owz23koLy2
# Y1R3N2PMQj3kj8Bnlph6ffNnitKhXuwj3NkWwPSSQvYhcBuTcCOxpXpUjWlQNuTt
# llTHp9leKMq11raPkSaLe2qVX4eBc6HPtBT+7XagpaA409d7fmYTOLKmE0BCEdgb
# YZzYmKSyjrAgWlU9SYxurhFgHuQFD0CsBW1aXl6IEjn26cVx+hmj2KCOFELAdh1r
# 9UTNt37a/o/TYCp/mQ22/oa/224is1dpNj7RAHnNaix5n8RKKHufEh85lVjS/cBn
# 7z3cCKejyfBaUGK10SUwZKJiJ51DKkRkdh4A5cL85wKkQcFnRpfT/T+KTOEYRFT/
# vz3uK9bMLwuBj+gkP3WnlVXf67IY3FfZaQUDNdtwur4UTGrDQOn8Xl2rEy7L9VlJ
# UOCjX93WfW0B1Q4IxSdF6vIJw1m44HpIU4jxnqTBEo6BVVRCtdmp/x0CAwEAAaOC
# AgMwggH/MB8GA1UdIwQYMBaAFGg34Ou2O/hfEYb7/mF7CIhl9E5CMB0GA1UdDgQW
# BBTH3/U7rGshoJKjtOAVqNAEWJ/PBDAOBgNVHQ8BAf8EBAMCB4AwEwYDVR0lBAww
# CgYIKwYBBQUHAwMwgbUGA1UdHwSBrTCBqjBToFGgT4ZNaHR0cDovL2NybDMuZGln
# aWNlcnQuY29tL0RpZ2lDZXJ0VHJ1c3RlZEc0Q29kZVNpZ25pbmdSU0E0MDk2U0hB
# Mzg0MjAyMUNBMS5jcmwwU6BRoE+GTWh0dHA6Ly9jcmw0LmRpZ2ljZXJ0LmNvbS9E
# aWdpQ2VydFRydXN0ZWRHNENvZGVTaWduaW5nUlNBNDA5NlNIQTM4NDIwMjFDQTEu
# Y3JsMD4GA1UdIAQ3MDUwMwYGZ4EMAQQBMCkwJwYIKwYBBQUHAgEWG2h0dHA6Ly93
# d3cuZGlnaWNlcnQuY29tL0NQUzCBlAYIKwYBBQUHAQEEgYcwgYQwJAYIKwYBBQUH
# MAGGGGh0dHA6Ly9vY3NwLmRpZ2ljZXJ0LmNvbTBcBggrBgEFBQcwAoZQaHR0cDov
# L2NhY2VydHMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0VHJ1c3RlZEc0Q29kZVNpZ25p
# bmdSU0E0MDk2U0hBMzg0MjAyMUNBMS5jcnQwCQYDVR0TBAIwADANBgkqhkiG9w0B
# AQsFAAOCAgEAQtDUmTp7UG2w4A4WaT6BoMLBLqzm09S64nFfuIUFjWk3KTCStpwR
# 3KzwG78CpYb7I0G6T7O2Emv+u0WgKVaWPbLFlnrjXXB+68DxR+CFWh6UDioz/9wo
# +eD/V2eKilAc2WSEIC8NzXT3C4yEtxUmnebK7Ysxy4qLlb4Sxk9NspS+Lg3jKBxb
# ExduQWHi1ytqw9NCghzK1Y2h5/AHwSYfwz7AyRerN3gTwzmmgTaWYEHVCL0NQddO
# 1lkSz6LPq2/JWHns7I0tNPCT5nZYva1v34EZvP9+P+SUDBH8bfrm6HlTd+Z6qNW5
# ACsALaCCAsZRQ6i7UZfjolD/lADn65f46XfnNMIo8PPpagFBIvxg03DGDJQu4QnY
# AyZhtrLDxc8VLtGZP8QVBf9JVcjVD8FxMMobDnuDq0YZ1h3ydRo1dqOzWVDipp0i
# oPd0UbL7EcZr6QcM72LWFvAACyVcIiXlh5jY+JehqaZMlS9aw4WQT0gpvBOaOJqb
# vGoAbtyHRFIkFbJG/Wxkpr+VkU1JvilXCh8g0OsXwvJk4dK4GeBVa7VLlq95fLiK
# zL54EZDTY1W+YfKYUseiptRlu5XBUn15C9rTpqDZhHFz6exyLfYcJzdxJJdArjio
# UKKR9ZhLfxm1bmFMb8NPWOKH/ZI6vR0jNgwalk3nTx63ZnVAOJLH+BkxghpoMIIa
# ZAIBATB9MGkxCzAJBgNVBAYTAlVTMRcwFQYDVQQKEw5EaWdpQ2VydCwgSW5jLjFB
# MD8GA1UEAxM4RGlnaUNlcnQgVHJ1c3RlZCBHNCBDb2RlIFNpZ25pbmcgUlNBNDA5
# NiBTSEEzODQgMjAyMSBDQTECEA3RSTbNfh/ebxfsd2XDEE0wDQYJYIZIAWUDBAIB
# BQCgfDAQBgorBgEEAYI3AgEMMQIwADAZBgkqhkiG9w0BCQMxDAYKKwYBBAGCNwIB
# BDAcBgorBgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAvBgkqhkiG9w0BCQQxIgQg
# 6aYh0qd6Eis4/0R+5gSOALX0/6rOllpw+jOu6LcY40AwDQYJKoZIhvcNAQEBBQAE
# ggIAi+Kso46n10d7kKJQ1EgqRkshR8TTJzIfaVntPIe1CbA9NhYgK+s+ZRV9SU/F
# qIaAJE/SPxZw13PcsB2Btx96Ndlfho58YxWLwbSbBsAs/9PcDB61LiifczwZsLZ0
# ockjmHQm66XOgiC0OmUtpQC6WNEhOvWSILIGAbTbK2QJU0VY89fLwhB/GrMl/zIT
# YTYb64/UYwl0rWnunePpxagxvnKuWcArAVvDqRoMXJnO6c+qbY/UBoXLnXCp1BAj
# CzM1WjR12rE1yhkpcNmQX62cKUTEWMyKYbwTtCp3v9yNJRo1v16BjyXn6E9V0QAo
# 4/Mun55SSFNIbzsn2QTZezAv2fbbCQMtUqxhO0Io7jZDcUPVHont9ZazbOcHDfym
# cZSrFUSw47XsAy3WlKoxXVNJo/WhpJEjuwlAUw2ozgVSpDuhsufZpxplZhCPDe4v
# o/KYWt4FmiehOROJVUHrtdrqwWBz7qfaWMXmMmHQQQqN8dzPscwdPJuV5XfajHfj
# y0gEzWV0FCSc7kJ1AWkgurudyZ46IxobQIijv2LU+QJUMD380EW3X5XYPdEho+Ow
# zqe1EOUKsvikZxu0ufiYJ3c1zyktRLEBXetrEiJ2zvxYjR9mw2/ZT5w1zUamBX2z
# FP97gXXbs6p+9zdBZn1yUyUtvBhk2dflniaPf/qg1SrXoGqhghc+MIIXOgYKKwYB
# BAGCNwMDATGCFyowghcmBgkqhkiG9w0BBwKgghcXMIIXEwIBAzEPMA0GCWCGSAFl
# AwQCAQUAMHgGCyqGSIb3DQEJEAEEoGkEZzBlAgEBBglghkgBhv1sBwEwMTANBglg
# hkgBZQMEAgEFAAQg6gQsJD4T4vVgDUpuK7AJVQGDCMm9Oylzzrerg3IyoHUCEQCk
# +Xj+VAaji74VT/jmpuEmGA8yMDIzMDYxNzA5NDg1NlqgghMHMIIGwDCCBKigAwIB
# AgIQDE1pckuU+jwqSj0pB4A9WjANBgkqhkiG9w0BAQsFADBjMQswCQYDVQQGEwJV
# UzEXMBUGA1UEChMORGlnaUNlcnQsIEluYy4xOzA5BgNVBAMTMkRpZ2lDZXJ0IFRy
# dXN0ZWQgRzQgUlNBNDA5NiBTSEEyNTYgVGltZVN0YW1waW5nIENBMB4XDTIyMDky
# MTAwMDAwMFoXDTMzMTEyMTIzNTk1OVowRjELMAkGA1UEBhMCVVMxETAPBgNVBAoT
# CERpZ2lDZXJ0MSQwIgYDVQQDExtEaWdpQ2VydCBUaW1lc3RhbXAgMjAyMiAtIDIw
# ggIiMA0GCSqGSIb3DQEBAQUAA4ICDwAwggIKAoICAQDP7KUmOsap8mu7jcENmtuh
# 6BSFdDMaJqzQHFUeHjZtvJJVDGH0nQl3PRWWCC9rZKT9BoMW15GSOBwxApb7crGX
# OlWvM+xhiummKNuQY1y9iVPgOi2Mh0KuJqTku3h4uXoW4VbGwLpkU7sqFudQSLuI
# aQyIxvG+4C99O7HKU41Agx7ny3JJKB5MgB6FVueF7fJhvKo6B332q27lZt3iXPUv
# 7Y3UTZWEaOOAy2p50dIQkUYp6z4m8rSMzUy5Zsi7qlA4DeWMlF0ZWr/1e0Bubxao
# mpyVR4aFeT4MXmaMGgokvpyq0py2909ueMQoP6McD1AGN7oI2TWmtR7aeFgdOej4
# TJEQln5N4d3CraV++C0bH+wrRhijGfY59/XBT3EuiQMRoku7mL/6T+R7Nu8GRORV
# /zbq5Xwx5/PCUsTmFntafqUlc9vAapkhLWPlWfVNL5AfJ7fSqxTlOGaHUQhr+1ND
# OdBk+lbP4PQK5hRtZHi7mP2Uw3Mh8y/CLiDXgazT8QfU4b3ZXUtuMZQpi+ZBpGWU
# wFjl5S4pkKa3YWT62SBsGFFguqaBDwklU/G/O+mrBw5qBzliGcnWhX8T2Y15z2LF
# 7OF7ucxnEweawXjtxojIsG4yeccLWYONxu71LHx7jstkifGxxLjnU15fVdJ9GSlZ
# A076XepFcxyEftfO4tQ6dwIDAQABo4IBizCCAYcwDgYDVR0PAQH/BAQDAgeAMAwG
# A1UdEwEB/wQCMAAwFgYDVR0lAQH/BAwwCgYIKwYBBQUHAwgwIAYDVR0gBBkwFzAI
# BgZngQwBBAIwCwYJYIZIAYb9bAcBMB8GA1UdIwQYMBaAFLoW2W1NhS9zKXaaL3WM
# aiCPnshvMB0GA1UdDgQWBBRiit7QYfyPMRTtlwvNPSqUFN9SnDBaBgNVHR8EUzBR
# ME+gTaBLhklodHRwOi8vY3JsMy5kaWdpY2VydC5jb20vRGlnaUNlcnRUcnVzdGVk
# RzRSU0E0MDk2U0hBMjU2VGltZVN0YW1waW5nQ0EuY3JsMIGQBggrBgEFBQcBAQSB
# gzCBgDAkBggrBgEFBQcwAYYYaHR0cDovL29jc3AuZGlnaWNlcnQuY29tMFgGCCsG
# AQUFBzAChkxodHRwOi8vY2FjZXJ0cy5kaWdpY2VydC5jb20vRGlnaUNlcnRUcnVz
# dGVkRzRSU0E0MDk2U0hBMjU2VGltZVN0YW1waW5nQ0EuY3J0MA0GCSqGSIb3DQEB
# CwUAA4ICAQBVqioa80bzeFc3MPx140/WhSPx/PmVOZsl5vdyipjDd9Rk/BX7NsJJ
# USx4iGNVCUY5APxp1MqbKfujP8DJAJsTHbCYidx48s18hc1Tna9i4mFmoxQqRYdK
# mEIrUPwbtZ4IMAn65C3XCYl5+QnmiM59G7hqopvBU2AJ6KO4ndetHxy47JhB8PYO
# gPvk/9+dEKfrALpfSo8aOlK06r8JSRU1NlmaD1TSsht/fl4JrXZUinRtytIFZyt2
# 6/+YsiaVOBmIRBTlClmia+ciPkQh0j8cwJvtfEiy2JIMkU88ZpSvXQJT657inuTT
# H4YBZJwAwuladHUNPeF5iL8cAZfJGSOA1zZaX5YWsWMMxkZAO85dNdRZPkOaGK7D
# ycvD+5sTX2q1x+DzBcNZ3ydiK95ByVO5/zQQZ/YmMph7/lxClIGUgp2sCovGSxVK
# 05iQRWAzgOAj3vgDpPZFR+XOuANCR+hBNnF3rf2i6Jd0Ti7aHh2MWsgemtXC8MYi
# qE+bvdgcmlHEL5r2X6cnl7qWLoVXwGDneFZ/au/ClZpLEQLIgpzJGgV8unG1TnqZ
# bPTontRamMifv427GFxD9dAq6OJi7ngE273R+1sKqHB+8JeEeOMIA11HLGOoJTiX
# AdI/Otrl5fbmm9x+LMz/F0xNAKLY1gEOuIvu5uByVYksJxlh9ncBjDCCBq4wggSW
# oAMCAQICEAc2N7ckVHzYR6z9KGYqXlswDQYJKoZIhvcNAQELBQAwYjELMAkGA1UE
# BhMCVVMxFTATBgNVBAoTDERpZ2lDZXJ0IEluYzEZMBcGA1UECxMQd3d3LmRpZ2lj
# ZXJ0LmNvbTEhMB8GA1UEAxMYRGlnaUNlcnQgVHJ1c3RlZCBSb290IEc0MB4XDTIy
# MDMyMzAwMDAwMFoXDTM3MDMyMjIzNTk1OVowYzELMAkGA1UEBhMCVVMxFzAVBgNV
# BAoTDkRpZ2lDZXJ0LCBJbmMuMTswOQYDVQQDEzJEaWdpQ2VydCBUcnVzdGVkIEc0
# IFJTQTQwOTYgU0hBMjU2IFRpbWVTdGFtcGluZyBDQTCCAiIwDQYJKoZIhvcNAQEB
# BQADggIPADCCAgoCggIBAMaGNQZJs8E9cklRVcclA8TykTepl1Gh1tKD0Z5Mom2g
# sMyD+Vr2EaFEFUJfpIjzaPp985yJC3+dH54PMx9QEwsmc5Zt+FeoAn39Q7SE2hHx
# c7Gz7iuAhIoiGN/r2j3EF3+rGSs+QtxnjupRPfDWVtTnKC3r07G1decfBmWNlCnT
# 2exp39mQh0YAe9tEQYncfGpXevA3eZ9drMvohGS0UvJ2R/dhgxndX7RUCyFobjch
# u0CsX7LeSn3O9TkSZ+8OpWNs5KbFHc02DVzV5huowWR0QKfAcsW6Th+xtVhNef7X
# j3OTrCw54qVI1vCwMROpVymWJy71h6aPTnYVVSZwmCZ/oBpHIEPjQ2OAe3VuJyWQ
# mDo4EbP29p7mO1vsgd4iFNmCKseSv6De4z6ic/rnH1pslPJSlRErWHRAKKtzQ87f
# SqEcazjFKfPKqpZzQmiftkaznTqj1QPgv/CiPMpC3BhIfxQ0z9JMq++bPf4OuGQq
# +nUoJEHtQr8FnGZJUlD0UfM2SU2LINIsVzV5K6jzRWC8I41Y99xh3pP+OcD5sjCl
# TNfpmEpYPtMDiP6zj9NeS3YSUZPJjAw7W4oiqMEmCPkUEBIDfV8ju2TjY+Cm4T72
# wnSyPx4JduyrXUZ14mCjWAkBKAAOhFTuzuldyF4wEr1GnrXTdrnSDmuZDNIztM2x
# AgMBAAGjggFdMIIBWTASBgNVHRMBAf8ECDAGAQH/AgEAMB0GA1UdDgQWBBS6Ftlt
# TYUvcyl2mi91jGogj57IbzAfBgNVHSMEGDAWgBTs1+OC0nFdZEzfLmc/57qYrhwP
# TzAOBgNVHQ8BAf8EBAMCAYYwEwYDVR0lBAwwCgYIKwYBBQUHAwgwdwYIKwYBBQUH
# AQEEazBpMCQGCCsGAQUFBzABhhhodHRwOi8vb2NzcC5kaWdpY2VydC5jb20wQQYI
# KwYBBQUHMAKGNWh0dHA6Ly9jYWNlcnRzLmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydFRy
# dXN0ZWRSb290RzQuY3J0MEMGA1UdHwQ8MDowOKA2oDSGMmh0dHA6Ly9jcmwzLmRp
# Z2ljZXJ0LmNvbS9EaWdpQ2VydFRydXN0ZWRSb290RzQuY3JsMCAGA1UdIAQZMBcw
# CAYGZ4EMAQQCMAsGCWCGSAGG/WwHATANBgkqhkiG9w0BAQsFAAOCAgEAfVmOwJO2
# b5ipRCIBfmbW2CFC4bAYLhBNE88wU86/GPvHUF3iSyn7cIoNqilp/GnBzx0H6T5g
# yNgL5Vxb122H+oQgJTQxZ822EpZvxFBMYh0MCIKoFr2pVs8Vc40BIiXOlWk/R3f7
# cnQU1/+rT4osequFzUNf7WC2qk+RZp4snuCKrOX9jLxkJodskr2dfNBwCnzvqLx1
# T7pa96kQsl3p/yhUifDVinF2ZdrM8HKjI/rAJ4JErpknG6skHibBt94q6/aesXmZ
# gaNWhqsKRcnfxI2g55j7+6adcq/Ex8HBanHZxhOACcS2n82HhyS7T6NJuXdmkfFy
# nOlLAlKnN36TU6w7HQhJD5TNOXrd/yVjmScsPT9rp/Fmw0HNT7ZAmyEhQNC3EyTN
# 3B14OuSereU0cZLXJmvkOHOrpgFPvT87eK1MrfvElXvtCl8zOYdBeHo46Zzh3SP9
# HSjTx/no8Zhf+yvYfvJGnXUsHicsJttvFXseGYs2uJPU5vIXmVnKcPA3v5gA3yAW
# Tyf7YGcWoWa63VXAOimGsJigK+2VQbc61RWYMbRiCQ8KvYHZE/6/pNHzV9m8BPqC
# 3jLfBInwAM1dwvnQI38AC+R2AibZ8GV2QqYphwlHK+Z/GqSFD/yYlvZVVCsfgPrA
# 8g4r5db7qS9EFUrnEw4d2zc4GqEr9u3WfPwwggWNMIIEdaADAgECAhAOmxiO+dAt
# 5+/bUOIIQBhaMA0GCSqGSIb3DQEBDAUAMGUxCzAJBgNVBAYTAlVTMRUwEwYDVQQK
# EwxEaWdpQ2VydCBJbmMxGTAXBgNVBAsTEHd3dy5kaWdpY2VydC5jb20xJDAiBgNV
# BAMTG0RpZ2lDZXJ0IEFzc3VyZWQgSUQgUm9vdCBDQTAeFw0yMjA4MDEwMDAwMDBa
# Fw0zMTExMDkyMzU5NTlaMGIxCzAJBgNVBAYTAlVTMRUwEwYDVQQKEwxEaWdpQ2Vy
# dCBJbmMxGTAXBgNVBAsTEHd3dy5kaWdpY2VydC5jb20xITAfBgNVBAMTGERpZ2lD
# ZXJ0IFRydXN0ZWQgUm9vdCBHNDCCAiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoC
# ggIBAL/mkHNo3rvkXUo8MCIwaTPswqclLskhPfKK2FnC4SmnPVirdprNrnsbhA3E
# MB/zG6Q4FutWxpdtHauyefLKEdLkX9YFPFIPUh/GnhWlfr6fqVcWWVVyr2iTcMKy
# unWZanMylNEQRBAu34LzB4TmdDttceItDBvuINXJIB1jKS3O7F5OyJP4IWGbNOsF
# xl7sWxq868nPzaw0QF+xembud8hIqGZXV59UWI4MK7dPpzDZVu7Ke13jrclPXuU1
# 5zHL2pNe3I6PgNq2kZhAkHnDeMe2scS1ahg4AxCN2NQ3pC4FfYj1gj4QkXCrVYJB
# MtfbBHMqbpEBfCFM1LyuGwN1XXhm2ToxRJozQL8I11pJpMLmqaBn3aQnvKFPObUR
# WBf3JFxGj2T3wWmIdph2PVldQnaHiZdpekjw4KISG2aadMreSx7nDmOu5tTvkpI6
# nj3cAORFJYm2mkQZK37AlLTSYW3rM9nF30sEAMx9HJXDj/chsrIRt7t/8tWMcCxB
# YKqxYxhElRp2Yn72gLD76GSmM9GJB+G9t+ZDpBi4pncB4Q+UDCEdslQpJYls5Q5S
# UUd0viastkF13nqsX40/ybzTQRESW+UQUOsxxcpyFiIJ33xMdT9j7CFfxCBRa2+x
# q4aLT8LWRV+dIPyhHsXAj6KxfgommfXkaS+YHS312amyHeUbAgMBAAGjggE6MIIB
# NjAPBgNVHRMBAf8EBTADAQH/MB0GA1UdDgQWBBTs1+OC0nFdZEzfLmc/57qYrhwP
# TzAfBgNVHSMEGDAWgBRF66Kv9JLLgjEtUYunpyGd823IDzAOBgNVHQ8BAf8EBAMC
# AYYweQYIKwYBBQUHAQEEbTBrMCQGCCsGAQUFBzABhhhodHRwOi8vb2NzcC5kaWdp
# Y2VydC5jb20wQwYIKwYBBQUHMAKGN2h0dHA6Ly9jYWNlcnRzLmRpZ2ljZXJ0LmNv
# bS9EaWdpQ2VydEFzc3VyZWRJRFJvb3RDQS5jcnQwRQYDVR0fBD4wPDA6oDigNoY0
# aHR0cDovL2NybDMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0QXNzdXJlZElEUm9vdENB
# LmNybDARBgNVHSAECjAIMAYGBFUdIAAwDQYJKoZIhvcNAQEMBQADggEBAHCgv0Nc
# Vec4X6CjdBs9thbX979XB72arKGHLOyFXqkauyL4hxppVCLtpIh3bb0aFPQTSnov
# Lbc47/T/gLn4offyct4kvFIDyE7QKt76LVbP+fT3rDB6mouyXtTP0UNEm0Mh65Zy
# oUi0mcudT6cGAxN3J0TU53/oWajwvy8LpunyNDzs9wPHh6jSTEAZNUZqaVSwuKFW
# juyk1T3osdz9HNj0d1pcVIxv76FQPfx2CWiEn2/K2yCNNWAcAgPLILCsWKAOQGPF
# mCLBsln1VWvPJ6tsds5vIy30fnFqI2si/xK4VC0nftg62fC2h5b9W9FcrBjDTZ9z
# twGpn1eqXijiuZQxggN2MIIDcgIBATB3MGMxCzAJBgNVBAYTAlVTMRcwFQYDVQQK
# Ew5EaWdpQ2VydCwgSW5jLjE7MDkGA1UEAxMyRGlnaUNlcnQgVHJ1c3RlZCBHNCBS
# U0E0MDk2IFNIQTI1NiBUaW1lU3RhbXBpbmcgQ0ECEAxNaXJLlPo8Kko9KQeAPVow
# DQYJYIZIAWUDBAIBBQCggdEwGgYJKoZIhvcNAQkDMQ0GCyqGSIb3DQEJEAEEMBwG
# CSqGSIb3DQEJBTEPFw0yMzA2MTcwOTQ4NTZaMCsGCyqGSIb3DQEJEAIMMRwwGjAY
# MBYEFPOHIk2GM4KSNamUvL2Plun+HHxzMC8GCSqGSIb3DQEJBDEiBCAVvAUwsDU9
# pR31vw+MqwXYj/YgK0WbI8S+TbcSiPwYmjA3BgsqhkiG9w0BCRACLzEoMCYwJDAi
# BCDH9OG+MiiJIKviJjq+GsT8T+Z4HC1k0EyAdVegI7W2+jANBgkqhkiG9w0BAQEF
# AASCAgA/nakC+hrXucM0ak293j+L+FpZkAvSwbxlx3kRE+hU9UsCZNzzQPmLgv1R
# Q4+nqgGR2QE8JaG5Zn9kLlgW3Tb/Hc+uBwaN0Q/8e/h5QwBCFj20UuclrhPA0Z6Q
# Wx/ZDealaKy861wvLh30IfBCznu0GISv2uypbUV/Zhx0DX14RAXBt6kGb5EnSUBg
# UpJUniqdsr9xtdmQLr7w8LUZOY0kcDGcTC3ROT1rt/mfpgUYTS9e7rDpZKV2E8NL
# tV4YFYC8B/pfWXzm8DkRNrz3xSTLc71LhHYg6j4RP0tZGZv0jeeeQbaCru+KMPLr
# ep86KkoAvAQYItveww9jsdRIlTk+RB1Jt9pYXMwYSfhnhulYhugLGCbw3VpuYUB+
# XPDF3N8gDWtXC4ggez3nkU7ljdatZq+7KVcezZLeo77Zk1rVTr1f6YHIQWMRvMB9
# EjxrnzjMa/IQ2SJWHpgB0Y7f5e62wjEAwgtH7EqMsE/VgTveD9KI01n05dHIM1H6
# JFO8gIwIO3kjYUb+yzb8b5mF0a3Vr5Hd4d4WrU/8sSNr7stHknEdNcnGp4Zv1kds
# z8zLJgm5YfBGczlo9KBlmqwPDo4H+9ljFM3Qmm+QqE8GUxN/OJwweqV01i4BrPt1
# Cf6LIYY8j6MMVGdSc+/0DQC1ncfHT8r1sio4EUNp1qU2usn4Iw==
# SIG # End signature block