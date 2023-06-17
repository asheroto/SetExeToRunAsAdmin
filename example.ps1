./SetExeToRunAsAdmin.ps1 -RegJump
./SetExeToRunAsAdmin.ps1 -RegJump -CurrentUser
./SetExeToRunAsAdmin.ps1 -RegJump -AllUsers

./SetExeToRunAsAdmin.ps1 -Path "C:\tools\ffmpeg-full\bin\ffmpeg.exe"
./SetExeToRunAsAdmin.ps1 -Path "C:\tools\ffmpeg-full\bin\ffmpeg.exe" -UnsetInstead
./SetExeToRunAsAdmin.ps1 -Path "C:\tools\ffmpeg-full\bin\ffmpeg.exe" -CurrentUser
./SetExeToRunAsAdmin.ps1 -Path "C:\tools\ffmpeg-full\bin\ffmpeg.exe" -CurrentUser -UnsetInstead
./SetExeToRunAsAdmin.ps1 -Path "C:\tools\ffmpeg-full\bin\ffmpeg.exe" -AllUsers
./SetExeToRunAsAdmin.ps1 -Path "C:\tools\ffmpeg-full\bin\ffmpeg.exe" -AllUsers -UnsetInstead

./SetExeToRunAsAdmin.ps1 -Path "C:\tools\ffmpeg-full\bin"
./SetExeToRunAsAdmin.ps1 -Path "C:\tools\ffmpeg-full\bin" -UnsetInstead
./SetExeToRunAsAdmin.ps1 -Path "C:\tools\ffmpeg-full\bin" -CurrentUser
./SetExeToRunAsAdmin.ps1 -Path "C:\tools\ffmpeg-full\bin" -CurrentUser -UnsetInstead
./SetExeToRunAsAdmin.ps1 -Path "C:\tools\ffmpeg-full\bin" -AllUsers
./SetExeToRunAsAdmin.ps1 -Path "C:\tools\ffmpeg-full\bin" -AllUsers -UnsetInstead