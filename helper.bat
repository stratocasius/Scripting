@echo off

:: looking for registry
set KEY_NAME="HKEY_LOCAL_MACHINE\Software\Eclipse Adoptium\JRE"
set VALUE_NAME=CurrentVersion

FOR /F "usebackq skip=2 tokens=1-3" %%A IN (`REG QUERY %KEY_NAME% /v %VALUE_NAME% 2^>nul`) DO (
    set ValueValue=%%C
)

SET KEY_NAME="%KEY_NAME:~1,-1%\%ValueValue%"
SET VALUE_NAME=JavaHome

FOR /F "usebackq skip=2 tokens=2* delims= " %%A IN (`REG QUERY %KEY_NAME% /v %VALUE_NAME% 2^>nul`) DO (
    set JRE_PATH2=%%B
)

if defined JRE_PATH2 (
	if exist %JRE_PATH2%\bin\javaw.exe (
		set JAVAW_PATH="%JRE_PATH2%\bin\javaw.exe"
		goto end
	)
)

:: looking for environment variable JAVA_HOME
if defined JAVA_HOME (
	if exist "%JAVA_HOME%\bin\javaw.exe" (
		set JAVAW_PATH="%JAVA_HOME%\bin\javaw.exe"
		goto end
	)
)

:: check system32 folder
if exist %WINDIR%\System32\javaw.exe (
	set JAVAW_PATH="%WINDIR%\System32\javaw.exe"
	goto end
)

:: check for Adoptium JDK/JRE 64-bit (Eclipse Temurin)
if exist %SystemDrive%\"Program Files"\AdoptOpenJDK\jdk-11* (
	for /f "delims=" %%a in ('dir /s /b "%SystemDrive%\Program Files\AdoptOpenJDK\jdk-11*"') do (
		if exist %%a\bin\javaw.exe (
			set JAVAW_PATH="%%a\bin\javaw.exe"
			goto end
		)
	)
)

:: check for Adoptium JDK/JRE 64-bit (Eclipse Temurin)
if exist %SystemDrive%\"Program Files"\Eclipse Adoptium\jdk-11* (
	for /f "delims=" %%a in ('dir /s /b "%SystemDrive%\Program Files\Eclipse Adoptium\jre-8.0.422.5-hotspot*"') do (
		if exist %%a\bin\javaw.exe (
			set JAVAW_PATH="%%a\bin\javaw.exe"
			goto end
		)
	)
)

:: check for java 11 Corretto 64bit
if exist %SystemDrive%\"Program Files"\"Amazon Corretto"\jdk11* (
	for /f "delims=" %%a in ('dir /s /b "%SystemDrive%\Program Files\Amazon Corretto\jdk11*"') do (
		if exist %%a\bin\javaw.exe (
			set JAVAW_PATH="%%a\bin\javaw.exe"
			goto end
		)
	)
)

:: check for java 8 64bit
if exist %SystemDrive%\"Program Files"\Java\jre1.8* (
	for /f "delims=" %%a in ('dir /s /b "%SystemDrive%\Program Files\Java\jre1.8*"') do (
		if exist %%a\bin\javaw.exe (
			set JAVAW_PATH="%%a\bin\javaw.exe"
			goto end
		)
	)
)

:: check for java 8 32bit
if exist %SystemDrive%\"Program Files (x86)"\Java\jre1.8* (
	for /f "delims=" %%b in ('dir /s /b "%SystemDrive%\Program Files (x86)\Java\jre1.8*"') do (
		set MyPath=%%b
		if exist %%b\bin\javaw.exe (
			set JAVAW_PATH="%%b\bin\javaw.exe"
			goto end
		)
	)
)

:: check the Integration Builder Folder
if exist "%~dp0\javaw.exe" (
	set JAVAW_PATH="%~dp0\javaw.exe"
	goto end
)

:: search disk to find javaw.exe
echo Searching for Java Runtime Environment please wait...

for %%d in (A B C D E F G H I J K L M N O P Q R S T U V W X Y Z) do (
    for /f "delims=" %%F in ('dir %%d:\javaw.exe /b/s 2^>nul') do (
		set JAVAW_PATH="%%F"
		copy "%%F" "%~dp0"
		goto end
	)
)

:end