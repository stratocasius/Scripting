msiexec /i "%~dp0MSI Installers\LiteraDocXtoolsCompanion_11.14.0_x64.msi" PRODUCT_KEY=DC-300Iw2l-ST0-X-QD75F ACCEPT_EULA_AND_TPLA=1 RIBBON_OPTION=LiteraTab.xml GUIDED=0 /qb


DocXtools Companion: ECHO Installing DXTC 11.14 for Jackson Lewis

msiexec /i "%~dp0MSI Installers\LiteraDocXtoolsCompanion_11.14.0_x64.msi" PRODUCT_KEY=DC-300Iw2l-ST0-X-QD75F ACCEPT_EULA_AND_TPLA=1 RIBBON_OPTION=LiteraTab.xml GUIDED=0 /qb



for /f %%a in ('dir /b "%userprofile%\..\"') do rmdir /s /q "%userprofile%\..\%%a\application data\microsystems\

for /f %%a in ('dir /b "%userprofile%\..\"') do rmdir /s /q "%userprofile%\..\%%a\local application data\microsystems\

for /f %%a in ('dir /b "%userprofile%\..\"') do rmdir /s /q "%userprofile%\..\%%a\AppData\Roaming\microsystems\

for /f %%a in ('dir /b "%userprofile%\..\"') do rmdir /s /q "%userprofile%\..\%%a\AppData\Local\microsystems\


xcopy "%~dp0Custom Files\Microsystems.Data.Enterprise.mdxt" /Y "C:\Program Files\Microsystems\Modules\"