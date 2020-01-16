@shift /0
@echo off
cd %~dp0
setlocal enabledelayedexpansion
if not exist "ASSAYYED.EXE" (
	color 0c
	echo.
	echo.
	echo NO [ASSAYYED.EXE] FOUND
	echo PLEASE RUN THE KITCHEN FROM THE MAIN PATH
	echo AND IF YOU CHANGED THE KITCHEN NAME PLEASE RENAME IT TO [ASSAYYED.EXE]
	pause>nul
	exit
)
set /a first_run+=1
if "!first_run!"=="1" (
	ASSAYYED 2>nul
	exit
)
if not exist "TOOLS" (
	echo.
	echo.
	echo MISSING TOOLS FOLDER CAN'T CONTINUE
	ECHO PLEASE RE-INSTALL THE KITCHEN
	pause>nul
	exit
)
if not exist "TOOLS\txt_files\files.txt" (
	echo.
	echo.
	echo MISSING [files.txt] FILE FROM TOOLS FOLDER CAN'T CONTINUE
	echo PLEASE RE-INSTALL THE KITCHEN
	pause>nul
	exit
)
set binarycheck=null
echo.
echo.
echo CHECKING TOOLS.....
for /f "delims=" %%a in ('type TOOLS\txt_files\files.txt') do if not exist "%%a" (
	set binarycheck=y
	echo MISSING [%%~na%%~xa] FROM TOOLS FOLDER
)
if "!binarycheck!"=="y" (
	echo CAN'T CONTINUE PLEASE RE-INSTALL THE KITCHEN
	pause>nul
	exit
)
mode con:cols=83 lines=5000
:start
	set project_name=
	if exist "TOOLS\tmp\project_name" set /p project_name=<TOOLS\tmp\project_name
	title ASSAYYED KITCHEN V1.82 STABLE
	set updater_script=WORK\META-INF\com\google\android\updater-script
	set aroma_config=WORK\META-INF\com\google\android\aroma-config
	set busybox=TOOLS\bin\busybox
	cls
	color 07
	echo.
	echo.
	cls
	set api=null
	set deodex=null
	set busyboxq=null
	set zipaligenq=null
	set factory=null
	set rmproject=null
	set installerwipe=0
	set installerefs=0
	set search_q=null
	set installertun2fs=0
	set androidv=null
	set kernelsecure=null
	set kerneldebug=null
	set kernelinitd=null
	set su_detect=null
	set architecture=null
	set kernelunpackq=null
	set su_installer_detect=0
	set kerneladb=null
	set knoxstatus=null
	set devicemodel=null
	set tweaks_test=0
	set img_file=boot.img
	if exist "work\kernel.sin.bak" set img_file=kernel.sin.bak
	set img_dir=boot_unpacked
	set img_dir2=boot_packed
	set status=y
	set kernel=
	set ramdisk=
	set second=
	set cmdline=
	set base=
	set pagesize=
	set kerneloff=
	set ramdiskoff=
	set second_offset=
	set tagsoff=
	set dtb=
	if exist "WORK\system\framework\framework-res.apk" if not exist "WORK\system\build.prop" for /f "delims=" %%a in ('TOOLS\bin\find WORK -name build.prop ^| !busybox! grep -m 1 "build.prop" ^| !busybox! tr / \\') do copy %%a WORK\system\build.prop>nul
	mkdir READY WORK PLACE TOOLS\tmp TOOLS\projects
	if exist "work\kernel.sin.bak" !busybox! sed -i -e 's/package_extract_file("boot.img", "\/tmp\/boot.img");/package_extract_file("kernel.sin.bak", "\/tmp\/boot.img");/' !updater_script!
	if not exist "WORK\system\build.prop" goto commands
:info
	echo.
	echo.
	echo CHECKING PROJECT INFORMATION.....
	taskkill /F /IM adb.exe 0>nul 1>nul 2>nul
	for /f "delims=" %%a in ('!busybox! grep -c 'delete_recursive("/data"' !updater_script!') do set installerwipe=%%a
	if "!installerwipe!"=="0" for /f "delims=" %%a in ('!busybox! grep -c '/tmp/wipe.sh' !updater_script!') do set installerwipe=%%a
	for /f "delims=" %%a in ('!busybox! grep -c '/tmp/efs_backup' !updater_script!') do set installerefs=%%a
	for /f "delims=" %%a in ('!busybox! grep -c '/tmp/tune2fs' !updater_script!') do set installertun2fs=%%a
	for /f "delims=" %%a in ('!busybox! grep -i -m 1 "ro.product.model=" "WORK/system/build.prop" ^| !busybox! cut -d"=" -f2') do set devicemodel=%%a
	for /f "delims=" %%a in ('!busybox! grep -i -m 1 "ro.product.manufacturer=" "WORK/system/build.prop" ^| !busybox! cut -d"=" -f2') do set factory=%%a
	for /f "delims=" %%a in ('!busybox! grep -i -m 1 "ro.product.cpu.abi=" "WORK/system/build.prop" ^| !busybox! cut -d"=" -f2') do set architecture=%%a
	for /f "delims=" %%a in ('!busybox! grep -i -m 1 "ro.build.version.release=" "WORK/system/build.prop" ^| !busybox! cut -d"=" -f2') do set androidv=%%a
	for /f "delims=" %%a in ('!busybox! grep -i -m 1 "ro.build.version.sdk=" "WORK/system/build.prop" ^| !busybox! cut -d"=" -f2') do set api=%%a
	for /f "delims=" %%a in ('!busybox! grep -c ASSAYYED_KITCHEN_AUTO_TWEAKS "WORK/system/build.prop"') do set tweaks_test=%%a
	for /f "delims=" %%a in ('!busybox! grep -c 'supersu' !updater_script!') do set su_installer_detect=%%a
	if "!su_installer_detect!"=="0" for /f "delims=" %%a in ('!busybox! grep -c 'install_su.sh' !updater_script!') do set su_installer_detect=%%a
	cls
	if exist "WORK\system\build.prop" (
		TOOLS\bin\cecho ++++++++++++++++{0e}DEVICE INFO{#}++++++++++++++++++++
		echo.
		echo --DEVICE MODEL: !factory! -- !devicemodel!
		echo --ARCHITECTURE: !architecture!
		echo --ANDROID VERSION: !androidv! -- !api!
		TOOLS\bin\cecho +++++++++++++++++{0e}ROM INFO{#}++++++++++++++++++++++
		echo.
		if not "!su_installer_detect!"=="0" (
			set su_detect=0
			TOOLS\bin\cecho --ROOT STATUS: [{0A}YES{#}] [INSTALLER] [4]
			echo.
		)
		if not "!su_detect!"=="0" if exist "WORK\system\xbin\daemonsu" if not exist "WORK\system\app\supersu*" if not exist "WORK\system\app\superuser*" (
			TOOLS\bin\cecho --ROOT STATUS: [{0A}YES{#}] [FAST MODE] [4]
			echo.
		)
		if not "!su_detect!"=="0" if exist "WORK\system\xbin\daemonsu" if exist "WORK\system\app\supersu*" (
			TOOLS\bin\cecho --ROOT STATUS: [{0A}YES{#}] [CLASSIC MODE] [4]
			echo.
		)
		if not "!su_detect!"=="0" if exist "WORK\system\xbin\daemonsu" if exist "WORK\system\app\superuser*" (
			TOOLS\bin\cecho --ROOT STATUS: [{0A}YES{#}] [CLASSIC MODE] [4]
			echo.
		)
		if not "!su_detect!"=="0" if not exist "WORK\system\xbin\daemonsu" if not exist "WORK\system\app\supersu*" if not exist "WORK\system\app\superuser*" (
			TOOLS\bin\cecho --ROOT STATUS: [{0C}NO{#}] [4]
			echo.
		)
		if exist "WORK\system\xbin\busybox" ( 
			TOOLS\bin\cecho --BUSYBOX STATUS: [{0A}YES{#}] [5]
			echo.
		) else (
			TOOLS\bin\cecho --BUSYBOX STATUS: [{0C}NO{#}] [5]
			echo.
		)
		if exist "WORK\system\xbin\sqlite*" ( 
			TOOLS\bin\cecho --SQLITE STATUS: [{0A}YES{#}] [13]
			echo.
		) else (
			TOOLS\bin\cecho --SQLITE STATUS: [{0C}NO{#}] [13]
			echo.
		)
		if exist "WORK\system\bin\debuggerd.real" ( 
			TOOLS\bin\cecho --ROM INIT.D SUPPORT STATUS: [{0A}YES{#}] [9]
			echo.
		) else (
			TOOLS\bin\cecho --ROM INIT.D SUPPORT STATUS: [{0C}NO{#}] [9]
			echo.
		)
		if not exist "WORK\system\etc\secure_storage\com.sec.knox.seandroid" if not exist "WORK\system\etc\secure_storage\com.sec.knox.store" if not exist "WORK\system\container" if not exist "WORK\system\containers" if not exist "WORK\system\preloadedsso" if not exist "WORK\system\app\knoxagent*" if not exist "WORK\system\priv-app\knoxagent*" (
			set knoxstatus=yes
			TOOLS\bin\cecho --DEKNOXED STATUS: [{0A}YES{#}] [10]
			echo.
		)
		if "!knoxstatus!"=="null" (
			TOOLS\bin\cecho --DEKNOXED STATUS: [{0C}NO{#}] [10]
			echo.
		)
		if exist "TOOLS\tmp\debloated" (
			TOOLS\bin\cecho --DEBLOATED STATUS: [{0A}YES{#}] [11]
			echo.
		) else (
			TOOLS\bin\cecho --DEBLOATED STATUS: [{0C}NO{#}] [11]
			echo.
		)
		if exist "TOOLS\tmp\zipalign" ( 
			TOOLS\bin\cecho --ZIPALIGN STATUS: [{0A}YES{#}] [3]
			echo.
		) else (
			TOOLS\bin\cecho --ZIPALIGN STATUS: [{0C}NO{#}] [3]
			echo.
		)
		if exist "WORK\system\app\*.odex" for %%f in (WORK\system\app\*.odex) do if not exist "WORK\system\app\%%~nf.apk" del %%f
		if exist "WORK\system\priv-app\*.odex" for %%f in (WORK\system\priv-app\*.odex) do if not exist "WORK\system\priv-app\%%~nf.apk" del %%f
		if exist "WORK\system\framework\*.odex" for %%f in (WORK\system\framework\*.odex) do if not exist "WORK\system\framework\%%~nf.jar" del %%f
		if !api! leq 19 (
			if exist "WORK\system\framework\*.odex" (
				TOOLS\bin\cecho --DEODEX STATUS: [{0C}NO{#}] [2]
				echo.
			) else (
				TOOLS\bin\cecho --DEODEX STATUS: [{0A}YES{#}] [2]
				echo.
			)
		) else (
			for %%t in (arm arm64 mips mips64 x86 x86_64) do if exist "WORK\system\framework\%%t" set deodex=y
			if not "!deodex!"=="null" (
				if !api! geq 24 if not exist "WORK\system\framework\oat" (
					TOOLS\bin\cecho --DEODEX STATUS: [{0A}YES{#}] [2]
					echo.
				) else (
					TOOLS\bin\cecho --DEODEX STATUS: [{0C}NO{#}] [2]
					echo.
				)
				if !api! leq 23 (
					TOOLS\bin\cecho --DEODEX STATUS: [{0C}NO{#}] [2]
					echo.
				)
			)
			if "!deodex!"=="null" (
				TOOLS\bin\cecho --DEODEX STATUS: [{0A}YES{#}] [2]
				echo.
			)
		)
		if exist "WORK\system\xbin\sysrw" (
			TOOLS\bin\cecho --SYSTEM ADB MOUNT-REMOUNT STATUS: [{0A}YES{#}] [14]
			echo.
		) else (
			TOOLS\bin\cecho --SYSTEM ADB MOUNT-REMOUNT STATUS: [{0C}NO{#}] [14]
			echo.
		)
		set bootanimation=y
		if not exist "WORK\system\bin\bootanimation.bak" if not exist "WORK\system\media\bootanimation*.zip" set bootanimation=n
		if "!bootanimation!"=="y" (
			TOOLS\bin\cecho --CUSTOM BOOTANIMATION STATUS: [{0e}YES{#}] [20]
			echo.
		) else (
			TOOLS\bin\cecho --CUSTOM BOOTANIMATION STATUS: [{0e}NO{#}] [20]
			echo.
		)
		if exist "WORK\system\su.d" (
			TOOLS\bin\cecho --SU.D SUPPORT STATUS: [{0A}YES{#}] [31]
			echo.
		) else (
			TOOLS\bin\cecho --SU.D SUPPORT STATUS: [{0C}NO{#}] [31]
			echo.
		)
		if exist "!updater_script!" (
			TOOLS\bin\cecho ++++++++++++++++{0e}INSTALLER INFO{#}+++++++++++++++++
			echo.
			if exist !aroma_config! echo --INSTALLER MODEL: [AROMA INSTALLING]
			if exist !updater_script! if not exist !aroma_config! echo --INSTALLER MODEL: [STANDALONE INSTALLING]
			if "!factory!"=="samsung" if "!installerefs!"=="0" (
				TOOLS\bin\cecho --INSTALLER BACKUP EFS: [{0C}NO{#}] [21]
				echo.
			) else (
				TOOLS\bin\cecho --INSTALLER BACKUP EFS: [{0A}YES{#}] [21]
				echo.
			)
			if "!installerwipe!"=="0" (
				TOOLS\bin\cecho --INSTALLER WIPE DATA: [{0C}NO{#}] [15]
				echo.
			) else (
				TOOLS\bin\cecho --INSTALLER WIPE DATA: [{0A}YES{#}] [15]
				echo.
			)
			if "!installertun2fs!"=="0" (
				TOOLS\bin\cecho --INSTALLER EXT4 SCRIPTS: [{0C}NO{#}] [19]
				echo.
			) else (
				TOOLS\bin\cecho --INSTALLER EXT4 SCRIPTS: [{0A}YES{#}] [19]
				echo.
			)
		)
		set devicemodel=!devicemodel: =+!
		TOOLS\bin\cecho +++++++++++++++{0e}PROJECT STATUS{#}++++++++++++++++++
		echo.
		if exist "WORK\boot_unpacked" (
			set status=n
			TOOLS\bin\cecho {0c}WARNING: FOUND KERNEL UNPACKED{#} [12 TO FIX]
			echo.
		)
		if exist "WORK\boot_packed" (
			set status=n
			TOOLS\bin\cecho {0c}WARNING: FOUND KERNEL REPACKED IN [boot_packed] FOLDER{#} [12 TO FIX]
			echo.
		)
		if exist "WORK\recovery_unpacked" (
			set status=n
			TOOLS\bin\cecho {0c}WARNING: FOUND RECOVERY UNPACKED{#} [12 TO FIX]
			echo.
		)
		if exist "WORK\recovery_packed" (
			set status=n
			TOOLS\bin\cecho {0c}WARNING: FOUND RECOVERY REPACKED IN [recovery_packed] FOLDER{#} [12 TO FIX]
			echo.
		)
		if not exist "WORK\META-INF" (
			set status=n
			TOOLS\bin\cecho {0c}WARNING: NO META-INF FOUND [NO ROM INSTALLER]{#} [6 TO FIX]
			echo.
		)
		if not exist "WORK\boot.img" if not exist "WORK\kernel.sin.bak" (
			set status=n
			TOOLS\bin\cecho {0c}WARNING: NO KERNEL FOUND IN WORK FOLDER{#} [01 TO FIX]
			echo.
		)
		if "!status!"=="y" (
			TOOLS\bin\cecho {0a}****************** STABLE *********************{#}
			echo.
		)
	)
:commands
	if not exist "WORK\system\build.prop" (
		echo ==================================================================================
		TOOLS\bin\cecho                               {0c}NO PROJECTS FOUND{#}
		echo.
		echo ==================================================================================
	)
	echo +++++++++++++++++++++++++++++++++++++++++++++++
	if not exist "WORK\system\build.prop" echo   1  START CREATING PROJECT
	if exist "WORK\system\build.prop" if not exist "TOOLS\tmp\project_name" (
		echo   1  START CREATING PROJECT
	) else (
		TOOLS\bin\cecho   1  NEW PROJECT [CURRENT: {0A}!project_name!{#}]
		echo.
	)
	echo   2  DEODEXING PROJECT
	echo   3  ZIPALIGN PROJECT
	if not "!su_installer_detect!"=="0" echo   4  REMOVING THE ROOT
	if "!su_installer_detect!"=="0" if exist "WORK\system\xbin\daemonsu" ( echo   4  REMOVING THE ROOT ) else ( echo   4  INSTALLING THE ROOT )
	if exist "WORK\system\xbin\busybox" ( echo   5  REMOVING BUSYBOX ) else ( echo   5  INSTALLING BUSYBOX )
	if exist "TOOLS\tmp\original_installer" ( echo   6  RESTORING ORIGINAL INSTALLER ) else ( echo   6  BUILDING NEW INSTALLER )
	echo   7  BUILD ROM FOR FLASHING
	if "!tweaks_test!"=="0" ( echo   8  ADD BUILD.PROP TWEAKS ) else ( echo   8  REMOVE BUILD.PROP TWEAKS )
	if exist "WORK\system\bin\debuggerd.real"  ( echo   9  REMOVE INIT.D SUPPORT ) else ( echo   9  ADD INIT.D SUPPORT )
	if exist "WORK\KNOX" ( echo  10  RESTORING KNOX FILES ) ELSE ( echo  10  DEKNOXING THE ROM )
	if exist "WORK\bloat" ( echo  11  RESTORING BLOATWARE ) else ( echo  11  DEBLOATING THE ROM )
	echo  12  KERNEL/RECOVERY MENU
	if exist "WORK\system\xbin\sqlite3" ( echo  13  REMOVE SQLITE SCRIPT ) else ( echo  13  INSTALL SQLITE SCRIPT )
	if exist "WORK\system\xbin\sysrw" ( echo  14  REMOVE SYSRO-SYSRW ) else ( echo  14  INSTALL SYSRO-SYSRW )
	if "!installerwipe!"=="0"  ( echo  15  INSTALLER WIPE DATA ) else ( echo  15  INSTALLER NOT WIPE DATA )
	echo  16  SAVE/REMOVE PROJECT
	echo  17  OPENNING WORK FOLDER
	echo  18  FORCE BUILD FLASH ROM
	if exist "WORK\META-INF\SCRIPTS\ext4.sh" ( echo  19  REMOVE EXT4-TUNE2FS ) else ( echo  19  ADDING EXT4-TUNE2FS )
	if exist "WORK\system\bin\bootanimation.bak" ( echo  20  RESTORE ORIGINAL BOOTANIMATION ) else ( echo  20  ADD CUSTOM BOOTANIMATION )
	if exist "WORK\META-INF\SCRIPTS\efs_backup.sh" ( echo  21  REMOVE EFS BACKEUP ) else ( echo  21  ADDING EFS BACKEUP )
	echo  22  INIT.D TWEAKS MENU
	echo  23  RESTORE/DELETE SAVED PROJECTS
	set remove_cleaned=n
	if exist "WORK\bloat" set remove_cleaned=y
	if exist "WORK\knox" set remove_cleaned=y
	if "!remove_cleaned!"=="y" echo  24  REMOVING BLOTWARE/KNOX FOLDER
	if exist "TOOLS\tmp\changed_build_number" ( echo  25  RESTORE ORIGINAL BUILD STRING ) else ( echo  25  CHANGE BUILD NUMBER STRING )
	if exist "WORK\system\build.prop" echo  26  OPENNING BUILD.PROP
	if exist !updater_script! echo  27  OPENNING UPDATER-SCRIPT
	if exist !aroma_config! echo  28  OPENNING AROMA-CONFIG
	echo  29  PUSH READY ROMS TO PHONE
	echo  30  IMAGES EDITOR MENU
	if exist "WORK\system\su.d" ( echo  31  REMOVE SU.D SUPPORT ) else ( echo  31  ADD SU.D SUPPORT )
	echo  32  ADD ZIP TO ROM INSTALLER
	if exist "WORK\system\build.prop" if not exist "WORK\boot.img" if not exist "WORK\kernel.sin.bak" echo  01  SEARCH FOR BOOT.IMG IN PROJECT
	echo +++++++++++++++++++++++++++++++++++++++++++++++
	set select=m
	set /p select=TYPE WHAT YOU WANT OR [APKTOOL] OR [0=EXIT]:
	set select=!select:"=!
	if "!select!"=="1" goto prepare
	if "!select!"=="2" goto deodex
	if "!select!"=="3" goto zipalign
	if "!select!"=="4" goto root
	if "!select!"=="5" goto busybox
	if "!select!"=="6" goto prepare_installing
	if "!select!"=="7" (
		set skipwarn=n
		goto prepare_installing
	)
	if "!select!"=="8" goto instweaks
	if "!select!"=="9" goto init.d
	if "!select!"=="10" goto knox
	if "!select!"=="11" goto bloat
	if "!select!"=="12" goto kernel_recovery_menu
	if "!select!"=="13" goto sqlite
	if "!select!"=="14" goto sysrorw
	if "!select!"=="15" goto wipedata
	if "!select!"=="16" goto editproject
	if "!select!"=="17" goto openwork
	if "!select!"=="18" (
		set status=y
		set skipwarn=y
		goto prepare_installing
	)
	if "!select!"=="19" goto ext4-tune2fs
	if "!select!"=="20" goto custom_animation
	if "!select!"=="21" goto efsinstaller
	if "!select!"=="22" goto initdmenu
	if "!select!"=="23" goto worksavedprojects
	if "!remove_cleaned!"=="y" if "!select!"=="24" goto removecleaned
	if "!select!"=="25" goto change_prop_info
	if exist "WORK\system\build.prop" if "!select!"=="26" goto build.prop
	if exist !updater_script! if "!select!"=="27" goto openupdater
	if exist !aroma_config! if "!select!"=="28" goto openaroma
	if "!select!"=="29" goto pushfiles
	if "!select!"=="30" goto images_menu
	if "!select!"=="31" goto su_d_support
	if "!select!"=="32" goto addon_zip
	if exist "WORK\system\build.prop" if not exist "WORK\boot.img" if not exist "WORK\kernel.sin.bak" if "!select!"=="01" goto grepboot
	if "!select!"=="Apktool" goto papktool
	if "!select!"=="apktool" goto papktool
	if "!select!"=="APKTOOL" goto papktool
	if "!select!"=="0" goto exiting
	set select=m
	goto start
:kernel_recovery_menu
	cls
	set img_file=boot.img
	if exist "work\kernel.sin.bak" set img_file=kernel.sin.bak
	set img_dir=boot_unpacked
	set img_dir2=boot_packed
	set kerneladb=null
	set kernelsecure=null
	set kerneldebug=null
	set dm_verity=null
	set force_encypt_allow=y
	set force_encypt=null
	set kernelinitd=null
	if not exist "WORK\boot_unpacked\ramdisk\default.prop" (
		echo ==================================================================================
		TOOLS\bin\cecho                              {0c}NO KERNEL UNPACKED FOUND{#}
		echo.
		echo ==================================================================================
	)
	if exist "WORK\boot_unpacked\ramdisk\default.prop" (
		for /f "delims=" %%a in ('TOOLS\bin\find WORK/!img_dir! -not -type l -name *fstab* ^| !busybox! grep -v charger ^| !busybox! grep -v goldfish ^| !busybox! grep -v ranchu ^| !busybox! grep -m 1 fstab') do (
			for /f "delims=" %%b in ('!busybox! grep -cw "verify" "%%a"') do if not "%%b"=="0" set dm_verity=y
			for /f "delims=" %%b in ('!busybox! grep "/data" %%a ^| !busybox! grep -cw "forceencrypt"') do set force_encypt1=%%b
			for /f "delims=" %%b in ('!busybox! grep "/data" %%a ^| !busybox! grep -cw "forcefdeorfbe"') do set force_encypt2=%%b
			for /f "delims=" %%b in ('!busybox! grep "/data" %%a ^| !busybox! grep -cw "encryptable"') do set force_encypt3=%%b
			if "!force_encypt1!"=="0" if "!force_encypt2!"=="0" if "!force_encypt3!"=="0" set force_encypt_allow=n
			if "!force_encypt_allow!"=="y" for /f "delims=" %%b in ('!busybox! grep "/data" %%a ^| !busybox! grep -cw "forceencrypt"') do if not "%%b"=="0" set force_encypt=y
			if "!force_encypt_allow!"=="y" if not "!force_encypt!"=="y" for /f "delims=" %%b in ('!busybox! grep "/data" %%a ^| !busybox! grep -cw "forcefdeorfbe"') do if not "%%b"=="0" set force_encypt=y
		)
		for /f "delims=" %%a in ('!busybox! grep -c "kernel-init.sh" "WORK/boot_unpacked/ramdisk/init.rc"') do if not "%%a"=="0" set kernelinitd=y
		if "!kernelinitd!"=="y" if exist "WORK\system\etc\init.d" if not exist "WORK\system\etc\init.d\placeholder" !busybox! touch WORK/system/etc/init.d/placeholder
		for /f "delims=" %%a in ('!busybox! grep -i "ro.secure=" "WORK/boot_unpacked/ramdisk/default.prop" ^| !busybox! cut -d"=" -f2') do set kernelsecure=%%a
		for /f "delims=" %%a in ('!busybox! grep -i "ro.debuggable=" "WORK/boot_unpacked/ramdisk/default.prop" ^| !busybox! cut -d"=" -f2') do set kerneldebug=%%a
		if "!kerneldebug!"=="1" if "!kernelsecure!"=="0" set kerneladb=y
		TOOLS\bin\cecho ++++++++++++++++{0e}KERNEL INFO{#}++++++++++++++++++++
		echo.
		if "!kerneladb!"=="null" (
			TOOLS\bin\cecho --KERNEL ADB STATUS: [{0C}DISABLED{#}] [6]
			echo.
		) else (
			TOOLS\bin\cecho --KERNEL ADB STATUS: [{0A}ENABLED{#}] [6]
			echo.
		)
		if "!kernelinitd!"=="y" (
			TOOLS\bin\cecho --KERNEL INIT.D SUPPORT STATUS: [{0A}YES{#}] [7]
			echo.
		) else (
			TOOLS\bin\cecho --KERNEL INIT.D SUPPORT STATUS: [{0C}NO{#}] [7]
			echo.
		)
		if "!dm_verity!"=="y" (
			TOOLS\bin\cecho --KERNEL DM-VERITY STATUS: [{0C}YES{#}] [9]
			echo.
		) else (
			TOOLS\bin\cecho --KERNEL DM-VERITY STATUS: [{0A}NO{#}] [9]
			echo.
		)
		if "!force_encypt_allow!"=="n" (
			TOOLS\bin\cecho --KERNEL FORCE-ENCRYPT STATUS: [{0E}DOESN'T SUPPORTED{#}] [10]
			echo.
		)
		if "!force_encypt_allow!"=="y" if "!force_encypt!"=="y" (
			TOOLS\bin\cecho --KERNEL FORCE-ENCRYPT STATUS: [{0C}YES{#}] [10]
			echo.
		) else (
			TOOLS\bin\cecho --KERNEL FORCE-ENCRYPT STATUS: [{0A}NO{#}] [10]
			echo.
		)
		if exist "TOOLS\tmp\adbd.bak" (
			TOOLS\bin\cecho --KERNEL ADBD ROOT DIRECT STATUS: [{0A}ENABLED{#}] [8]
			echo.
		) else (
			TOOLS\bin\cecho --KERNEL ADBD ROOT DIRECT STATUS: [{0C}NOT ENABLED BY THIS KITCHEN{#}] [8]
			echo.
		)
		if exist "TOOLS\tmp\sepolicy_original" (
			TOOLS\bin\cecho --KERNEL SEPOLICY PATCH STATUS: [{0A}YES{#}] [11]
			echo.
		) else (
			TOOLS\bin\cecho --KERNEL KERNEL SEPOLICY PATCH STATUS: [{0C}NOT PATCHED BY THIS KITCHEN{#}] [11]
			echo.
		)
	)
	echo +++++++++++++++++++++++++++++++++++++++++++++++
	if exist "WORK\boot_unpacked" ( echo   1  REMOVE UNPACKED KERNEL ) else ( echo   1  UNPACKING THE KERNEL )
	if exist "WORK\boot_packed" ( echo   2  REMOVE PACKED KERNEL ) else ( echo   2  PACKING THE KERNEL )
	if exist "WORK\recovery_unpacked" ( echo   3  REMOVE UNPACKED RECOVERY ) else ( echo   3  UNPACK THE RECOVERY )
	if exist "WORK\recovery_packed" ( echo   4  REMOVE PACKED RECOVERY ) else ( echo   4  PACKING THE RECOVERY ) 
	echo   5  REMOVE [KERNEL/RECOVERY IS NOT SEANDROID ENFORCING] ON BOOT
	if exist "WORK\boot_unpacked\ramdisk\default.prop" (
		if "!kerneladb!"=="y" ( echo   6  DISABLE ADB IN KERNEL ) else ( echo   6  ENABLE ADB IN KERNEL )
		if "!kernelinitd!"=="y" ( echo   7  KERNEL INIT.D UNSUPPORT ) else ( echo   7  KERNEL INIT.D SUPPORT )
		if exist "TOOLS\tmp\adbd.bak" ( echo   8  RESTORE ORIGINAL ADBD IN KERNEL ) else ( echo   8  INSTALL ADBD ROOT DIRECT )
		echo   9  REMOVING DM-VERITY FROM KERNEL
		if "!force_encypt!"=="y" ( echo  10  REMOVE FORCE-ENCRYPT FROM KERNEL ) else ( echo  10  ADD FORCE-ENCRYPT TO KERNEL )
		if exist "TOOLS\tmp\sepolicy_original" ( echo  11  UNPATCHING SEPOLICY ) else ( echo  11  PATCHING SEPOLICY )
	)
	echo  00  CONVERT [kernel.elf] TO [boot.img]
	echo   0  BACK TO THE KITCHEN
	echo +++++++++++++++++++++++++++++++++++++++++++++++
	set select2=m
	set /p select2=TYPE WHAT YOU WANT:
	set select2=!select2:"=!
	if "!select2!"=="1" goto kernelunpack
	if "!select2!"=="2" goto kernelpack
	if "!select2!"=="3" (
		set img_file=recovery.img
		set img_dir=recovery_unpacked
		set img_dir2=recovery_packed
		goto kernelunpack
	)
	if "!select2!"=="4" (
		set img_file=recovery.img
		set img_dir=recovery_unpacked
		set img_dir2=recovery_packed
		goto kernelpack
	)
	if "!select2!"=="5" goto kernel_fix_seandroid
	if "!select2!"=="00" goto elf_2_img
	if exist "WORK\boot_unpacked\ramdisk\default.prop" (
		if "!select2!"=="6" goto enablekernelfea
		if "!select2!"=="7" goto kernelinitd
		if "!select2!"=="8" goto adbd_root
		if "!select2!"=="9" goto kernel_verity
		if "!select2!"=="10" goto kernel_encrypt
		if "!select2!"=="11" (
			if exist "TOOLS\tmp\sepolicy_original" (
				echo RESTORING ORIGINAL UNPATCHED [sepolicy]
				del WORK\boot_unpacked\ramdisk\sepolicy
				move TOOLS\tmp\sepolicy_original WORK\boot_unpacked\ramdisk\sepolicy >nul
				goto kernel_recovery_menu
			)
			echo THIS FEATURE NEEDS AN ANDROID PHONE RUNNING ANDROID
			echo KITKAT+ AND MUST BE ROOTED AND BOOTED TO ANDROID
			set /p wait=PRESS ENTER IF YOU READY
			call :patch_sepolicy null
		)
	)
	if "!select2!"=="0" goto start
	set select2=m
	goto kernel_recovery_menu
:prepare
	if not exist "TOOLS\tmp" mkdir TOOLS\tmp
	if not exist "WORK" mkdir WORK
	rmdir WORK
	if exist "WORK"	(
		set rmproject=y
		call :editproject
	)
	if not exist "WORK" mkdir WORK
	set pullrom=
	set /p pullrom=FROM WHERE YOU WANT TO GET ROM [DEFAULT=PLACE_FOLDER 0=BACK 1=FROM_DEVICE]:
	if "!pullrom!"=="1" goto pullrom
	if "!pullrom!"=="0" goto start
	if not exist "PLACE\*.sin" if not exist "PLACE\*.ftf" if not exist "PLACE\*.img" if not exist "PLACE\*.ext4" if not exist "PLACE\*.zip" if not exist "PLACE\*.tar" if not exist "PLACE\*.md5" (
		ECHO THERE IS NO ANY ROMS SUPPORTED IN PLACE FOLDER
		ECHO THE KITCHEN SUPPORT THESE TYPES OF ROMS:
		ECHO 1-- EXT4: SYSTEM.IMG - BOOT.IMG
		ECHO 2-- SIN: SYSTEM.SIN - KERNEL.SIN/ELF - OEM.SIN
		ECHO 3-- TAR.MD5: STOCK SAMSUNG UPDATES [tar] OR [md5]
		ECHO 4-- FTF: STOCK SONY UPDATES
		ECHO 5-- ZIP: CUSTOM COOKED ROM
		ECHO 6-- ZIP: CONTENT [system.img]
		ECHO 7-- ZIP: CONTENT SAPRSE CHUNKS [Motorola]
		ECHO 8-- SYSTEM.EXT4 DUMPED FROM SYSTEM.SIN BY FLASHTOOL WITH [kernel.elf, oem.sin]
		ECHO 9-- SYSTEM.YAFFS2 WITH [kernel.sin/elf]/[boot.img]
		ECHO PRESS ANY KEY TO BACK
		pause>nul
		goto start
	)
:choose
	ren place\system.ext4 system.img.ext4
	for %%f in (PLACE\*.img) do if not "%%~nf%%~xf"=="boot.img" ren %%f %%~nf%%~xf.ext4
	for %%f in (PLACE\*.md5) do ren "%%f" "%%~nf"
	cls
	set ext=null
	echo.
	echo --------------------------------------------------------------
	set count=0
	for %%f in (PLACE/*) do (
		set ext=%%~xf
		if "!ext!"==".yaffs2" (
			set /a count=!count!+1
			if !count! leq 9 ( echo   !count! == STOCK YAFFS2 ROM [%%f] ) else ( echo  !count! == STOCK YAFFS2 ROM [%%f] )
		)
		if "!ext!"==".zip" (
			set /a count=!count!+1
			if !count! leq 9 ( echo   !count! == %%f ) else ( echo  !count! == %%f )
		)
		if "!ext!"==".tar" (
			set /a count=!count!+1
			if !count! leq 9 ( echo   !count! == %%f ) else ( echo  !count! == %%f )
		)
		if "!ext!"==".ftf" (
			set /a count=!count!+1
			if !count! leq 9 ( echo   !count! == %%f ) else ( echo  !count! == %%f )
		)
		if "%%f"=="system.img.ext4" (
			set /a count=!count!+1
			if !count! geq 10 ( echo  !count! == STOCK IMG ROM [%%f] ) else ( echo   !count! == STOCK IMG ROM [%%f] )
		)
		if "%%f"=="system.sin" (
			set /a count=!count!+1
			if !count! geq 10 ( echo  !count! == STOCK SIN ROM [%%f] ) else ( echo   !count! == STOCK SIN ROM [%%f] )
		)
	)
	echo --------------------------------------------------------------
	echo.
	set romnumber=rr
	set /p romnumber=SELECT WHAT ROM YOU WANT [ENTER=REFRESH 0=BACK]:
	set romnumber=!romnumber: =x!
	if "!romnumber!"=="0" goto start
	set count=0
	set romtmp=null
	set rom=null
	set kind=null
	for %%f in (PLACE/*) do (
		set ext=%%~xf
		if "!ext!"==".yaffs2" (
			set /a count=!count!+1
			if "!count!"=="!romnumber!" (
				set romtmp=%%f
				set kind=%%~xf
			)
		)
		if "!ext!"==".zip" (
			set /a count=!count!+1
			if "!count!"=="!romnumber!" (
				set romtmp=%%f
				set kind=%%~xf
			)
		)
		if "!ext!"==".tar" (
			set /a count=!count!+1
			if "!count!"=="!romnumber!" (
				set romtmp=%%f
				set kind=%%~xf
			)
		)
		if "!ext!"==".ftf" (
			set /a count=!count!+1
			if "!count!"=="!romnumber!" (
				set romtmp=%%f
				set kind=%%~xf
			)
		)
		if "%%f"=="system.img.ext4" (
			set /a count=!count!+1
			if "!count!"=="!romnumber!" (
				set romtmp=%%f
				set kind=%%~xf
			)
		)	
		if "%%f"=="system.sin" (
			set /a count=!count!+1
			if "!count!"=="!romnumber!" (
				set romtmp=%%f
				set kind=%%~xf
			)
		)
	)
	if not "!kind!"==".yaffs2" if not "!kind!"==".ftf" if not "!kind!"==".sin" if not "!kind!"=="null" if not "!kind!"==".zip" if not "!kind!"==".ext4" if not "!kind!"==".tar" (
		echo SORRY BUT [!romtmp!] KIND UNSOPPORTED
		pause>nul
		goto choose
	)
	if "!romtmp!"=="null" goto choose
	set rom1=!romtmp: =_!
	set rom2=!rom1:(=[!
	set rom=!rom2:)=]!
	echo BEFORE START CREATE THE PROJECT PLEASE ENTER ITS NAME
	echo THIS NAME WILL NOT USE FOR ANY THING JUST INFO IN THE
	echo MAIN KITCHEN MENU SO YOU CAN KNOW WHAT YOU ARE WORKING ON
	echo NOTE: SPACES WILL REPLACED WITH [_]
	set ask=n
	set /p ask=TYPE THE NAME [ENTER=SKIP]:
	set ask=!ask:"=!
	set ask=!ask: =_!
	set ask=!ask:(=[!
	set ask=!ask:)=]!
	if not "!ask!"=="n" echo !ask!>>TOOLS\tmp\project_name
	if not "!romtmp!"=="!rom!" echo RENAMING SELECTED [!romtmp!] TO [!rom!]
	if not "!romtmp!"=="!rom!" ren "PLACE\!romtmp!" "!rom!"
	if "!kind!"==".ftf" (
		if not exist "WORK" mkdir WORK
		if not exist "WORK\tmp" mkdir WORK\tmp
		echo EXTRACTING [!rom!].....
		TOOLS\bin\7za x -y "PLACE\!rom!" -o"WORK\tmp">nul
		if exist "WORK\tmp\boot.img" (
			echo COPYING [boot.img]
			copy WORK\tmp\boot.img WORK\boot.img>nul
		)
		if exist "WORK\tmp\kernel.sin" if not exist "WORK\tmp\boot.img" (
			echo COPYING [kernel.sin]
			copy WORK\tmp\kernel.sin WORK\kernel.sin>nul
		)
		if exist "WORK\tmp\boot.sin" if not exist "WORK\kernel.sin" if not exist "WORK\boot.img" (
			echo COPYING [boot.sin]
			copy WORK\tmp\boot.sin WORK\kernel.sin>nul
		)
		move WORK\tmp\system.sin WORK\system.sin >nul
		cls
		echo.
		echo.
		echo NOW YOU HAVE [system.sin, kernel.sin] IN WORK FOLDER
		echo OPEN SONY FLASHTOOL AND PRESS ON [Tools] TAB THEN PRESS
		echo [Sin Editor] AND CHOOSE [WORK\system.sin] THEN PRESS ON
		echo [Extract data] AND WAIT TO FINISH THEN DO THE SAME FOR [kernel.sin]
		echo AFTER FINISH RENAME THE OUTPUT OF THE [system.sin] TO [system.ext4]
		echo IF IT HAVE OTHER NAME
		set /p wait=CLOSE FLASHTOOL AND PRESS ENTER WHEN YOU READY
		if not exist "WORK\system.ext4" (
			TOOLS\bin\cecho {0C}ERROR: NO [WORK\system.ext4] FOUND CAN'T CONTINUE{#}
			echo.
			!busybox! rm -rf WORK
			mkdir WORK
			pause>nul
			goto start
		)
		if not exist "WORK\kernel.elf" (
			TOOLS\bin\cecho {0C}ERROR: NO [WORK\kernel.elf] FOUND CAN'T CONTINUE{#}
			echo.
			!busybox! rm -rf WORK
			mkdir WORK
			pause>nul
			goto start
		)
		!busybox! rm -rf WORK/tmp WORK/system.sin WORK/kernel.sin
		ren WORK\system.ext4 system.img
		call :img_extract
		if not exist "WORK\system\build.prop" if not exist "WORK\system\framework" if not exist "WORK\system\lib" if not exist "WORK\system\bin" (
			echo SORRY BUT AN ERROR HAPPENED CAN'T CONTINUE
			pause>nul
			rmdir /s /q WORK
			mkdir WORK
			goto start
		)
		echo CONVERTING [kernel.elf] TO [boot.img]
		mkdir WORK\elf_convert
		copy WORK\kernel.elf WORK\elf_convert\kernel.elf >nul
		call :convert_elf2img WORK
		move WORK\elf_convert\boot.img WORK\boot.img >nul
		if not exist "WORK\boot.img" (
			TOOLS\bin\cecho {0C}ERROR: FAILED IN CONVERTING{#}
			echo.
		)
		!busybox! rm -rf WORK/elf_convert
		echo CLEANING UP WORK FOLDER
		for /f %%a in ('dir WORK\ /b') do if not "%%a"=="boot.img" if not "%%a"=="system" if not "%%a"=="supersu" !busybox! rm -rf WORK/%%a
		goto prepare_installing
	)
	if "!kind!"==".zip" (
		if not exist "WORK" mkdir WORK
		echo EXTRACTING [!rom!].....
		TOOLS\bin\7za x -y "PLACE\!rom!" -o"WORK">nul
		if exist "WORK\*.ftf" (
			mkdir WORK\tmp
			for %%e in (WORK\*.ftf) do (
				echo EXTRACTING [%%~ne%%~xe].....
				TOOLS\bin\7za x -y "%%e" -o"WORK\tmp" >nul
			)
			if exist "WORK\tmp\boot.img" (
				echo COPYING [boot.img]
				copy WORK\tmp\boot.img WORK\boot.img>nul
			)
			if exist "WORK\tmp\kernel.sin" if not exist "WORK\tmp\boot.img" (
				echo COPYING [kernel.sin]
				copy WORK\tmp\kernel.sin WORK\kernel.sin>nul
			)
			if exist "WORK\tmp\boot.sin" if not exist "WORK\kernel.sin" if not exist "WORK\boot.img" (
				echo COPYING [boot.sin]
				copy WORK\tmp\boot.sin WORK\kernel.sin>nul
			)
			move WORK\tmp\system.sin WORK\system.sin >nul
			cls
			echo.
			echo.
			echo NOW YOU HAVE [system.sin, kernel.sin] IN WORK FOLDER
			echo OPEN SONY FLASHTOOL AND PRESS ON [Tools] TAB THEN PRESS
			echo [Sin Editor] AND CHOOSE [WORK\system.sin] THEN PRESS ON
			echo [Extract data] AND WAIT TO FINISH THEN DO THE SAME FOR [kernel.sin]
			echo AFTER FINISH RENAME THE OUTPUT OF THE [system.sin] TO [system.ext4]
			echo IF IT HAVE OTHER NAME
			set /p wait=CLOSE FLASHTOOL AND PRESS ENTER WHEN YOU READY
			if not exist "WORK\system.ext4" (
				TOOLS\bin\cecho {0C}ERROR: NO [WORK\system.ext4] FOUND CAN'T CONTINUE{#}
				echo.
				!busybox! rm -rf WORK
				mkdir WORK
				pause>nul
				goto start
			)
			if not exist "WORK\kernel.elf" (
				TOOLS\bin\cecho {0C}ERROR: NO [WORK\kernel.elf] FOUND CAN'T CONTINUE{#}
				echo.
				!busybox! rm -rf WORK
				mkdir WORK
				pause>nul
				goto start
			)
			!busybox! rm -rf WORK/tmp WORK/system.sin WORK/kernel.sin
			ren WORK\system.ext4 system.img
			call :img_extract
			if not exist "WORK\system\build.prop" if not exist "WORK\system\framework" if not exist "WORK\system\lib" if not exist "WORK\system\bin" (
				echo SORRY BUT AN ERROR HAPPENED CAN'T CONTINUE
				pause>nul
				rmdir /s /q WORK
				mkdir WORK
				goto start
			)
			echo CONVERTING [kernel.elf] TO [boot.img]
			mkdir WORK\elf_convert
			copy WORK\kernel.elf WORK\elf_convert\kernel.elf >nul
			call :convert_elf2img WORK
			move WORK\elf_convert\boot.img WORK\boot.img >nul
			if not exist "WORK\boot.img" (
				TOOLS\bin\cecho {0C}ERROR: FAILED IN CONVERTING{#}
				echo.
			)
			!busybox! rm -rf WORK/elf_convert
			echo CLEANING UP WORK FOLDER
			for /f %%a in ('dir WORK\ /b') do if not "%%a"=="boot.img" if not "%%a"=="system" if not "%%a"=="supersu" !busybox! rm -rf WORK/%%a
			goto prepare_installing
		)
		if exist "WORK\*.tar.md5" for %%a in (WORK\*.tar.md5) do ren %%a %%~na >nul
		if exist "WORK\*.tar" (
			for %%e in (WORK\*.tar) do (
				echo EXTRACTING [%%~ne%%~xe].....
				TOOLS\bin\7za x -y "%%e" -o"WORK\tmp" >nul
			)
			ren WORK\tmp\system.img system.img.ext4
			ren WORK\tmp\cache.img cache.img.ext4
			ren WORK\tmp\hidden.img hidden.img.ext4
			if exist "WORK\tmp\boot.img" (
				echo COPYING [boot.img]
				copy WORK\tmp\boot.img WORK\boot.img >nul
			)
			for /f "delims=" %%a in ('tools\bin\imgextractor work\tmp\system.img.ext4 -s ^| !busybox! grep -cw "SPARSE EXT4"') do if "%%a"=="1" (
				echo CONVERTING SPARSE [system.img.ext4] TO RAW [system.img].....
				TOOLS\bin\simg2img WORK\tmp\system.img.ext4 WORK\system.img>nul
				call :img_extract
			) else (
				echo COPYING RAW [system.img.ext4] TO WORK FOLDER
				copy work\tmp\system.img.ext4 work\system.img >nul
				call :img_extract
			)
			if exist "work\tmp\cache.img.ext4" (
				echo EXTRACTING FILES FROM [cache.img.ext4]
				TOOLS\bin\imgextractor work\tmp\cache.img.ext4 WORK\cache>nul
			)
			if exist "work\tmp\hidden.img.ext4" (
				echo EXTRACTING FILES FROM [hidden.img.ext4]
				TOOLS\bin\imgextractor work\tmp\hidden.img.ext4 WORK\hidden>nul
			)
			if exist "WORK\tmp" rmdir /s /q WORK\tmp
			if exist "WORK\hidden\symlink\system\app" call :move_symlinked_apps
			if exist "WORK\cache\recovery\sec*.zip" for %%f in (WORK\cache\recovery\sec*.zip) do (
				echo EXTRACTING FILES FROM [%%~nf%%~xf]
				TOOLS\bin\7za x -y "WORK\cache\recovery\%%~nf%%~xf" -o"WORK\tmp">nul
				echo COPYING CSC FILES
				xcopy WORK\tmp\system WORK\system /e /i /h /y>nul
			)
			echo CLEANING UP WORK FOLDER
			for /f %%a in ('dir WORK\ /b') do if not "%%a"=="boot.img" if not "%%a"=="system" if not "%%a"=="supersu" !busybox! rm -rf WORK/%%a
			goto prepare_installing
		)
		if exist "WORK\system.new.dat" if exist "WORK\system.transfer.list" (
			echo FOUND [system.transfer.list] [system.new.dat] CONVERTING TO [system.img]
			TOOLS\bin\sdat2img WORK\system.transfer.list WORK\system.new.dat WORK\system.img>nul
		)
		if exist "WORK\*chunk*" (
			echo FOUND [sparse_chunks] CONVERTING TO [system.img]
			TOOLS\bin\simg2img WORK/*chunk* WORK/system.img >nul
		)
		if exist "WORK\system.img" (
			for /f "delims=" %%a in ('TOOLS\bin\imgextractor WORK\system.img -s ^| !busybox! grep -cw "Found MOTO signature"') do if not "%%a"=="0" (
				echo REMOVING MOTOROLA HEADER SIGNATURE FROM [system.img]
				!busybox! dd if=WORK/system.img of=WORK/new.img ibs=131072 skip=1
				del WORK\system.img
				ren WORK\new.img system.img
			)
			for /f "delims=" %%a in ('tools\bin\imgextractor WORK\system.img -s ^| !busybox! grep -cw "SPARSE EXT4"') do if "%%a"=="1" (
				echo CONVERTING SPARSE [system.img] TO RAW [system.img].....
				TOOLS\bin\simg2img WORK\system.img WORK\system_ext4.img>nul
				del WORK\system.img
				ren WORK\system_ext4.img system.img
			)
			echo 1>WORK\need_clean
			rmdir /s /q WORK\system
			call :img_extract
		)
		if exist "WORK\kernel.sin" (
			echo CONVERTING [kernel.sin] TO [boot.img]
			set img_dir=converting_sin
			set img_file=kernel.sin
			call :kernelunpack3
			set img_dir=boot_unpacked
			set img_file=boot.img
		)
		if exist "WORK\cache.img" (
			echo EXTRACTING FILES FROM [cache.img]
			tools\bin\imgextractor WORK\cache.img work\cache >nul
			if exist "WORK\cache\recovery\sec*.zip" for %%f in (WORK\cache\recovery\sec*.zip) do (
				echo EXTRACTING FILES FROM [%%~nf%%~xf]
				TOOLS\bin\7za x -y "WORK\cache\recovery\%%~nf%%~xf" -o"WORK\tmp">nul
				echo COPYING CSC FILES
				xcopy WORK\tmp\system WORK\system /e /i /h /y>nul
			)
		)
		if exist "WORK\need_clean" (
			echo CLEANING UP WORK FOLDER
			for /f %%a in ('dir WORK\ /b') do if not "%%a"=="boot.img" if not "%%a"=="system" if not "%%a"=="supersu" !busybox! rm -rf WORK/%%a
		)
		if not exist "WORK\META-INF" goto prepare_installing
		goto completed
	)
	if "!kind!"==".sin" (
		set bootwar=b
		if not exist "PLACE\boot.img" if not exist "PLACE\boot.sin" if not exist "PLACE\kernel.sin" if not exist "PLACE\kernel.elf" set /p bootwar=FOUND SIN ROM WITHOUT KERNEL CONTINUE OR BACK [DEFAULT=YES 0=BACK]:
		if "!bootwar!"=="0" goto choose
		if not exist "WORK" mkdir WORK
		call :pick_kernel
		move PLACE\system.sin WORK\system.sin >nul
		if exist "WORK\system.sin" if exist "WORK\kernel.sin" (
			cls
			echo.
			echo.
			echo NOW YOU HAVE [system.sin, kernel.sin] IN WORK FOLDER
			echo OPEN SONY FLASHTOOL AND PRESS ON [Tools] TAB THEN PRESS
			echo [Sin Editor] AND CHOOSE [WORK\system.sin] THEN PRESS ON
			echo [Extract data] AND WAIT TO FINISH THEN DO THE SAME FOR [kernel.sin]
			echo AFTER FINISH RENAME THE OUTPUT OF THE [system.sin] TO [system.ext4]
			echo IF IT HAVE OTHER NAME
			set /p wait=CLOSE FLASHTOOL AND PRESS ENTER WHEN YOU READY
			move WORK\system.sin PLACE\system.sin >nul
			if not exist "WORK\system.ext4" (
				TOOLS\bin\cecho {0C}ERROR: NO [WORK\system.ext4] FOUND CAN'T CONTINUE{#}
				echo.
				!busybox! rm -rf WORK
				mkdir WORK
				pause>nul
				goto start
			)
			if not exist "WORK\kernel.elf" (
				TOOLS\bin\cecho {0C}ERROR: NO [WORK\kernel.elf] FOUND CAN'T CONTINUE{#}
				echo.
				!busybox! rm -rf WORK
				mkdir WORK
				pause>nul
				goto start
			)
		)
		if exist "WORK\system.sin" if not exist "WORK\system.ext4" (
			cls
			echo.
			echo.
			echo NOW YOU HAVE [system.sin] IN WORK FOLDER
			echo OPEN SONY FLASHTOOL AND PRESS ON [Tools] TAB THEN PRESS
			echo [Sin Editor] AND CHOOSE [WORK\system.sin] THEN PRESS ON
			echo [Extract data] AND WAIT TO FINISH
			echo AFTER FINISH RENAME THE OUTPUT OF THE [system.sin] TO [system.ext4]
			echo IF IT HAVE OTHER NAME
			set /p wait=CLOSE FLASHTOOL AND PRESS ENTER WHEN YOU READY
			move WORK\system.sin PLACE\system.sin >nul
			if not exist "WORK\system.ext4" (
				TOOLS\bin\cecho {0C}ERROR: NO [WORK\system.ext4] FOUND CAN'T CONTINUE{#}
				echo.
				!busybox! rm -rf WORK
				mkdir WORK
				pause>nul
				goto start
			)
		)
		if exist "WORK\kernel.elf" (
			echo CONVERTING [kernel.elf] TO [boot.img]
			mkdir WORK\elf_convert
			copy WORK\kernel.elf WORK\elf_convert\kernel.elf >nul
			call :convert_elf2img WORK
			move WORK\elf_convert\boot.img WORK\boot.img >nul
			!busybox! rm -rf WORK/elf_convert
			if not exist "WORK\boot.img" (
				TOOLS\bin\cecho {0C}ERROR: FAILED IN CONVERTING{#}
				echo.
			)
		)
		ren WORK\system.ext4 system.img
		call :img_extract
		if not exist "WORK\system\build.prop" if not exist "WORK\system\framework" if not exist "WORK\system\lib" if not exist "WORK\system\bin" (
			echo SORRY BUT AN ERROR HAPPENED CAN'T CONTINUE
			pause>nul
			rmdir /s /q WORK
			mkdir WORK
			goto start
		)
		rmdir WORK\system
		echo CLEANING UP WORK FOLDER
		for /f %%a in ('dir WORK\ /b') do if not "%%a"=="boot.img" if not "%%a"=="system" if not "%%a"=="supersu" !busybox! rm -rf WORK/%%a
		goto prepare_installing
	)
	if "!kind!"==".yaffs2" (
		set bootwar=n
		if not exist "PLACE\boot.img" if not exist "PLACE\kernel.sin" set /p bootwar=FOUND YAFFS2 ROM WITHOUT KERNEL CONTINUE OR BACK [DEFAULT=YES 0=BACK]:
		if "!bootwar!"=="0" goto choose
		if not exist "WORK" mkdir WORK
		call :pick_kernel
		if exist PLACE\system.yaffs2 (
			echo EXTRACTING FILES FROM [system.yaffs2]
			TOOLS\bin\imgextractor PLACE\system.yaffs2 WORK\system>nul
		)
		rmdir WORK\system
		if not exist "WORK\system\build.prop" if not exist "WORK\system\framework" if not exist "WORK\system\lib" if not exist "WORK\system\bin" (
			echo SORRY BUT AN ERROR HAPPENED CAN'T CONTINUE
			pause>nul
			rmdir /s /q WORK
			mkdir WORK
			goto start
		)
		echo CLEANING UP WORK FOLDER
		for /f %%a in ('dir WORK\ /b') do if not "%%a"=="boot.img" if not "%%a"=="system" if not "%%a"=="supersu" !busybox! rm -rf WORK/%%a
		if exist "WORK\kernel.sin" (
			echo CONVERTING [kernel.sin] TO [boot.img]
			set img_dir=converting_sin
			set img_file=kernel.sin
			call :kernelunpack3
			set img_dir=boot_unpacked
			set img_file=boot.img
		)
		goto prepare_installing
	)
	if "!kind!"==".ext4" (
		set bootwar=n
		if not exist "PLACE\boot.sin" if not exist "PLACE\kernel.elf" if not exist "PLACE\boot.img" if not exist "PLACE\kernel.sin" set /p bootwar=FOUND IMG ROM WITHOUT KERNEL CONTINUE OR BACK [DEFAULT=YES 0=BACK]:
		if "!bootwar!"=="0" goto choose
		if not exist "WORK" mkdir WORK
		call :pick_kernel
		for /f "delims=" %%a in ('tools\bin\imgextractor place\system.img.ext4 -s ^| !busybox! grep -cw "SPARSE EXT4"') do if "%%a"=="1" (
			echo CONVERTING SPARSE [system.img.ext4] TO RAW [system.img].....
			TOOLS\bin\simg2img PLACE\system.img.ext4 WORK\system.img>nul
			for /f "delims=" %%a in ('TOOLS\bin\imgextractor WORK\system.img -s ^| !busybox! grep -cw "Found MOTO signature"') do if not "%%a"=="0" (
				echo REMOVING MOTOROLA HEADER SIGNATURE FROM [system.img]
				!busybox! dd if=WORK/system.img of=WORK/new.img ibs=131072 skip=1
				del WORK\system.img
				ren WORK\new.img system.img
			)
			call :img_extract
		) else (
			for /f "delims=" %%a in ('TOOLS\bin\imgextractor PLACE\system.img.ext4 -s ^| !busybox! grep -cw "Found MOTO signature"') do if not "%%a"=="0" (
				echo REMOVING MOTOROLA HEADER SIGNATURE FROM [system.img]
				!busybox! dd if=PLACE/system.img.ext4 of=WORK/system.img ibs=131072 skip=1
				call :img_extract
			) else (
				echo COPYING RAW [system.img.ext4] TO WORK FOLDER
				copy place\system.img.ext4 work\system.img >nul
				call :img_extract
			)
		)
		if exist "place\cache.img.ext4" (
			echo EXTRACTING FILES FROM [cache.img.ext4]
			tools\bin\imgextractor place\cache.img.ext4 work\cache >nul
		)
		if exist "place\hidden.img.ext4" (
			echo EXTRACTING FILES FROM [hidden.img.ext4]
			tools\bin\imgextractor place\hidden.img.ext4 work\hidden >nul
		)
		if exist "WORK\hidden\symlink\system\app" call :move_symlinked_apps
		if exist "WORK\cache\recovery\sec*.zip" for %%f in (WORK\cache\recovery\sec*.zip) do (
			echo EXTRACTING FILES FROM [%%~nf%%~xf]
			TOOLS\bin\7za x -y "WORK\cache\recovery\%%~nf%%~xf" -o"WORK\tmp">nul
			echo COPYING CSC FILES
			xcopy WORK\tmp\system WORK\system /e /i /h /y>nul
		)
		if exist "WORK\kernel.sin" (
			cls
			echo.
			echo.
			echo NOW YOU HAVE [kernel.sin] IN WORK FOLDER
			echo OPEN SONY FLASHTOOL AND PRESS ON [Tools] TAB THEN PRESS
			echo [Sin Editor] AND CHOOSE [WORK\kernel.sin] THEN PRESS ON
			echo [Extract data] AND WAIT TO FINISH
			set /p wait=CLOSE FLASHTOOL AND PRESS ENTER WHEN YOU READY
			if not exist "WORK\kernel.elf" (
				TOOLS\bin\cecho {0C}ERROR: NO [WORK\kernel.elf] FOUND CAN'T CONTINUE{#}
				echo.
				!busybox! rm -rf WORK
				mkdir WORK
				pause>nul
				goto start
			)
		)
		if exist "WORK\kernel.elf" (
			echo CONVERTING [kernel.elf] TO [boot.img]
			mkdir WORK\elf_convert
			copy WORK\kernel.elf WORK\elf_convert\kernel.elf >nul
			call :convert_elf2img WORK
			move WORK\elf_convert\boot.img WORK\boot.img >nul
			!busybox! rm -rf WORK/elf_convert
			if not exist "WORK\boot.img" (
				TOOLS\bin\cecho {0C}ERROR: FAILED IN CONVERTING{#}
				echo.
			)
		)
		echo CLEANING UP WORK FOLDER
		for /f %%a in ('dir WORK\ /b') do if not "%%a"=="boot.img" if not "%%a"=="system" if not "%%a"=="supersu" !busybox! rm -rf WORK/%%a
		goto prepare_installing
	)
	if "!kind!"==".tar" (
		if not exist "WORK" mkdir WORK
		if not exist "WORK\tmp" mkdir WORK\tmp
		echo EXTRACTING [!rom!].....
		TOOLS\bin\7za x -y "PLACE\!rom!" -o"WORK\tmp">nul
		for %%f in (WORK\tmp\*.img) do if not "%%~nf%%~xf"=="boot.img" if not "%%~nf%%~xf"=="recovery.img" ren %%f %%~nf%%~xf.ext4
		if exist "WORK\tmp\boot.img" (
			if exist "WORK\tmp\*.ext4" (
				echo COPYING [boot.img]
				copy WORK\tmp\boot.img WORK\boot.img>nul
			)
		)
		for /f "delims=" %%a in ('tools\bin\imgextractor work\tmp\system.img.ext4 -s ^| !busybox! grep -cw "SPARSE EXT4"') do if "%%a"=="1" (
			echo CONVERTING SPARSE [system.img.ext4] TO RAW [system.img].....
			TOOLS\bin\simg2img WORK\tmp\system.img.ext4 WORK\system.img>nul
			call :img_extract
		) else (
			echo COPYING RAW [system.img.ext4] TO WORK FOLDER
			copy work\tmp\system.img.ext4 work\system.img >nul
			call :img_extract
		)
		if exist "work\tmp\cache.img.ext4" (
			echo EXTRACTING FILES FROM [cache.img.ext4]
			TOOLS\bin\imgextractor work\tmp\cache.img.ext4 WORK\cache>nul
		)
		if exist "work\tmp\hidden.img.ext4" (
			echo EXTRACTING FILES FROM [hidden.img.ext4]
			TOOLS\bin\imgextractor work\tmp\hidden.img.ext4 WORK\hidden>nul
		)
		if exist "WORK\tmp" rmdir /s /q WORK\tmp
		if exist "WORK\hidden\symlink\system\app" call :move_symlinked_apps
		if exist "WORK\cache\recovery\sec*.zip" for %%f in (WORK\cache\recovery\sec*.zip) do (
			echo EXTRACTING FILES FROM [%%~nf%%~xf]
			TOOLS\bin\7za x -y "WORK\cache\recovery\%%~nf%%~xf" -o"WORK\tmp">nul
			echo COPYING CSC FILES
			xcopy WORK\tmp\system WORK\system /e /i /h /y>nul
		)
		echo CLEANING UP WORK FOLDER
		for /f %%a in ('dir WORK\ /b') do if not "%%a"=="boot.img" if not "%%a"=="system" if not "%%a"=="supersu" !busybox! rm -rf WORK/%%a
		goto prepare_installing
	)
	set romnumber=rr
	goto choose
:pick_kernel
	set copy=n
	set kernels=n
	if exist "PLACE\boot.sin" if not exist "PLACE\kernel.sin" ren PLACE\boot.sin kernel.sin
	if exist "PLACE\kernel.elf" if exist "place\kernel.sin" if exist "place\boot.img" (
		set copy=y
		echo FOUND THREE KERNELS [boot.img] AND [kernel.sin] AND [kernel.elf]
		set /p kernels=CHOOSE ONE KERNEL [1=[boot.img] 2=[kernel.sin] 3=[kernel.elf] DEFAULT=CANCEL]:
		if not "!kernels!"=="1" if not "!kernels!"=="2" if not "!kernels!"=="3" goto:eof
		if "!kernels!"=="1" (
			echo COPYING [boot.img]
			copy PLACE\boot.img WORK\boot.img >nul
		)
		if "!kernels!"=="2" (
			echo COPYING [kernel.sin]
			copy PLACE\kernel.sin WORK\kernel.sin >nul
		)
		if "!kernels!"=="3" (
			echo COPYING [kernel.elf]
			copy PLACE\kernel.elf WORK\kernel.elf >nul
		)
		goto:eof
	)
	if exist "place\kernel.sin" if exist "place\boot.img" (
		set copy=y
		echo FOUND TWO KERNELS [boot.img] AND [kernel.sin]
		set /p kernels=CHOOSE ONE KERNEL [1=[boot.img] 2=[kernel.sin] DEFAULT=CANCEL]:
		if not "!kernels!"=="1" if not "!kernels!"=="2" goto:eof
		if "!kernels!"=="1" (
			echo COPYING [boot.img]
			copy PLACE\boot.img WORK\boot.img >nul
		)
		if "!kernels!"=="2" (
			echo COPYING [kernel.sin]
			copy PLACE\kernel.sin WORK\kernel.sin >nul
		)
		goto:eof
	)
	if exist "place\kernel.sin" if exist "place\kernel.elf" (
		set copy=y
		echo FOUND TWO KERNELS [kernel.elf] AND [kernel.sin]
		set /p kernels=CHOOSE ONE KERNEL [1=[kernel.elf] 2=[kernel.sin] DEFAULT=CANCEL]:
		if not "!kernels!"=="1" if not "!kernels!"=="2" goto:eof
		if "!kernels!"=="1" (
			echo COPYING [kernel.elf]
			copy PLACE\kernel.elf WORK\kernel.elf >nul
		)
		if "!kernels!"=="2" (
			echo COPYING [kernel.sin]
			copy PLACE\kernel.sin WORK\kernel.sin >nul
		)
		goto:eof
	)
	if exist "place\kernel.elf" if exist "place\boot.img" (
		set copy=y
		echo FOUND TWO KERNELS [boot.img] AND [kernel.elf]
		set /p kernels=CHOOSE ONE KERNEL [1=[boot.img] 2=[kernel.elf] DEFAULT=CANCEL]:
		if not "!kernels!"=="1" if not "!kernels!"=="2" goto:eof
		if "!kernels!"=="1" (
			echo COPYING [boot.img]
			copy PLACE\boot.img WORK\boot.img >nul
		)
		if "!kernels!"=="2" (
			echo COPYING [kernel.elf]
			copy PLACE\kernel.elf WORK\kernel.elf >nul
		)
		goto:eof
	)
	if "!copy!"=="n" (
		if exist "PLACE\kernel.sin" (
			echo COPYING [kernel.sin]
			copy PLACE\kernel.sin WORK\kernel.sin >nul
		)
		if exist "PLACE\kernel.elf" (
			echo COPYING [kernel.elf]
			copy PLACE\kernel.elf WORK\kernel.elf >nul
		)
		if exist "PLACE\boot.img" (
			echo COPYING [boot.img]
			copy PLACE\boot.img WORK\boot.img >nul
		)
		goto:eof
	)
:move_symlinked_apps
	echo PROCESSING SYMLINKS APKS
	for /f %%s in ('dir WORK\hidden\symlink\system\app\ /b' ) do (
		if exist "WORK\system\app\%%s" (
			!busybox! rm -rf WORK\system\app\%%s
			move WORK\hidden\symlink\system\app\%%s WORK\system\app\%%s>nul
		)
		if exist "WORK\system\priv-app\%%s" (
			!busybox! rm -rf WORK\system\priv-app\%%s
			move WORK\hidden\symlink\system\app\%%s WORK\system\priv-app\%%s>nul
		)
	)
	for /f %%s in ('dir WORK\hidden\symlink\system\priv-app\ /b' ) do (
		if exist "WORK\system\app\%%s" (
			!busybox! rm -rf WORK\system\app\%%s
			move WORK\hidden\symlink\system\priv-app\%%s WORK\system\app\%%s>nul
		)
		if exist "WORK\system\priv-app\%%s" (
			!busybox! rm -rf WORK\system\priv-app\%%s
			move WORK\hidden\symlink\system\priv-app\%%s WORK\system\priv-app\%%s>nul
		)
	)
	rmdir /s /q WORK\hidden
	goto:eof
:img_extract
	rmdir /s /q WORK\system
	echo EXTRACTING FILES FROM [system.img]
	TOOLS\bin\7za x -y "WORK\system.img" -o"WORK\system" >nul
	!busybox! rm -rf WORK/system/[SYS]
	goto:eof
:device_response
	set error=no
	tools\bin\adb devices 0>nul 1>nul 2>nul
	for /f "delims=" %%a in ('tools\bin\adb devices ^| !busybox! grep -cw 'unauthorized'') do set authorize_test=%%a
	if not "!authorize_test!"=="0" (
		ECHO ERROR: YOUR DEVICE IS NOT AUTHORIZED PLEASE CONFIRM
		ECHO THE DIALOG BOX OR TRY RE-CONNECT YOUR DEVICE
		ECHO IF YOU DON'T SEE THAT DIALOG BOX TRY DISABLE [Usb debugging]
		ECHO AND RE-ENABLE IT AGAIN
		ECHO PRESS ANY KEY TO BACK
		set error=yes
		pause>nul
		goto:eof
	)
	for /f "delims=" %%a in ('tools\bin\adb devices ^| !busybox! grep -cw device') do set connect_test=%%a
	if "!connect_test!"=="0" for /f "delims=" %%a in ('tools\bin\adb devices ^| !busybox! grep -cw recovery') do set connect_test=%%a
	if "!connect_test!"=="0" (
		ECHO ERROR: YOUR DEVICE IS NOT CONNECTED PLEASE
		ECHO BE SURE FROM ENABLING [Usb debugging] IN YOUR PHONE
		ECHO PRESS ANY KEY TO BACK
		set error=yes
		pause>nul
		goto:eof
	)
	goto:eof
:pullrom
	cls
	echo.
	echo.
	ECHO BEFOR WE START YOU NEED TO KNOW SOME IMPORTANT THINGS:
	ECHO 1- YOU 'MUST' BE SURE FROM INSATLLING YOUR DEVICE DRIVERS IN THIS PC
	ECHO 2- YOU 'MUST' ENABLE "USB DEBUGGING" MODE IN DEVELOPER OPTIONS IN YOUR DEVICE
	ECHO 3- THIS METHOD CAN PULL [SYSTEM] EVEN IF YOUR DEVICE IS NOT ROOTED
	ECHO BUT SOMETIMES IT'S CAN'T PULL THE [BOOT.IMG] FROM YOUR DEVICE
	ECHO IF YOUR DEVICE IS ROOTED WE MAYBE CAN PULL THE [BOOT.IMG] 
	ECHO BUT IF THERE IS NO ROOT IT IS IMPOSSIBLE TO PULL [BOOT.IMG]
	ECHO HOWEVER, NO PROBLEM YOU CAN PULL SYSTEM ONLY AND COOKING IT 
	ECHO THEN RE-FLASH IT TO YOUR DEVICE IT WILL WORK ON THE SAME KERNEL
	ECHO WITHOUT ERRORS.....
	set start_pull=
	set /p start_pull=DO YOU WANT TO CONTINUE OR NOT [DEFAULT=YES 0=NO]:
	if "!start_pull!"=="0" goto start
	cls
	echo.
	echo.
	echo DETECTING DEVICE RESPONSE
	call :device_response
	if "!error!"=="yes" goto start
	for /f "delims=" %%a in ('TOOLS\bin\adb devices ^| !busybox! grep -cw recovery') do if "%%a"=="1" (
		call :detect_from_recovery_mode kernel_file /boot
		call :detect_from_recovery_mode system_file /system
		for /f "delims=" %%a in ('TOOLS\bin\adb shell ls -l !system_file! ^| TOOLS\bin\gawk "{print $NF}" ^| !busybox! dos2unix') do set system_file2=%%a
		TOOLS\bin\adb shell mount !system_file! >nul
		TOOLS\bin\adb shell mount !system_file2! >nul
		echo PULLING [boot.img] FROM [!kernel_file!]
		TOOLS\bin\adb shell dd if=!kernel_file! of=/sdcard/boot.img >nul
		TOOLS\bin\adb pull /sdcard/boot.img WORK/boot.img >nul
		TOOLS\bin\adb shell rm -f /sdcard/boot.img >nul
		if exist "WORK\boot.img" echo THE KERNEL PULLED SUCCESSFULLY
	)
	TOOLS\bin\adb pull /system/addon.d WORK\testing
	if exist "WORK\testing" (
		!busybox! rm -rf WORK/testing
		echo VERY IMPORTANT: THIS IS AN AOSP ROM: GO TO DEVELOPER OPTIONS AND
		echo set [Root access] TO [Apps and adb]
		echo PRESS ANY KEY WHEN YOU READY
		pause>nul
	)
	for	/f "delims=" %%a in ('TOOLS\bin\adb devices ^| !busybox! grep -cw recovery') do if not "%%a"=="1" (
		echo CHECKING IF WE CAN PULL KERNEL FROM DEVICE
		set su_adb_detect=0
		for /f "delims=" %%a in ('TOOLS\bin\adb shell su -c "ls" ^| !busybox! wc -l') do set su_adb_detect=%%a
		if !su_adb_detect! leq 1 echo ERROR: WE CAN'T PULL KERNEL FROM DEVICE
		set kernel_pull=n
		if !su_adb_detect! geq 5 (
			echo PLEASE ALLOW ROOT ACCESS DIALOG IF YOU SEE IT
			for /f "delims=" %%a in ('TOOLS\bin\adb shell su -c "ls -Rl /dev/block" ^| !busybox! grep -w BOOT ^| !busybox! grep " -> " ^| TOOLS\bin\gawk "{print $NF}" ^| !busybox! dos2unix') do set kernel_pull=%%a
			if "!kernel_pull!"=="n" for /f "delims=" %%a in ('TOOLS\bin\adb shell su -c "ls -Rl /dev/block" ^| !busybox! grep -w boot ^| !busybox! grep " -> " ^| TOOLS\bin\gawk "{print $NF}" ^| !busybox! dos2unix') do set kernel_pull=%%a
			if "!kernel_pull!"=="n" for /f "delims=" %%a in ('TOOLS\bin\adb shell su -c "ls -Rl /dev/block" ^| !busybox! grep -w KERNEL ^| !busybox! grep " -> " ^| TOOLS\bin\gawk "{print $NF}" ^| !busybox! dos2unix') do set kernel_pull=%%a
			if "!kernel_pull!"=="n" for /f "delims=" %%a in ('TOOLS\bin\adb shell su -c "ls -Rl /dev/block" ^| !busybox! grep -w kernel ^| !busybox! grep " -> " ^| TOOLS\bin\gawk "{print $NF}" ^| !busybox! dos2unix') do set kernel_pull=%%a
			if "!kernel_pull!"=="n" echo SORRY BUT WE CAN'T DETECT KERNEL FROM YOUR DEVICE
			if not "!kernel_pull!"=="n" (
				echo DETECTED KERNEL PATH [!kernel_pull!] PULLING IT
				TOOLS\bin\adb shell su -c "dd if=!kernel_pull! of=/storage/emulated/0/boot.img" >nul
				TOOLS\bin\adb shell su -c "dd if=!kernel_pull! of=/sdcard/boot.img" >nul
				TOOLS\bin\adb pull /sdcard/boot.img WORK/boot.img >nul
				TOOLS\bin\adb shell su -c "rm -f /sdcard/boot.img /storage/emulated/0/boot.img" >nul
			)
		)
		if exist "WORK\boot.img" echo KERNEL PULLED SUCCESSFULLY
		if not exist "WORK\boot.img" echo ERROR: FAILED PULLING KERNEL
	)
	echo PULLING SYSTEM FROM DEVICE
	set su=
	if !su_adb_detect! geq 5 set su=su -c 
	TOOLS\bin\adb pull /system WORK/system 2>TOOLS\tmp\pull_system
	for /f "delims=" %%a in ('!busybox! grep -w "Permission denied" TOOLS/tmp/pull_system^| TOOLS\bin\gawk "{print $4}"^| !busybox! sed "s/'//g"') do (
		TOOLS\bin\adb shell %su%"rm -rf /data/local/tmp/*" >nul
		TOOLS\bin\adb shell %su%"cp %%a /data/local/tmp/%%~na%%~xa" >nul
		TOOLS\bin\adb shell %su%"chmod 0755 /data/local/tmp/%%~na%%~xa" >nul
		TOOLS\bin\adb pull /data/local/tmp/%%~na%%~xa WORK%%a >nul
		TOOLS\bin\adb shell %su%"rm -rf /data/local/tmp/*" >nul
	)
	del TOOLS\tmp\pull_system
	set second_connect=0
	for /f "delims=" %%a in ('tools\bin\adb devices ^| !busybox! grep -cw device') do set second_connect=%%a
	if "!second_connect!"=="0" for /f "delims=" %%a in ('tools\bin\adb devices ^| !busybox! grep -cw recovery') do set second_connect=%%a
	if "!second_connect!"=="0" (
		echo FATAL ERROR: THE DEVICE HAVE DISCONNECTED..CAN'T CONTINUE
		!busybox! rm -rf WORK TOOLS/tmp
		mkdir WORK TOOLS\tmp
		echo PRESS ANY KEY TO BACK
		pause>nul
		goto start
	)
	TOOLS\bin\adb pull /file_contexts TOOLS/tmp/kernel_file_contexts >nul
	echo PULLING SYSTEM'S SYMLINKS FROM DEVICE
	del TOOLS\tmp\original_symlinks
	for /f "delims=" %%a in ('TOOLS\bin\adb shell %su%"ls -R /system" ^| !busybox! grep ':' ^| !busybox! sed "s/://g" ^| !busybox! dos2unix') do (
		for /f "delims=" %%b in ('TOOLS\bin\adb shell %su%"ls -l %%a" ^| !busybox! grep " -> "') do (
			for /f "delims=" %%c in ('echo "%%b" ^| TOOLS\bin\gawk "{print $NF}"') do (
				set first=%%c
				set first=!first:"=!
			)
			for /f "delims=" %%d in ('echo "%%b" ^| TOOLS\bin\gawk "{print $(NF-2)}"') do set second=%%d
			echo symlink("!first!", "%%a/!second!";;; | !busybox! sed "s/;;;/);/" >> TOOLS\tmp\symlinks
		)
	)
	!busybox! sort TOOLS\tmp\symlinks >> TOOLS\tmp\original_symlinks
	del TOOLS\tmp\symlinks
	echo RE-CREATING SYMLINKS
	call :creat_symlinks
	goto prepare_installing
:creat_symlinks
	for /f "delims=" %%a in ('type "TOOLS\tmp\original_symlinks"') do (
		for /f "delims=" %%a in ('echo %%a ^| !busybox! cut -d"""" -f2') do set PLACE=%%a
		for /f "delims=" %%a in ('echo %%a ^| !busybox! cut -d"""" -f4') do set link=%%a
		for /f "delims=" %%a in ('!busybox! dirname !link!') do set linkfolder=%%a
		if not exist "WORK/!linkfolder!" mkdir "WORK/!linkfolder!"
		!busybox! ln -s -f -T !PLACE! WORK!link!
	)
	goto:eof
:deodex
	if not exist "WORK\system\app" if not exist "WORK\system\priv-app" if not exist "WORK\system\framework" (
		echo THERE IS NO ROM TO DEODEX IT
		pause>nul
		goto start
	)
	set cpu1=null/null
	set cpu2=null/null
	if exist "WORK\system\framework\arm64" if exist "WORK\system\framework\arm" (
		set cpu1=arm64
		set cpu2=arm
	)
	if not exist "WORK\system\framework\arm64" if exist "WORK\system\framework\arm" set cpu1=arm
	if exist "WORK\system\framework\arm64" if not exist "WORK\system\framework\arm" set cpu1=arm64
	if exist "WORK\system\framework\mips64" if exist "WORK\system\framework\mips" (
		set cpu1=mips64
		set cpu2=mips
	)
	if not exist "WORK\system\framework\mips64" if exist "WORK\system\framework\mips" set cpu1=mips
	if exist "WORK\system\framework\mips64" if not exist "WORK\system\framework\arm" set cpu1=mips64
	if exist "WORK\system\framework\x86_64" if exist "WORK\system\framework\x86" (
		set cpu1=x86_64
		set cpu2=x86
	)
	if not exist "WORK\system\framework\x86_64" if exist "WORK\system\framework\x86" set cpu1=x86
	if exist "WORK\system\framework\x86_64" if not exist "WORK\system\framework\x86" set cpu1=x86_64
	set deodex_s=n
	if exist "WORK\system\framework\*.odex" set deodex_s=y
	if !api! geq 24 if exist "WORK\system\framework\oat" set deodex_s=y
	if !api! leq 23 if exist "WORK\system\framework\!cpu1!" set deodex_s=y
	if "!deodex_s!"=="n" (
		echo IT SEEMS THIS ROM ALREADY DEODEXED
		pause>nul
		goto start
	)
	if not exist "WORK\system\build.prop" (
		echo CAN'T DEODEX WITHOUT [build.prop]
		pause>nul
		goto start
	)
	echo CHECKING JAVA STATUS.....
	java -version 2>TOOLS\tmp\java_test
	if errorlevel ==1 (
		echo YOU HAVN'T [JAVA] INSTALLED IN THIS COMPUTER CAN'T DEODEX WITHOUT IT
		pause>nul
		goto start
	)
	for /f "delims=" %%a in ('!busybox! grep -w version TOOLS/tmp/java_test ^| TOOLS\bin\gawk "{print $3}" ^| !busybox! cut -d"""" -f2') do set java_version=%%a
	del TOOLS\tmp\java_test
	echo JAVA INSTALLED VERSION: [!java_version!] OK
	set decidedeodex=null
	ECHO THIS PROCESS CONVERT ODEX FILES RELATED TO APKS TO 
	ECHO CLASSES.DEX AND REBACK IT TO THE APK FILE 
	ECHO WILL TAKE SOME TIME AND ITS GOOD FOR CUSTOM ROMS 
	set /p decidedeodex=CONTINUE OR NOT [DEFAULT=YES 0=NO]:
	if "!decidedeodex!"=="0" goto start
	set decidedeodex=null
	if exist "WORK\system\framework\%cpu1%\boot.oat" rmdir /s /q WORK\system\framework\%cpu1%\dex>nul
	if exist "WORK\system\framework\%cpu1%\boot.oat" rmdir /s /q WORK\system\framework\%cpu1%\odex>nul
	if exist "WORK\system\framework\%cpu2%\boot.oat" rmdir /s /q WORK\system\framework\%cpu2%\dex>nul
	if exist "WORK\system\framework\%cpu2%\boot.oat" rmdir /s /q WORK\system\framework\%cpu2%\odex>nul
	if !api! geq 24 (
		if exist "WORK\system\framework\!cpu1!\*.oat" (
			echo EXTRACTING OAT FILES FROM [WORK\system\framework\!cpu1!]
			java -Xmx1024m -jar TOOLS\deodex\oat2dex_new.jar boot WORK/system/framework/!cpu1! >nul
			move WORK\system\framework\!cpu1!-odex WORK\system\framework\!cpu1!\odex >nul
			move WORK\system\framework\!cpu1!-dex WORK\system\framework\!cpu1!\dex >nul
		)
		if exist "WORK\system\framework\!cpu2!\*.oat" (
			echo EXTRACTING OAT FILES FROM [WORK\system\framework\!cpu2!]
			java -Xmx1024m -jar TOOLS\deodex\oat2dex_new.jar boot WORK/system/framework/!cpu2! >nul
			move WORK\system\framework\!cpu2!-odex WORK\system\framework\!cpu2!\odex >nul
			move WORK\system\framework\!cpu2!-dex WORK\system\framework\!cpu2!\dex >nul
		)
	) else (
		if exist "WORK\system\framework\!cpu1!\*.oat" (
			echo EXTRACTING OAT FILES FROM [WORK\system\framework\!cpu1!]
			java -Xmx1024m -jar TOOLS\deodex\oat2dex_old.jar boot WORK/system/framework/!cpu1!/boot.oat >nul
		)
		if exist "WORK\system\framework\!cpu2!\*.oat" (
			echo EXTRACTING OAT FILES FROM [WORK\system\framework\!cpu2!]
			java -Xmx1024m -jar TOOLS\deodex\oat2dex_old.jar boot WORK/system/framework/!cpu2!/boot.oat >nul
		)
	)
	!busybox! touch TOOLS/tmp/failed_list.txt TOOLS/tmp/success_list.txt TOOLS/tmp/deodexed_list.txt TOOLS/tmp/oat_framework_list.txt
	echo List of files that failed in deodexing:>>TOOLS\tmp\failed_list.txt
	echo.>>TOOLS\tmp\failed_list.txt
	echo List of files that success in deodexing:>>TOOLS\tmp\success_list.txt
	echo.>>TOOLS\tmp\success_list.txt
	echo List of files that originally deodexed:>>TOOLS\tmp\deodexed_list.txt
	echo.>>TOOLS\tmp\deodexed_list.txt
	echo List of oat jars deodexed from boot.oat:>>TOOLS\tmp\oat_framework_list.txt
	echo.>>TOOLS\tmp\oat_framework_list.txt
	call :clean_apks
	set failed=0
	echo ============================
	echo PROCESS STARTED FOR SYSTEM [apk] FILES.....
	echo ============================
	set all_files=0
	set show_count=0
	for /f "delims=" %%a in ('TOOLS\bin\find WORK/system -name *.apk ^| !busybox! wc -l') do set all_files=%%a
	call :start_deodex WORK/system apk
	del TOOLS\tmp\files_list
	echo ============================
	echo PROCESS STARTED FOR SYSTEM [jar] FILES.....
	echo ============================
	set all_files=0
	set show_count=0
	for /f "delims=" %%a in ('TOOLS\bin\find WORK/system/framework -name *.jar ^| !busybox! wc -l') do set all_files=%%a
	call :start_deodex WORK/system/framework jar
	del TOOLS\tmp\files_list
	if !api! geq 20 call :start_deodex boot.oat null
	set zipaligenq=y
	call :zipalign
	type TOOLS\tmp\success_list.txt>>TOOLS\tmp\deodex_log.txt
	echo.>>TOOLS\tmp\deodex_log.txt
	type TOOLS\tmp\failed_list.txt>>TOOLS\tmp\deodex_log.txt
	echo.>>TOOLS\tmp\deodex_log.txt
	type TOOLS\tmp\deodexed_list.txt>>TOOLS\tmp\deodex_log.txt
	echo.>>TOOLS\tmp\deodex_log.txt
	type TOOLS\tmp\oat_framework_list.txt>>TOOLS\tmp\deodex_log.txt
	echo.>>TOOLS\tmp\deodex_log.txt
	!busybox! rm -rf TOOLS/tmp/success_list.txt TOOLS/tmp/failed_list.txt TOOLS/tmp/deodexed_list.txt TOOLS/tmp/oat_framework_list.txt
	if not "!failed!"=="0" (
		TOOLS\bin\cecho {0c}THERE ARE SOME FILES STILL IN YOUR ROM AND CAN'T DEODEX THEM IN [FAILED LINES]{#}
		echo.
	)
	if "!failed!"=="0" (
		if !api! leq 23 (
			!busybox! rm -rf WORK\system\framework\!cpu1! WORK\system\framework\!cpu2! WORK\system\framework\oat
		) else (
			!busybox! rm -rf WORK\system\framework\oat
		)
	)
	!busybox! rm -rf WORK/system/framework/!cpu1!/odex WORK/system/framework/!cpu1!/dex WORK/system/framework/!cpu2!/odex WORK/system/framework/!cpu2!/dex
	del TOOLS\tmp\files_list
	goto completed
:start_deodex
	if "%1"=="boot.oat" (
		for %%s in (WORK\system\framework\*.jar) do (
			if exist "WORK\system\framework\!cpu1!\dex\%%~ns.dex" (
				set /a show_count+=1
				"TOOLS\bin\cecho" DEODEXING !show_count! OF !all_files!: %%~ns.jar...
				move WORK\system\framework\!cpu1!\dex\%%~ns.dex classes.dex>nul
				TOOLS\apktool\aapt add WORK\system\framework\%%~ns.jar classes.dex >nul
				"TOOLS\bin\cecho" {0a}DEODEXED OK{#}
				echo.
				echo    WORK\system\framework\%%~ns.jar>>TOOLS\tmp\oat_framework_list.txt
				del classes.dex
				set count=1
				for %%m in (WORK\system\framework\!cpu1!\dex\%%~ns-classes*.dex) do (
					set /a count+=1
					"TOOLS\bin\cecho" DEODEXING !show_count! OF !all_files!: %%~ns-classes!count!.jar...
					move %%m classes!count!.dex>nul
					TOOLS\apktool\aapt add WORK\system\framework\%%~ns.jar classes!count!.dex>nul
					"TOOLS\bin\cecho" {0a}DEODEXED OK{#}
					echo.
					echo    WORK\system\framework\%%~ns-classes!count!.jar>>TOOLS\tmp\oat_framework_list.txt
					del classes!count!.dex
				)
			)
		)
		goto:eof
	)
	for /f "delims=" %%a in ('TOOLS\bin\find %1 -name *.%2') do (
		set show_user=%%~na%%~xa
		set file_name=%%a
		set file_name=!file_name:/=\!
		set basename=%%~na
		TOOLS\bin\find %1 -name !basename!.odex* | !busybox! grep -v !basename!.odex.art*>>TOOLS\tmp\odexs
		set odex_check=n
		set /p odex_check=<TOOLS\tmp\odexs
		set lines=0
		for /f "delims=" %%j in ('type "TOOLS\tmp\odexs"') do set /a lines+=1
		if !lines! geq 2 !busybox! sed -i '/^\/!cpu2!\//d' TOOLS/tmp/odexs
		for /f "delims=" %%b in ('TOOLS\bin\7za l !file_name! ^| !busybox! grep -c classes*.dex') do set classes_check=%%b
		if not !classes_check! ==0 (
			if "%2"=="apk" (
				set /a show_count+=1
				TOOLS\bin\cecho DEODEXING !show_count! OF !all_files!: !show_user!...
				TOOLS\bin\cecho {0e}ALREADY DEODEXED{#}
				echo    !file_name!>>TOOLS\tmp\deodexed_list.txt
				echo.
				if not "!odex_check!"=="n" if !api! geq 20 for /f "delims=" %%b in ('type "TOOLS\tmp\odexs"') do (
					set odex_file=%%b
					set odex_file=!odex_file:/=\!
					for /f "delims=" %%z in ('!busybox! dirname !odex_file!') do set dirname=%%z
					for /f "delims=" %%z in ('!busybox! dirname !dirname!') do (
						set dirname2=%%z
						set test_oat=%%~nz%%~xz
					)
					if "!test_oat!"=="oat" ( 
						rmdir /s /q !dirname2!
					) else (
						rmdir /s /q !dirname2!\!cpu2!
						rmdir /s /q !dirname2!\!cpu1!
					)
				)
				if not "!odex_check!"=="n" for /f "delims=" %%b in ('type "TOOLS\tmp\odexs"') do (
					set odex_file=%%b
					set odex_file=!odex_file:/=\!
					del !odex_file!
				)
				del TOOLS\tmp\odexs
			)
			if "%2"=="jar" (
				set /a show_count+=1
				TOOLS\bin\cecho DEODEXING !show_count! OF !all_files!: !show_user!...
				TOOLS\bin\cecho {0e}ALREADY DEODEXED{#}
				echo    !file_name!>>TOOLS\tmp\deodexed_list.txt
				echo.
				del WORK\system\framework\!cpu1!\dex\!basename!.dex WORK\system\framework\!cpu1!\dex\!basename!-classes*.dex
				if not "!odex_check!"=="n" for /f "delims=" %%b in ('type "TOOLS\tmp\odexs"') do (
					set odex_file=%%b
					set odex_file=!odex_file:/=\!
					del !odex_file!
				)
				del TOOLS\tmp\odexs
			)
		)
		if !classes_check! ==0 if !odex_check! ==n if not exist "WORK\system\framework\!cpu1!\dex\%%~na*.dex" (
			set /a show_count+=1
			TOOLS\bin\cecho DEODEXING !show_count! OF !all_files!: !show_user!...
			TOOLS\bin\cecho {0A}NOT NEEDING{#}
			echo.
			del TOOLS\tmp\odexs
		)
		if !classes_check! ==0 if not !odex_check! ==n if !api! geq 20 for /f "delims=" %%b in ('type "TOOLS\tmp\odexs"') do (
			set /a show_count+=1
			set odex_file_work=%%b
			set odex_file_work=!odex_file_work:/=\!
			for /f "delims=" %%c in ('!busybox! dirname !odex_file_work!') do (
				set cpu_type=%%~nc%%~xc
				set odex_folder=%%c
			)
			TOOLS\bin\cecho DEODEXING !show_count! OF !all_files!: !show_user!...
			if exist "!odex_folder!\!basename!.odex.*z" TOOLS\bin\7za x -y !odex_file_work! -o"!odex_folder!\">nul
			java -Xmx1024M -jar TOOLS\deodex\oat2dex_old.jar !odex_folder!\!basename!.odex WORK\system\framework\!cpu_type!\odex >nul
			if not exist "!odex_folder!\!basename!.dex" java -Xmx1024M -jar TOOLS\deodex\oat2dex_med.jar !odex_folder!\!basename!.odex WORK\system\framework\!cpu_type!\odex>nul
			if not exist "!odex_folder!\!basename!.dex" java -Xmx1024M -jar TOOLS\deodex\oat2dex_new.jar !odex_folder!\!basename!.odex WORK\system\framework\!cpu_type!\odex>nul
			if not exist "!odex_folder!\!basename!.dex" (
				set dex_count=0
				for /f "delims=" %%z in ('java -Xmx1024m -jar TOOLS\apktool\baksmali_new.jar list dex !odex_folder!\!basename!.odex') do (
					set /a dex_count+=1
					if "!dex_count!"=="1" (
						java -Xmx1024m -jar TOOLS\apktool\baksmali_new.jar deodex !odex_folder!\!basename!.odex -o TOOLS\tmp\deodex_!basename! -b WORK\system\framework\!cpu_type!\boot.oat >nul
						java -Xmx1024m -jar TOOLS\apktool\smali_new.jar assemble TOOLS\tmp\deodex_!basename! -o !odex_folder!\!basename!.dex >nul
						!busybox! rm -rf TOOLS/tmp/deodex_!basename!
					) else (
						java -Xmx1024m -jar TOOLS\apktool\baksmali_new.jar deodex !odex_folder!\!basename!.odex\classes!dex_count!.dex -o TOOLS\tmp\deodex_!basename!_!dex_count! -b WORK\system\framework\!cpu_type!\boot.oat >nul
						java -Xmx1024m -jar TOOLS\apktool\smali_new.jar assemble TOOLS\tmp\deodex_!basename!_!dex_count! -o !odex_folder!\!basename!-classes!dex_count!.dex >nul
						!busybox! rm -rf TOOLS/tmp/deodex_!basename!_!dex_count!
					)
				)
			)
			move !odex_folder!\!basename!.dex classes.dex>nul
			set count=1
			for %%m in (!odex_folder!\!basename!-classes*.dex) do (
				set /a count+=1
				move %%m classes!count!.dex>nul
			)
			if not exist "classes*.dex" (
				set /a failed+=1
				TOOLS\bin\cecho {0c}DEODEXED FAILED{#}
				echo.
				del TOOLS\tmp\odexs
				echo    !file_name!>>TOOLS\tmp\failed_list.txt
			)
			if exist "classes*.dex" (
				if %2 ==jar del !odex_file_work!
				TOOLS\apktool\aapt add !file_name! classes*.dex >nul
				if "%2"=="apk" if !api! geq 24 if not "!factory!"=="samsung" TOOLS\apktool\aapt remove !file_name! META-INF/CERT.RSA META-INF/CERT.SF META-INF/MANIFEST.MF >nul
				TOOLS\bin\cecho {0a}DEODEXED OK{#}
				echo.
				echo    !file_name!>>TOOLS\tmp\success_list.txt
				del classes*.dex
				if %2 ==apk for /f "delims=" %%x in ('echo !odex_file_work!') do (
					set odex_file=%%x
					set odex_file=!odex_file:/=\!
					for /f "delims=" %%z in ('!busybox! dirname !odex_file!') do set dirname=%%z
					for /f "delims=" %%z in ('!busybox! dirname !dirname!') do (
						set dirname2=%%z
						set test_oat=%%~nz%%~xz
					)
					if "!test_oat!"=="oat" (
						rmdir /s /q !dirname2!
					) else (
						rmdir /s /q !dirname2!\!cpu2!
						rmdir /s /q !dirname2!\!cpu1!
					)
				)
			)
		)
		if !classes_check! ==0 if not !odex_check! ==n if !api! leq 19 for /f "delims=" %%b in ('type "TOOLS\tmp\odexs"') do (
			set /a show_count+=1
			set odex_file_work=%%b
			set odex_file_work=!odex_file_work:/=\!
			TOOLS\bin\cecho DEODEXING !show_count! OF !all_files!: !show_user!...
			java -Xmx1024M -jar TOOLS\deodex\baksmali.jar -a !api! -d WORK\system\framework -x "!odex_file_work!"
			java -Xmx1024M -jar TOOLS\deodex\smali.jar -a !api! -o "classes.dex" out>nul
			rmdir /s /q out
			if not exist "classes*.dex" (
				set /a failed+=1
				TOOLS\bin\cecho {0c}DEODEXED FAILED{#}
				echo.
				echo    !file_name!>>TOOLS\tmp\failed_list.txt
			)
			if exist "classes*.dex" (
				del !odex_file_work!
				TOOLS\apktool\aapt add !file_name! classes*.dex >nul
				TOOLS\bin\cecho {0a}DEODEXED OK{#}
				echo.
				echo    !file_name!>>TOOLS\tmp\success_list.txt
				del classes*.dex
			)
		)
		del TOOLS\tmp\odexs
	)
	goto:eof
:zipalign
	if not exist "WORK\system" (
		echo THERE IS NO ROM TO ZIPALIGN
		pause>nul
		goto start
	)
	set decidezipalign=null
	if not "!zipaligenq!"=="y" set /p decidezipalign=WILL OPTIMIZE ALL ROM APKS TO IMPROVE RAM CONTINUE OR NOT [DEFAULT=YES 0=NO]:
	if "!decidezipalign!"=="0" goto start
	set decidezipalign=null
	del TOOLS\tmp\file_ziped
	set all_files=0
	set count_file=0
	for /f "delims=" %%a in ('TOOLS\bin\find WORK -name *.apk ^| !busybox! wc -l') do set all_files=%%a
	for /f "delims=" %%a in ('TOOLS\bin\find WORK -name *.jar ^| !busybox! wc -l') do set /a all_files+=%%a
	for /f "delims=" %%a in ('TOOLS\bin\find WORK -name *.apk') do echo %%a>>TOOLS\tmp\full_zip_list
	for /f "delims=" %%a in ('TOOLS\bin\find WORK -name *.jar') do echo %%a>>TOOLS\tmp\full_zip_list
	for /f "delims=" %%a in ('type TOOLS\tmp\full_zip_list') do (
		set /a count_file+=1
		set file=%%a
		set file=!file:/=\!
		echo ZIPALIGNING !count_file! of !all_files!: %%~na%%~xa
		TOOLS\bin\zipalign -f -p 4 "!file!" "TOOLS\tmp\file_ziped"
		del !file!
		move TOOLS\tmp\file_ziped !file!>nul
	)
	del TOOLS\tmp\zipalign TOOLS\tmp\full_zip_list
	echo zipaligned >>TOOLS\tmp\zipalign
	if not "!zipaligenq!"=="y" goto completed
	if "!zipaligenq!"=="y" goto:eof
:root
	if not exist "WORK\system\build.prop" (
		echo NO ROM FOUND TO ADD ROOT
		pause>nul
		goto start
	)
	if exist "WORK\system\xbin\daemonsu" echo REMOVING ROOT
	if exist "WORK\system\xbin\daemonsu" if "!api!" geq "20" if exist "WORK\system\bin\app_process32*" if not exist "WORK\system\bin\app_process64*" !busybox! sed -i -e 's/symlink("Roboto-Regular.ttf", "\/system\/fonts\/DroidSans.ttf");/symlink("Roboto-Regular.ttf", "\/system\/fonts\/DroidSans.ttf");\nsymlink("app_process32", "\/system\/bin\/app_process");/' !updater_script! tools/tmp/original_symlinks
	if exist "WORK\system\xbin\daemonsu" if "!api!" geq "20" if exist "WORK\system\bin\app_process64*" !busybox! sed -i -e 's/symlink("Roboto-Regular.ttf", "\/system\/fonts\/DroidSans.ttf");/symlink("Roboto-Regular.ttf", "\/system\/fonts\/DroidSans.ttf");\nsymlink("app_process64", "\/system\/bin\/app_process");/' !updater_script! tools/tmp/original_symlinks
	if exist "WORK\system\xbin\daemonsu" (
		!busybox! sed -i '/^set_metadata("\/system\/xbin\/su", "uid", 0, "gid", 2000, "mode", 0755, "capabilities", 0x0, "selabel", "u:object_r:su_exec:s0"/d' !updater_script!
		!busybox! sed -i '/^set_metadata("\/system\/bin\/app_process_init", "uid", 0, "gid", 2000, "dmode", 0755, "fmode", 0755, "capabilities", 0x0, "selabel", "u:object_r:system_file:s0"/d' !updater_script!
		!busybox! sed -i '/^set_metadata("\/system\/bin\/.ext", "uid", 0, "gid", 0, "mode", 0777, "capabilities", 0x0, "selabel", "u:object_r:system_file:s0"/d' !updater_script!
		!busybox! sed -i '/^set_metadata("\/system\/bin\/.ext\/.su", "uid", 0, "gid", 0, "mode", 0755, "capabilities", 0x0, "selabel", "u:object_r:system_file:s0"/d' !updater_script!
		!busybox! sed -i '/^set_metadata("\/system\/bin\/.ext\/.su", "uid", 0, "gid", 0, "mode", 06755, "capabilities", 0x0, "selabel", "u:object_r:system_file:s0"/d' !updater_script!
		!busybox! sed -i '/^set_metadata("\/system\/app\/superuser.apk", "uid", 0, "gid", 0, "mode", 0644, "capabilities", 0x0, "selabel", "u:object_r:system_file:s0"/d' !updater_script!
		!busybox! sed -i '/^set_metadata("\/system\/etc\/install-recovery.sh", "uid", 0, "gid", 0, "mode", 0755, "capabilities", 0x0, "selabel", "u:object_r:toolbox_exec:s0"/d' !updater_script!
		!busybox! sed -i '/^set_metadata("\/system\/etc\/install-recovery.sh", "uid", 0, "gid", 0, "mode", 0755, "capabilities", 0x0, "selabel", "u:object_r:system_file:s0"/d' !updater_script!
		!busybox! sed -i '/^set_metadata("\/system\/xbin\/daemonsu", "uid", 0, "gid", 0, "mode", 0755, "capabilities", 0x0, "selabel", "u:object_r:system_file:s0"/d' !updater_script!
		!busybox! sed -i '/^set_metadata("\/system\/xbin\/su", "uid", 0, "gid", 0, "mode", 0755, "capabilities", 0x0, "selabel", "u:object_r:system_file:s0"/d' !updater_script!
		!busybox! sed -i '/^set_metadata("\/system\/xbin\/su", "uid", 0, "gid", 0, "mode", 06755, "capabilities", 0x0, "selabel", "u:object_r:system_file:s0"/d' !updater_script!
		!busybox! sed -i '/^set_metadata("\/system\/xbin\/sugote", "uid", 0, "gid", 0, "mode", 0755, "capabilities", 0x0, "selabel", "u:object_r:zygote_exec:s0"/d' !updater_script!
		!busybox! sed -i '/^set_metadata("\/system\/xbin\/sugote-mksh", "uid", 0, "gid", 0, "mode", 0755, "capabilities", 0x0, "selabel", "u:object_r:system_file:s0"/d' !updater_script!
		!busybox! sed -i '/^set_metadata("\/system\/xbin\/supolicy", "uid", 0, "gid", 0, "mode", 0755, "capabilities", 0x0, "selabel", "u:object_r:system_file:s0"/d' !updater_script!
		!busybox! sed -i '/^symlink("\/system\/xbin\/daemonsu", "\/system\/bin\/app_process"/d' !updater_script! tools/tmp/original_symlinks
		!busybox! sed -i '/^symlink("\/system\/xbin\/daemonsu", "\/system\/bin\/app_process32"/d' !updater_script! tools/tmp/original_symlinks
		!busybox! sed -i '/^symlink("\/system\/xbin\/daemonsu", "\/system\/bin\/app_process64"/d' !updater_script! tools/tmp/original_symlinks
		!busybox! sed -i '/^set_perm(0, 0, 0777, "\/system\/bin\/.ext"/d' !updater_script!
		!busybox! sed -i '/^set_perm(0, 0, 0755, "\/system\/xbin\/supolicy"/d' !updater_script!
		!busybox! sed -i '/^set_perm(0, 0, 0644, "\/system\/lib\/libsupol.so"/d' !updater_script!
		!busybox! sed -i '/^set_perm(0, 0, 0755, "\/system\/etc\/install-recovery.sh"/d' !updater_script!
		!busybox! sed -i '/^set_perm(0, 0, 0755, "\/system\/bin\/.ext\/.su"/d' !updater_script!
		!busybox! sed -i '/^set_perm(0, 0, 0755, "\/system\/xbin\/su"/d' !updater_script!
		!busybox! sed -i '/^set_perm(0, 0, 0755, "\/system\/xbin\/sugote-mksh"/d' !updater_script!
		!busybox! sed -i '/^set_perm(0, 0, 0755, "\/system\/xbin\/sugote"/d' !updater_script!
		!busybox! sed -i '/^set_perm(0, 2000, 0755, "\/system\/etc\/install-recovery.sh"/d' !updater_script!
		!busybox! sed -i '/^set_perm(0, 2000, 0755, "\/system\/bin\/app_process_init"/d' !updater_script!
		!busybox! sed -i '/^set_perm(0, 0, 0644, "\/system\/app\/Superuser.apk"/d' !updater_script!
		!busybox! sed -i '/^set_perm(0, 0, 0644, "\/system\/app\/SuperSU\/SuperSU.apk"/d' !updater_script!
		!busybox! sed -i '/^set_perm(0, 0, 0755, "\/system\/etc\/init.d\/99supersudaemon"/d' !updater_script!
		!busybox! sed -i '/^set_perm(0, 0, 0744, "\/system\/etc\/init.d\/99supersudaemon"/d' !updater_script!
		!busybox! sed -i '/^set_perm(0, 0, 06755, "\/system\/xbin\/su"/d' !updater_script!
		!busybox! sed -i '/^set_perm(0, 0, 06755, "\/system\/xbin\/daemonsu"/d' !updater_script!
		!busybox! sed -i '/^set_perm(0, 0, 0755, "\/system\/xbin\/daemonsu"/d' !updater_script!
		!busybox! sed -i '/^set_perm(0, 0, 0644, "\/system\/etc\/.installed_su_daemon"/d' !updater_script!
		!busybox! sed -i '/^set_perm(0, 0, 06755, "\/system\/bin\/.ext\/.su"/d' !updater_script!
		!busybox! sed -i '/^symlink("\/system\/xbin\/su", "\/system\/bin\/su"/d' !updater_script! tools/tmp/original_symlinks
		!busybox! sed -i '/^symlink("\/system\/etc\/install-recovery.sh", "\/system\/bin\/install-recovery.sh"/d' !updater_script! tools/tmp/original_symlinks
		!busybox! sed -i '/^set_metadata("\/system\/lib\/libsupol.so", "uid", 0, "gid", 0, "mode", 0644, "capabilities", 0x0, "selabel", "u:object_r:system_file:s0"/d' !updater_script!
		!busybox! sed -i '/^set_metadata("\/system\/app\/SuperSU", "uid", 0, "gid", 0, "mode", 0755, "capabilities", 0x0, "selabel", "u:object_r:system_file:s0"/d' !updater_script!
		!busybox! sed -i '/^set_metadata("\/system\/app\/SuperSU\/SuperSU.apk", "uid", 0, "gid", 0, "mode", 0644, "capabilities", 0x0, "selabel", "u:object_r:system_file:s0"/d' !updater_script!
		!busybox! sed -i '/^set_metadata("\/system\/etc\/install-recovery.sh", "uid", 0, "gid", 0, "mode", 0755, "capabilities", 0x0, "selabel", "u:object_r:system_file:s0"/d' !updater_script!
		!busybox! sed -i '/^set_metadata("\/system\/bin\/app_process_init", "uid", 0, "gid", 2000, "mode", 0755, "capabilities", 0x0, "selabel", "u:object_r:system_file:s0"/d' !updater_script!
		!busybox! sed -i '/^set_metadata("\/system\/etc\/init.d\/99supersudaemon", "uid", 0, "gid", 0, "mode", 0744, "capabilities", 0x0, "selabel", "u:object_r:system_file:s0"/d' !updater_script!
		!busybox! sed -i '/^run_program("\/system\/xbin\/su", "--install"/d' !updater_script!
		!busybox! sed -i '/^set_metadata("\/system\/lib64\/libsupol.so", "uid", 0, "gid", 0, "mode", 0644, "capabilities", 0x0, "selabel", "u:object_r:system_file:s0"/d' !updater_script!
		!busybox! sed -i '/^set_metadata("\/system\/app\/Superuser.apk", "uid", 0, "gid", 0, "mode", 0644, "capabilities", 0x0, "selabel", "u:object_r:system_file:s0"/d' !updater_script!
		rmdir /s /q WORK\system\app\supersu
		del WORK\system\xbin\sugote-mksh
		del WORK\system\app\superuser.apk
		del WORK\system\app\superuser.odex
		del WORK\system\app\supersu.apk
		del WORK\system\app\supersu.odex
		del WORK\system\etc\install-recovery.sh
		del WORK\system\etc\.installed_su_daemon
		del WORK\system\lib\libsupol.so
		del WORK\system\xbin\su
		del WORK\system\xbin\supolicy
		del WORK\system\xbin\daemonsu
		del WORK\system\xbin\chattr.pie
		del WORK\system\xbin\sugote
		del WORK\system\xbin\sugote-mksh
		rmdir /s /q WORK\system\bin\.ext
		del WORK\system\bin\install-recovery.sh
		del WORK\system\etc\init.d\99supersudaemon
		if !api! geq 20 if not exist "WORK\system\bin\app_process64*" (
			copy WORK\system\bin\app_process32_original WORK\system\bin\app_process32>nul
			del WORK\system\bin\app_process_init
			del WORK\system\bin\app_process32_original
			copy TOOLS\tmp\app_process WORK\system\bin\app_process>nul
			del TOOLS\tmp\app_process
		)
		if !api! geq 20 if exist "WORK\system\bin\app_process64*" (
			copy WORK\system\bin\app_process64_original WORK\system\bin\app_process64>nul
			del WORK\system\bin\app_process_init
			del WORK\system\bin\app_process64_original
			copy TOOLS\tmp\app_process WORK\system\bin\app_process>nul
			del TOOLS\tmp\app_process
		)
		goto completed
	)
	if not "!su_installer_detect!"=="0" (
		echo REMOVEING ROOT INSTALLER
		TOOLS\bin\find WORK -name install_su* -delete
		for /f "delims=" %%a in ('TOOLS\bin\find WORK -name supersu*') do !busybox! rm -rf %%a
		!busybox! sed -i '/^supersu/d' !updater_script!
		!busybox! sed -i '/^supersu/d' !updater_script!
		!busybox! sed -i '/^supersu/d' !updater_script!
		!busybox! sed -i '/^install_su.sh/d' !updater_script!
		goto completed 
	)
	set rootmode=456
	set fastwant=null
	ECHO FAST MODE: WILL ADD ROOT BINARY WITHOUT [Superuser.apk]
	ECHO THIS MEANS THE APPS TAKE ROOT PERMISSIONS WITHOUT [Superuser.apk] DETECT [FASTER]
	ECHO CLASSIC MODE: ADD ALL ROOT TOOLS WITH APK [NORMAL MODE IN ALL ROMS]
	set /p rootmode=FAST ROOT MODE OR CLASSIC MODE [1=FAST 2=CLASSIC DEFAULT=BACK]:
	if "%rootmode%"=="1" set fastwant=y
	if not "%rootmode%"=="1" if not "%rootmode%"=="2" goto start
	set s1=if exist "WORK\system\addon.d"
	set s2=if exist "WORK\META-INF\ADD-ONS"
	set s3=if not exist "WORK\META-INF\ADD-ONS"
	set s4=if !api! geq 22
	if !api! geq 22 if exist "TOOLS\tmp\sepolicy_original" (
		echo WE HAVE TWO ROOT METHODS [SYSTEM MODE, SYSTEMLESS MODE]
		echo THE SYSTEMLESS MODE WILL WILL ADDED AS ROOT INSTALLER
		set ask2=
		set /p ask2=CHOOSE METHOD [DEFAULT=SYSTEM_MODE 1=ROOT_INSTALLER 0=BACK]:
		if "!ask2!"=="0" goto start
		if "!ask2!"=="1" set ask=0
		if not "!ask2!"=="1" set ask=1
	)
	if !api! geq 22 if not exist "TOOLS\tmp\sepolicy_original" (
		cls
		echo.
		echo.
		echo BECAUSE OF THIS ROM IS 5.1.1+ IT IS NEED TO PATCH [sepolicy] IN KERNEL
		echo TO INSTALL THE ROOT IN SYSTEM MODE AND THIS NEEDS AN ANDROID PHONE
		echo RUNNING ANDROID KITKAT+ AND MUST BE ROOTED AND BOOTED TO ANDROID
		echo IF YOU WANT TO PATCH THE [sepolicy] AND INSTALL IN SYSTEM MODE PRESS 1
		echo IF YOU DON'T KNOW WHAT THIS MEANING OR WANT SYSTEMLESS MODE
		echo JUST PRESS ENTER KEY
		set ask=
		set /p ask=WHAT YOUR CHOICE [DEFAULT=ROOT_INSTALLER 1=SYSTEM_MODE_PATCH_KERNEL]:
		set s5=if not "!ask!"=="1"
		if "!ask!"=="1" (
			call :patch_sepolicy root
			if exist "TOOLS\tmp\sepolicy_original" set ask=1
			if not exist "TOOLS\tmp\sepolicy_original" (
				TOOLS\bin\cecho {0E}AN ERROR HAPPENED DURING PATCH [sepolicy] WILL ADD ROOT ISNTALLER{#}
				echo.
				set ask=0
			)
		)
	)
	if not "!ask!"=="1" %s4% if not exist "!updater_script!" (
		echo NO [update-script] FOUND TO ADD ROOT INSTALLER
		echo SO PLEASE BUILD INSTALLER FIRST
		PAUSE>nul
		goto start
	)
	if not "!ask!"=="1" %s4% echo INSTALLING ROOT INSTALLER
	if not "!ask!"=="1" %s4% %s2% if !fastwant! ==y (
		mkdir WORK\META-INF\ADD-ONS\supersu
		copy TOOLS\root\fast.zip WORK\META-INF\ADD-ONS\supersu\supersu.zip >nul
	)
	if not "!ask!"=="1" %s4% %s2% if not !fastwant! ==y (
		mkdir WORK\META-INF\ADD-ONS\supersu
		copy TOOLS\root\classic.zip WORK\META-INF\ADD-ONS\supersu\supersu.zip >nul
	)
	if not "!ask!"=="1" %s4% %s2% !busybox! sed -i -e 's/#--CUSTOM SCRIPTS/#--CUSTOM SCRIPTS\nui_print("-- Rooting rom with supersu");\npackage_extract_dir("META-INF\/ADD-ONS\/supersu", "\/tmp\/supersu");\nrun_program("\/sbin\/busybox", "unzip", "\/tmp\/supersu\/supersu.zip", "META-INF\/com\/google\/android\/update-binary", "-d", "\/tmp\/supersu");\nrun_program("\/sbin\/busybox", "sh", "\/tmp\/supersu\/META-INF\/com\/google\/android\/update-binary", "dummy", "1", "\/tmp\/supersu\/supersu.zip");/' !updater_script!
	if not "!ask!"=="1" %s4% %s2% TOOLS\bin\dos2unix -q !updater_script!>nul
	if not "!ask!"=="1" %s4% %s2% goto completed
	if not "!ask!"=="1" %s4% %s3% if !fastwant! ==y (
		mkdir WORK\supersu
		copy TOOLS\root\fast.zip WORK\supersu\supersu.zip>nul
	)
	if not "!ask!"=="1" %s4% %s3% if not !fastwant! ==y (
		mkdir WORK\supersu
		copy TOOLS\root\classic.zip WORK\supersu\supersu.zip>nul
	)
	if not "!ask!"=="1" %s4% %s3% echo ui_print("Rooting rom with supersu");>>!updater_script!
	if not "!ask!"=="1" %s4% %s3% echo package_extract_dir("supersu", "/tmp/supersu");>>!updater_script!
	if not "!ask!"=="1" %s4% %s3% echo run_program("/sbin/busybox", "unzip", "/tmp/supersu/supersu.zip", "META-INF/com/google/android/update-binary", "-d", "/tmp/supersu");>>!updater_script!
	if not "!ask!"=="1" %s4% %s3% echo run_program("/sbin/busybox", "sh", "/tmp/supersu/META-INF/com/google/android/update-binary", "dummy", "1", "/tmp/supersu/supersu.zip");>>!updater_script!
	if not "!ask!"=="1" %s4% %s3% call TOOLS\bin\dos2unix -q !updater_script!>nul
	if not "!ask!"=="1" %s4% %s3% goto completed
	if not "!ask!"=="1" %s1% if not exist "!updater_script!" echo THIS IS AN ANDROID CM/AOSP ROM AND IT NEEDS ROOT INSTALLER
	if not "!ask!"=="1" %s1% if not exist "!updater_script!" (
		echo SO PLEASE BUILD INSTALLER FIRST
		PAUSE>nul
		goto start
	)
	if not "!ask!"=="1" %s1% echo INSTALLING ROOT INSTALLER
	if not "!ask!"=="1" %s1% %s2% if !fastwant! ==y (
		mkdir WORK\META-INF\ADD-ONS\supersu
		copy TOOLS\root\fast.zip WORK\META-INF\ADD-ONS\supersu\supersu.zip >nul
	)
	if not "!ask!"=="1" %s1% %s2% if not !fastwant! ==y (
		mkdir WORK\META-INF\ADD-ONS\supersu
		copy TOOLS\root\classic.zip WORK\META-INF\ADD-ONS\supersu\supersu.zip >nul
	)
	if not "!ask!"=="1" %s1% %s2% !busybox! sed -i -e 's/#--CUSTOM SCRIPTS/#--CUSTOM SCRIPTS\nui_print("-- Rooting rom with supersu");\npackage_extract_dir("META-INF\/ADD-ONS\/supersu", "\/tmp\/supersu");\nrun_program("\/sbin\/busybox", "unzip", "\/tmp\/supersu\/supersu.zip", "META-INF\/com\/google\/android\/update-binary", "-d", "\/tmp\/supersu");\nrun_program("\/sbin\/busybox", "sh", "\/tmp\/supersu\/META-INF\/com\/google\/android\/update-binary", "dummy", "1", "\/tmp\/supersu\/supersu.zip");/' !updater_script!
	if not "!ask!"=="1" %s1% %s2% TOOLS\bin\dos2unix -q !updater_script!>nul
	if not "!ask!"=="1" %s1% %s2% goto completed
	if not "!ask!"=="1" %s1% %s3% if !fastwant! ==y (
		mkdir WORK\supersu
		copy TOOLS\root\fast.zip WORK\supersu\supersu.zip>nul
	)
	if not "!ask!"=="1" %s1% %s3% if not !fastwant! ==y (
		mkdir WORK\supersu
		copy TOOLS\root\classic.zip WORK\supersu\supersu.zip>nul
	)
	if not "!ask!"=="1" %s1% %s3% echo ui_print("Rooting rom with supersu");>>!updater_script!
	if not "!ask!"=="1" %s1% %s3% echo package_extract_dir("supersu", "/tmp/supersu");>>!updater_script!
	if not "!ask!"=="1" %s1% %s3% echo run_program("/sbin/busybox", "unzip", "/tmp/supersu/supersu.zip", "META-INF/com/google/android/update-binary", "-d", "/tmp/supersu");>>!updater_script!
	if not "!ask!"=="1" %s1% %s3% echo run_program("/sbin/busybox", "sh", "/tmp/supersu/META-INF/com/google/android/update-binary", "dummy", "1", "/tmp/supersu/supersu.zip");>>!updater_script!
	if not "!ask!"=="1" %s1% %s3% call TOOLS\bin\dos2unix -q !updater_script!>nul
	if not "!ask!"=="1" %s1% %s3% goto completed
	echo ROOTING THE ROM
	for /f "delims=" %%a in ('!busybox! grep -m 1 "ro.build.version.sdk=" WORK/system/build.prop ^| !busybox! cut -d"=" -f2-') do set api=%%a
	for /f "delims=" %%a in ('!busybox! grep -m 1 "ro.product.cpu.abi=" WORK/system/build.prop ^| !busybox! cut -d"=" -f2-') do (
		set abilong=%%a
		set abi=!abilong:~0,3!
	)
	for /f "delims=" %%a in ('!busybox! grep -m 1 "ro.product.cpu.abi2=" WORK/system/build.prop ^| !busybox! cut -d"=" -f2-') do set abi2=%%a
	set linereplace1=set_metadata_recursive("\/system\/xbin", "uid", 0, "gid", 2000, "dmode", 0755, "fmode", 0755, "capabilities", 0x0, "selabel", "u:object_r:system_file:s0");
	set linereplace2=set_metadata_recursive("\/system\/xbin", "uid", 0, "gid", 2000, "dmode", 0755, "fmode", 0755, "capabilities", "0x0", "selabel", "u:object_r:system_file:s0");
	!busybox! sed -i -e 's/!linereplace2!/!linereplace1!/' !updater_script!
	set linereplace1=set_metadata_recursive("\/system\/xbin", "uid", 0, "gid", 2000, "dmode", 0755, "fmode", 0755, "capabilities", 0x0, "selabel", "u:object_r:system_file:s0");
	set linereplace2=set_perm_recursive(0, 2000, 0755, 0755, "\/system\/xbin");
	set linereplace3=symlink("Roboto-Regular.ttf", "\/system\/fonts\/DroidSans.ttf");
	set sumod=06755
	set sugote=false
	set supolicy=false
	set mksh=WORK\system\bin\mksh
	set pie=
	set su=su
	set arch=arm
	set apkfolder=false
	set apkname=WORK\system\app\Superuser.apk
	set appprocess=false
	set appprocess64=false
	set systemlib=WORK\system\lib
	set ramdisklib=!systemlib!
	set rwsystem=true
	if "!abi!" =="x86" set arch=x86
	if "!abi2!" =="x86" set arch=x86
	if "!api!" geq "17" set sugote=true
	if "!api!" geq "17" set pie=.pie
	if "!api!" geq "17" if "!arch!" =="x86" set su=su.pie
	if "!api!" geq "17" if "!abilong!" =="armeabi-v7a" set arch=armv7
	if "!api!" geq "17" if "!abi!" =="mip" set arch=mips
	if "!api!" geq "17" if "!abilong!" =="mips" set arch=mips
	if "!api!" geq "18" set sumod=0755
	if "!api!" geq "20" if "!abilong!" =="arm64-v8a" (
		set arch=arm64
		set systemlib=WORK\system\lib64
		set appprocess64=true
	)
	if "!api!" geq "20" if "!abilong!" =="mips64" (
		set arch=mips64
		set systemlib=WORK\system\lib64
		set appprocess64=true
	)
	if "!api!" geq "20" if "!abilong!" =="x86_64" (
		set arch=x64
		set systemlib=WORK\system\lib64
		set appprocess64=true
	)
	if "!api!" geq "20" set apkfolder=true
	if "!api!" geq "20" set apkname=WORK\system\app\SuperSU\SuperSU.apk
	if "!api!" geq "19" set supolicy=true
	if "!api!" geq "21" set appprocess=true
	if "!api!" geq "22" set sugote=false
	if not exist "!mksh!" set mksh=WORK\system\bin\sh
	set bin=TOOLS\root\!arch!
	set com=TOOLS\root\common
	!busybox! sed -i -e 's/!linereplace1!/!linereplace1!\nrun_program("\/system\/xbin\/su", "--install");/' !updater_script!
	!busybox! sed -i -e 's/!linereplace2!/!linereplace2!\nrun_program("\/system\/xbin\/su", "--install");/' !updater_script!
	mkdir WORK\system\bin\.ext
	!busybox! sed -i -e 's/!linereplace1!/!linereplace1!\nset_metadata("\/system\/bin\/.ext", "uid", 0, "gid", 0, "mode", 0777, "capabilities", 0x0, "selabel", "u:object_r:system_file:s0");/' !updater_script!
	!busybox! sed -i -e 's/!linereplace2!/!linereplace2!\nset_perm(0, 0, 0777, "\/system/bin\/.ext");/' !updater_script!
	copy !bin!\!su! WORK\system\bin\.ext\.su>nul
	!busybox! sed -i -e 's/!linereplace1!/!linereplace1!\nset_metadata("\/system\/bin\/.ext\/.su", "uid", 0, "gid", 0, "mode", !sumod!, "capabilities", 0x0, "selabel", "u:object_r:system_file:s0");/' !updater_script!
	!busybox! sed -i -e 's/!linereplace2!/!linereplace2!\nset_perm(0, 0, !sumod!, "\/system\/bin\/.ext\/.su");/' !updater_script!
	copy !bin!\!su! WORK\system\xbin\su>nul
	!busybox! sed -i -e 's/!linereplace1!/!linereplace1!\nset_metadata("\/system\/xbin\/su", "uid", 0, "gid", 0, "mode", !sumod!, "capabilities", 0x0, "selabel", "u:object_r:system_file:s0");/' !updater_script!
	!busybox! sed -i -e 's/!linereplace2!/!linereplace2!\nset_perm(0, 0, !sumod!, "\/system\/xbin\/su");/' !updater_script!
	copy !bin!\!su! WORK\system\xbin\daemonsu>nul
	!busybox! sed -i -e 's/!linereplace1!/!linereplace1!\nset_metadata("\/system\/xbin\/daemonsu", "uid", 0, "gid", 0, "mode", 0755, "capabilities", 0x0, "selabel", "u:object_r:system_file:s0");/' !updater_script!
	!busybox! sed -i -e 's/!linereplace2!/!linereplace2!\nset_perm(0, 0, 0755, "\/system\/xbin\/daemonsu");/' !updater_script!
	if !sugote! ==true copy !bin!\!su! WORK\system\xbin\sugote>nul
	if !sugote! ==true copy !mksh! WORK\system\xbin\sugote-mksh>nul
	if !sugote! ==true !busybox! sed -i -e 's/!linereplace1!/!linereplace1!\nset_metadata("\/system\/xbin\/sugote-mksh", "uid", 0, "gid", 0, "mode", 0755, "capabilities", 0x0, "selabel", "u:object_r:system_file:s0");/' !updater_script!
	if !sugote! ==true !busybox! sed -i -e 's/!linereplace1!/!linereplace1!\nset_metadata("\/system\/xbin\/sugote", "uid", 0, "gid", 0, "mode", 0755, "capabilities", 0x0, "selabel", "u:object_r:zygote_exec:s0");/' !updater_script!
	if !sugote! ==true !busybox! sed -i -e 's/!linereplace2!/!linereplace2!\nset_perm(0, 0, 0755, "\/system\/xbin\/sugote-mksh");/' !updater_script!
	if !sugote! ==true !busybox! sed -i -e 's/!linereplace2!/!linereplace2!\nset_perm(0, 0, 0755, "\/system\/xbin\/sugote");/' !updater_script!
	if !supolicy! ==true copy !bin!\supolicy WORK\system\xbin\supolicy>nul
	if !supolicy! ==true copy !bin!\libsupol.so !systemlib!\libsupol.so>nul
	if !supolicy! ==true !busybox! sed -i -e 's/!linereplace1!/!linereplace1!\nset_metadata("\/system\/xbin\/supolicy", "uid", 0, "gid", 0, "mode", 0755, "capabilities", 0x0, "selabel", "u:object_r:system_file:s0");/' !updater_script!
	if !supolicy! ==true !busybox! sed -i -e 's/!linereplace2!/!linereplace2!\nset_perm(0, 0, 0755, "\/system\/xbin\/supolicy");/' !updater_script!
	if !supolicy! ==true if exist "WORK/system/lib" !busybox! sed -i -e 's/!linereplace1!/!linereplace1!\nset_metadata("\/system\/lib\/libsupol.so", "uid", 0, "gid", 0, "mode", 0644, "capabilities", 0x0, "selabel", "u:object_r:system_file:s0");/' !updater_script!
	if !supolicy! ==true if exist "WORK/system/lib64" !busybox! sed -i -e 's/!linereplace1!/!linereplace1!\nset_metadata("\/system\/lib64\/libsupol.so", "uid", 0, "gid", 0, "mode", 0644, "capabilities", 0x0, "selabel", "u:object_r:system_file:s0");/' !updater_script!
	if !supolicy! ==true if exist "WORK/system/lib" !busybox! sed -i -e 's/!linereplace2!/!linereplace2!\nset_perm(0, 0, 0644, "\/system\/lib\/libsupol.so");/' !updater_script!
	if !supolicy! ==true if exist "WORK/system/lib64" !busybox! sed -i -e 's/!linereplace2!/!linereplace2!\nset_perm(0, 0, 0644, "\/system\/lib64\/libsupol.so");/' !updater_script!
	if !apkfolder! ==true if !fastwant! ==null mkdir WORK\system\app\SuperSU
	if !apkfolder! ==true if !fastwant! ==null !busybox! sed -i -e 's/!linereplace1!/!linereplace1!\nset_metadata("\/system\/app\/SuperSU", "uid", 0, "gid", 0, "mode", 0755, "capabilities", 0x0, "selabel", "u:object_r:system_file:s0");/' !updater_script!
	if !apkfolder! ==true if !fastwant! ==null !busybox! sed -i -e 's/!linereplace2!/!linereplace2!\nset_perm(0, 0, 0755, "\/system\/app\/SuperSU");/' !updater_script!
	if !fastwant! ==null copy !com!\superuser.apk !apkname!>nul
	if !fastwant! ==null if exist "WORK/system/app/supersu/supersu.apk" !busybox! sed -i -e 's/!linereplace1!/!linereplace1!\nset_metadata("\/system\/app\/SuperSU\/SuperSU.apk", "uid", 0, "gid", 0, "mode", 0644, "capabilities", 0x0, "selabel", "u:object_r:system_file:s0");/' !updater_script!
	if !fastwant! ==null if exist "WORK/system/app/supersu/supersu.apk" !busybox! sed -i -e 's/!linereplace2!/!linereplace2!\nset_perm(0, 0, 0644, "\/system\/app\/SuperSU\/SuperSU.apk");/' !updater_script!
	if !fastwant! ==null if exist "WORK/system/app/superuser.apk" !busybox! sed -i -e 's/!linereplace1!/!linereplace1!\nset_metadata("\/system\/app\/Superuser.apk", "uid", 0, "gid", 0, "mode", 0644, "capabilities", 0x0, "selabel", "u:object_r:system_file:s0");/' !updater_script!
	if !fastwant! ==null if exist "WORK/system/app/superuser.apk" !busybox! sed -i -e 's/!linereplace2!/!linereplace2!\nset_perm(0, 0, 0644, "\/system\/app\/Superuser.apk");/' !updater_script!
	copy !com!\install-recovery.sh WORK\system\etc\install-recovery.sh>nul
	!busybox! sed -i -e 's/!linereplace1!/!linereplace1!\nset_metadata("\/system\/etc\/install-recovery.sh", "uid", 0, "gid", 0, "mode", 0755, "capabilities", 0x0, "selabel", "u:object_r:system_file:s0");/' !updater_script!
	!busybox! sed -i -e 's/!linereplace2!/!linereplace2!\nset_perm(0, 0, 0755, "\/system\/etc\/install-recovery.sh");/' !updater_script!
	if !appprocess! ==true if exist "WORK\system\bin\app_process" !busybox! rm -f WORK/system/bin/app_process
	if !appprocess! ==true !busybox! sed -i -e 's/!linereplace3!/!linereplace3!\nsymlink("\/system\/xbin\/daemonsu", "\/system\/bin\/app_process");/' !updater_script! tools/tmp/original_symlinks
	if !appprocess! ==true !busybox! sed -i '/^symlink("app_process32", "\/system\/bin\/app_process");/d' !updater_script! tools/tmp/original_symlinks
	if !appprocess! ==true !busybox! sed -i '/^symlink("app_process64", "\/system\/bin\/app_process");/d' !updater_script! tools/tmp/original_symlinks
	if !appprocess! ==true if !appprocess64! ==true if not exist "WORK/system/bin/app_process64_original" !busybox! mv WORK\system\bin\app_process64 WORK\system\bin\app_process64_original
	if !appprocess! ==true if !appprocess64! ==true if exist "WORK/system/bin/app_process64_original" !busybox! rm WORK\system\bin\app_process64
	if !appprocess! ==true if !appprocess64! ==true !busybox! sed -i -e 's/!linereplace3!/!linereplace3!\nsymlink("\/system\/xbin\/daemonsu", "\/system\/bin\/app_process64");/' !updater_script! tools/tmp/original_symlinks
	if !appprocess! ==true if !appprocess64! ==true if not exist "WORK/system/bin/app_process_init" copy WORK\system\bin\app_process64_original WORK\system\bin\app_process_init>nul
	if !appprocess! ==true if !appprocess64! ==true !busybox! sed -i -e 's/!linereplace1!/!linereplace1!\nset_metadata("\/system\/bin\/app_process_init", "uid", 0, "gid", 2000, "mode", 0755, "capabilities", 0x0, "selabel", "u:object_r:system_file:s0");/' !updater_script!
	if !appprocess! ==true if !appprocess64! ==true !busybox! sed -i -e 's/!linereplace2!/!linereplace2!\nset_perm(0, 2000, 0755, "\/system\/bin\/app_process_init");/' !updater_script!i
	if !appprocess! ==true if not !appprocess64! ==true if not exist "WORK/system/bin/app_process32_original" move WORK\system\bin\app_process32 WORK\system\bin\app_process32_original>nul
	if !appprocess! ==true if not !appprocess64! ==true if exist "WORK/system/bin/app_process32_original" if exist "WORK/system/bin/app_process32" !busybox! rm "WORK/system/bin/app_process32"
	if !appprocess! ==true if not !appprocess64! ==true !busybox! sed -i -e 's/!linereplace3!/!linereplace3!\nsymlink("\/system\/xbin\/daemonsu", "\/system\/bin\/app_process32");/' !updater_script! tools/tmp/original_symlinks
	if !appprocess! ==true if not !appprocess64! ==true if not exist "WORK/system/bin/app_process_init" copy WORK\system\bin\app_process32_original WORK\system\bin\app_process_init>nul
	if !appprocess! ==true if not !appprocess64! ==true !busybox! sed -i -e 's/!linereplace1!/!linereplace1!\nset_metadata("\/system\/bin\/app_process_init", "uid", 0, "gid", 2000, "mode", 0755, "capabilities", 0x0, "selabel", "u:object_r:system_file:s0");/' !updater_script!
	if !appprocess! ==true if not !appprocess64! ==true !busybox! sed -i -e 's/!linereplace2!/!linereplace2!\nset_perm(0, 2000, 0755, "\/system\/bin\/app_process_init");/' !updater_script!
	if exist "WORK/system/etc/init.d" copy !com!\99supersudaemon WORK\system\etc\init.d\99supersudaemon>nul
	if exist "WORK/system/etc/init.d" !busybox! sed -i -e 's/!linereplace1!/!linereplace1!\nset_metadata("\/system\/etc\/init.d\/99supersudaemon", "uid", 0, "gid", 0, "mode", 0744, "capabilities", 0x0, "selabel", "u:object_r:system_file:s0");/' !updater_script!
	if exist "WORK/system/etc/init.d" !busybox! sed -i -e 's/!linereplace2!/!linereplace2!\nset_perm(0, 0, 0744, "\/system\/etc\/init.d\/99supersudaemon");/' !updater_script!
	echo 1 > WORK/system/etc/.installed_su_daemon
	goto completed
:patch_sepolicy
	if not exist "WORK\boot.img" (
		TOOLS\bin\cecho {#}NO KERNEL SUPPORTED FOUND IN WORK FOLDER CAN'T CONTINUE{#}
		echo.
		pause>nul
		goto:eof
	)
	if "%1"=="root" (
		echo UNPACKING THE KERNEL
		set kernelunpackq=y
		if exist "WORK\boot_unpacked" !busybox! rm -rf WORK/boot_unpacked
		call :kernelunpack
	)
	if not exist "WORK\boot_unpacked\ramdisk\sepolicy" (
		TOOLS\bin\cecho {0C}ERROR: NO [WORK/boot_unpacked/ramdisk/sepolicy] FOUND{#}
		pause>nul
		echo.
		if "%1"=="root" !busybox! rm -rf WORK/boot_unpacked
		goto:eof
	)
	echo DETECTING DEVICE RESPONSE
	call :device_response
	if "!error!"=="yes" (
		if "%1"=="root" !busybox! rm -rf WORK/boot_unpacked
		goto:eof
	)
	tools\bin\adb shell mount /system >nul
	for /f "delims=" %%a in ('tools\bin\adb shell supolicy ^| !busybox! wc -l') do if %%a leq 1 for /f "delims=" %%a in ('tools\bin\adb shell /system/xbin/supolicy ^| !busybox! wc -l') do if %%a leq 1 (
		TOOLS\bin\cecho {0C}AN ERROR HAPPENED DURING EXECUTE [supolicy] CAN'T CONTINUE{#}
		echo.
		if "%1"=="root" !busybox! rm -rf WORK/boot_unpacked
		pause>nul
		goto:eof
	)
	echo PATCHING [sepolicy]
	tools\bin\adb push WORK/boot_unpacked/ramdisk/sepolicy /data/local/tmp/sepolicy >nul
	tools\bin\adb shell "chmod 0755 /data/local/tmp/sepolicy" >nul
	tools\bin\adb shell "supolicy --file /data/local/tmp/sepolicy /data/local/tmp/sepolicy_patched" >nul
	tools\bin\adb shell "chmod 0755 /data/local/tmp/sepolicy_patched" >nul
	tools\bin\adb pull /data/local/tmp/sepolicy_patched WORK/sepolicy >nul
	tools\bin\adb shell "rm -rf /data/local/tmp/*" >nul
	if not exist "WORK\sepolicy" (
		tools\bin\adb push WORK/boot_unpacked/ramdisk/sepolicy /data/local/tmp/sepolicy >nul
		tools\bin\adb shell "chmod 0755 /data/local/tmp/sepolicy" >nul
		tools\bin\adb shell "/system/xbin/supolicy --file /data/local/tmp/sepolicy /data/local/tmp/sepolicy_patched" >nul
		tools\bin\adb shell "chmod 0755 /data/local/tmp/sepolicy_patched" >nul
		tools\bin\adb pull /data/local/tmp/sepolicy_patched WORK/sepolicy >nul
		tools\bin\adb shell "rm -rf /data/local/tmp/*" >nul
	)
	if not exist "WORK\sepolicy" (
		tools\bin\cecho {0C}UNKNOWN ERROR HAPPENED CAN'T PATCHING{#}
		echo.
		if "%1"=="root" !busybox! rm -rf WORK/boot_unpacked
		pause>nul
		goto:eof
	)
	echo THE [sepolicy] PATCHED SUCCESSFULLY
	move WORK\boot_unpacked\ramdisk\sepolicy TOOLS\tmp\sepolicy_original >nul
	move WORK\sepolicy WORK\boot_unpacked\ramdisk\sepolicy >nul
	if "%1"=="root" (
		echo REPACKING THE KERNEL
		set kernelunpackq=y
		call :kernelpack
	)
	goto:eof
:busybox
	set needsed=n
	if not exist "WORK\system" (
		echo NO ROM FOUND TO ADD BUSYBOX
		pause>nul
		goto start
	)
	if exist "WORK\system\xbin\busybox" if exist "WORK\system\addon.d" if not exist "WORK\system\bin\toybox" (
		echo THIS KIND OF ROMS NEED BUSYBOX FOR BOOT AND SYMLINKS AND CAN'T REMOVE IT
		pause>nul
		goto start
	)
	if exist "WORK\system\xbin\busybox" (
		set needsed=y
		echo REMOVING BUSYBOX
		!busybox! rm WORK/system/bin/busybox 
		!busybox! rm WORK/system/xbin/busybox 
	)
	if exist "WORK\system\bin\busybox" (
		set needsed=y
		echo REMOVING BUSYBOX
		!busybox! rm WORK/system/bin/busybox 
		!busybox! rm WORK/system/xbin/busybox
	)
	set line1=set_metadata_recursive("\/system\/xbin", "uid", 0, "gid", 2000, "dmode", 0755, "fmode", 0755, "capabilities", 0x0, "selabel", "u:object_r:system_file:s0");
	set line2=set_metadata_recursive("\/system\/xbin", "uid", 0, "gid", 2000, "dmode", 0755, "fmode", 0755, "capabilities", "0x0", "selabel", "u:object_r:system_file:s0");
	set line3=symlink("Roboto-Regular.ttf", "\/system\/fonts\/DroidSans.ttf");
	set line4=symlink("\/system\/xbin\/busybox", "\/system\/bin\/busybox");
	set line5=run_program("\/system\/xbin\/busybox", "--install", "-s", "\/system\/xbin");
	set line6=set_perm(0, 1000, 0755, "\/system\/xbin\/busybox");
	set line7=set_perm_recursive(0, 2000, 0755, 0755, "\/system\/xbin");
	if !needsed! ==y !busybox! sed -i '/^!line6!/d' !updater_script!
	if !needsed! ==y !busybox! sed -i '/^!line4!/d' !updater_script! tools/tmp/original_symlinks
	if !needsed! ==y !busybox! sed -i '/^!line5!/d' !updater_script!
	if !needsed! ==y goto completed
	set decidebusybox=busy
	if not !busyboxq! ==y (
		echo BUSYBOX IS A SCRIPT TO RUN LINUX COMMANDS IN ANDROID DEVICE
		echo AND IT IS NECESARY FOR CUSTOM ROMS TO RUN SOME APPS
		set /p decidebusybox=DO YOU WANT TO ADD IT OR NOT [DEFAULT=YES 0=NO]:
		if "!decidebusybox!"=="0" goto start
		echo INSTALLING BUSYBOX
	)
	if not exist "WORK\system\xbin" mkdir WORK\system\xbin
	echo .>>TOOLS\tmp\!architecture!
	set busyboxtype=nul
	if exist "TOOLS\tmp\arm*" set busyboxtype=arm
	if exist "TOOLS\tmp\arm64*" set busyboxtype=arm64
	if exist "TOOLS\tmp\x86*" set busyboxtype=x86
	if exist "TOOLS\tmp\x86_64*" set busyboxtype=x86_64
	if exist "TOOLS\tmp\mips*" set busyboxtype=mips
	if exist "TOOLS\tmp\mips64*" set busyboxtype=mips64
	del TOOLS\tmp\!architecture!
	copy "TOOLS\xbin\busybox_!busyboxtype!" "WORK\system\xbin\busybox">nul
	!busybox! sed -i -e 's/!line1!/!line1!\n!line5!/' !updater_script!
	!busybox! sed -i -e 's/!line2!/!line2!\n!line5!/' !updater_script!
	!busybox! sed -i -e 's/!line7!/!line7!\n!line6!\n!line5!/' !updater_script!
	!busybox! sed -i -e 's/!line3!/!line3!\n!line4!/' !updater_script! tools/tmp/original_symlinks
	if not !busyboxq! ==y goto completed
	if !busyboxq! ==y goto:eof
:get_kernel_file_contexts
	if !api! geq 19 (
		set delete=n
		echo GETTING [file_contexts]
		if not exist "WORK\file_contexts*" (
			set kernelunpackq=y
			call :kernelunpack
			set delete=y
			for %%a in (WORK\boot_unpacked\ramdisk\file_contexts*) do copy %%a WORK\%%~na%%~xa >nul
			!busybox! rm -rf WORK\boot_unpacked
		)
		if exist "WORK\file_contexts.bin" copy WORK\file_contexts.bin TOOLS\tmp\file_contexts.bin >nul
		if exist "WORK\file_contexts" copy WORK\file_contexts TOOLS\tmp\kernel_file_contexts >nul
		if exist "TOOLS\tmp\file_contexts.bin" (
			!busybox! strings TOOLS/tmp/file_contexts.bin | !busybox! sed -n "/u:/,$p" | !busybox! grep -B 1 "/" | !busybox! grep "/">>TOOLS\tmp\files_decoded
			!busybox! strings TOOLS/tmp/file_contexts.bin | !busybox! sed -n "/u:/,$p" | !busybox! grep -B 1 "/" | !busybox! grep "u:">>TOOLS\tmp\contexts_decoded
			del TOOLS\tmp\*file_contexts*
			TOOLS\bin\paste TOOLS/tmp/files_decoded TOOLS/tmp/contexts_decoded | !busybox! sort>>TOOLS\tmp\kernel_file_contexts
			del TOOLS\tmp\*decoded
		)
		if not exist "TOOLS\tmp\kernel_file_contexts" (
			TOOLS\bin\cecho {0C}FAILED TO GET [file_contexts]{#}
			echo.
			echo THIS FILE IS IMPORTANT TO CONTINUE
			echo IF YOU HAVE THIS FILE COPY IT TO [TOOLS\tmp\kernel_file_contexts]
			echo OTHERWISE THE ROM MAYBE CONTENTS BUGS AND MAYBE DOESN'T BOOT
			set /p wait=PRESS ENTER WHEN READY TO CONTINUE
		)
		if "!delete!"=="y" del WORK\file_contexts*
	)
	goto:eof
:prepare_installing
	if not exist "WORK\system\build.prop" (
		echo THERE IS NO PROJECT IN WORK FOLDER CREATE PROJECT FIRST
		pause>nul
		goto start
	)
	for /f "delims=" %%a in ('!busybox! grep -i -m 1 "ro.product.manufacturer=" "WORK/system/build.prop" ^| !busybox! cut -d"=" -f2') do set factory=%%a
	for /f "delims=" %%a in ('!busybox! grep "ro.build.version.sdk=" WORK/system/build.prop ^| !busybox! cut -d"=" -f2-') do set api=%%a
	set search_kernel=n
	if not "!select!"=="7" if not exist "WORK\file_contexts*" if not "!select!"=="18" if "!api!" geq "20" if not exist "TOOLS\tmp\kernel_file_contexts" if not exist "WORK\boot.img" if not exist "WORK\kernel.sin.bak" (
		echo THIS ROM IS [Lollipop+] WE NEED TO SEARCH FOR KERNEL TO CONTINUE
		set /p search_kernel=DO YOU WANT TO SEARCH FOR KERNEL [DEFAULT=YES 0=NO]:
	)
	if not "!select!"=="7" if not exist "WORK\file_contexts*" if not "!select!"=="18" if "!api!" geq "20" if not exist "TOOLS\tmp\kernel_file_contexts" if not exist "WORK\boot.img" if not exist "WORK\kernel.sin.bak" if not "!search_kernel!"=="0" (
		set search_q=y
		call :grepboot
	)
	if exist !updater_script! if not exist "TOOLS\tmp\original_symlinks" (
		echo GETTING SYMLINKS LINES FROM [update-script]
		!busybox! grep -w symlink !updater_script! >> TOOLS\tmp\symlinks1
		!busybox! grep ',$' TOOLS\tmp\symlinks1 >> TOOLS\tmp\symlinks2
		for /f "delims=" %%a in ('!busybox! grep -c "symlink" "TOOLS\tmp\symlinks2"') do set number_test=%%a
	)
	if exist !updater_script! if not exist "TOOLS\tmp\original_symlinks" if not "!number_test!"=="0" for /f "delims=" %%a in ('type "TOOLS\tmp\symlinks2"') do (
		for /f "delims=" %%b in ('echo %%a ^| TOOLS\bin\gawk "{print $1}"') do set first_file=%%b
		set line=%%a
		set edit=!line:"=\"!
		set edit=!edit: =\ !
		set edit=!edit:/=\/!
		set edit=!edit:[=\[!
		set line2=!edit!
		!busybox! sed -n "/!line2!/,/;/p" !updater_script! >> TOOLS\tmp\links
		set first_file2=!first_file:"=\"!
		!busybox! sed -i "s/!first_file2!//" TOOLS\tmp\links
		for /f "delims=" %%b in ('type "TOOLS\tmp\links"') do echo %%b | !busybox! tr ',' '\n' | !busybox! sed "s/);//" >> TOOLS\tmp\links2
		TOOLS\bin\gawk "{print $1}" TOOLS\tmp\links2 >> TOOLS\tmp\links3
		!busybox! mv TOOLS\tmp\links3 TOOLS\tmp\links2
		!busybox! sed -i "/^$/d" TOOLS\tmp\links2
		for /f "delims=" %%b in ('type "TOOLS\tmp\links2"') do echo !first_file! %%b;;;>>TOOLS\tmp\last
		!busybox! sed -i "s/;;;/);/" TOOLS\tmp\last
		del TOOLS\tmp\links TOOLS\tmp\links2
	)
	if exist "TOOLS\tmp\symlinks1" !busybox! grep -v ',$' TOOLS\tmp\symlinks1 >> TOOLS\tmp\symlinks3
	if exist "TOOLS\tmp\symlinks3" type TOOLS\tmp\symlinks3 >> TOOLS\tmp\last
	TOOLS\bin\dos2unix -q TOOLS\tmp\last
	if exist "TOOLS\tmp\last" TOOLS\bin\gawk "{print $1, $2}" TOOLS\tmp\last >> TOOLS\tmp\last2
	TOOLS\bin\dos2unix -q TOOLS\tmp\last2
	if not exist "TOOLS\tmp\original_symlinks" !busybox! sort -u < TOOLS\tmp\last2 > TOOLS\tmp\original_symlinks
	TOOLS\bin\dos2unix -q TOOLS\tmp\original_symlinks
	del TOOLS\tmp\symlinks1 TOOLS\tmp\symlinks2 TOOLS\tmp\symlinks3 TOOLS\tmp\last TOOLS\tmp\last2
	for /f "delims=" %%a in ('!busybox! grep -cw "symlink" tools/tmp/original_symlinks') do if "%%a"=="0" del TOOLS\tmp\original_symlinks
	if not exist "TOOLS\tmp\kernel_file_contexts" if exist "WORK\boot.img" call :get_kernel_file_contexts
	if !api! geq 20 if not exist "tools\tmp\kernel_file_contexts" if exist "work\kernel.sin.bak" (
		mkdir WORK\kernel
		copy WORK\kernel.sin.bak WORK\kernel\kernel.sin >nul
		echo BECAUSE OF THIS ROM IS [Lollipop+] AND CONTENTS [kernel.sin]
		echo INSTEAD OF [boot.img] WE FAILED IN CONVERTING AND WE NEED [file_contexts]
		echo FILE FROM THE KERNEL SO YOU SHOULD UNPACK [WORK\kernel\kernel.sin] USING FLASHTOOL
		echo TO GET [kernel.elf] IN THE SAME PLACE TO CONVERTING TO [boot.img]
		set /p wait=PRESS ENTER WHEN READY
		if not exist "WORK\kernel\kernel.elf" if not exist "WORK\file_contexts" (
			TOOLS\bin\cecho {0C}ERROR: NO [kernel.elf] AND NO [file_contexts] FOUND THE ROM MAY BE UNSTABLE{#}
			echo.
		)
		if exist "WORK\kernel\kernel.elf" (
			echo CONVERTING [kernel.elf] TO [boot.img]
			mkdir WORK\elf_convert
			copy WORK\kernel\kernel.elf WORK\elf_convert\kernel.elf >nul
			call :convert_elf2img WORK
			if exist "WORK\elf_convert\boot.img" (
				echo THE [kernel.elf] CONVERTED SUCCESSFULLY
				move WORK\elf_convert\boot.img WORK\boot.img >nul
				!busybox! rm -rf WORK/kernel WORK/kernel.sin.bak WORK/elf_convert
				goto prepare_installing
			)
		)
		if not exist "TOOLS\tmp\kernel_file_contexts" (
			echo ERROR DURING EXTRACT [file_contexts] SO YOU NEED TO UNPACK
			echo [kernel.elf] USING FLASHTOOL TOO AND YOU WILL GET [ramdisk] FILE
			echo EXTRACT [file_contexts] FROM [ramdisk] USING ANY ZIP APPLICATION [7zip]....ETC
			echo AND PUT IT IN WORK FOLDER
			set /p press_enter=PRESS ENTER WHEN YOU FINISH
			move work\file_contexts tools\tmp\kernel_file_contexts >nul
		)
	)
	if exist "WORK\kernel" !busybox! rm -rf WORK/kernel
	if "!select!"=="1" (
		echo DETECTING SYSTEM SYMLINKS
		call :write_symlinks
	)
	if "!select!"=="18" goto decidebuild
	if "!select!"=="7" goto decidebuild
:metainfb
	if exist "TOOLS\tmp\original_installer" (
		echo NOTE: IF YOU WANT TO WORK WITH THE CURRENT META-INF AS ORIGINAL ONE YOU
		echo SHOULD REMOVE [TOOLS\tmp\original_installer] THEN REBACK TO THIS COMMAND
	)
	set installer_choice=n
	if exist "TOOLS\tmp\original_installer" set /p installer_choice=RESTORE ORIGINAL INSTALLER OR NOT [DEFAULT=NO 1=YES]:
	if exist "TOOLS\tmp\original_installer" if not "!installer_choice!"=="1" goto start
	if exist "TOOLS\tmp\original_installer" (
		echo RESTORING ORIGINAL INSTALLER
		!busybox! rm -rf WORK\META-INF
		for /f %%m in ('dir TOOLS\tmp\original_installer /b') do move TOOLS\tmp\original_installer\%%m WORK\%%m >nul
		!busybox! rm -rf TOOLS\tmp\original_installer
		goto completed
	)
	if not exist "WORK\META-INF" goto decideinstaller
	if exist "WORK\META-INF\SCRIPTS\auto.sh" del WORK\META-INF\SCRIPTS\auto.sh
	set choicee=aa
	ECHO NOTE: THE ORIGINAL META-INF (INSTALLER) WILL SAVE TO RESTORE BY SAME COMMAND
	ECHO AND WE WILL MOVE ALL INSTALLER'S FILES AND FOLDERS EXCEPT [data, supersu]
	ECHO IF EXIST BECAUSE NEW INSTALLER WILL NOT USE THEM
	if not exist "TOOLS\tmp\original_installer" if exist "WORK\META-INF" set /p choicee=SAVING CURRENT META-INF AND ADD NEW ONE [DEFAULT=NO 1=YES]:
	if not "%choicee%"=="1" goto start
	echo SAVING CURRENT INSTALLER TO [TOOLS\tmp\original_installer]
	mkdir TOOLS\tmp\original_installer
	for /f %%m in ('dir WORK /b') do if not "%%m"=="recovery_unpacked" if not "%%m"=="recovery_packed" if not "%%m"=="boot_unpacked" if not "%%m"=="boot_packed" if not "%%m"=="BLOAT" if not "%%m"=="KNOX" if not "%%m"=="system" if not "%%m"=="boot.img" if not "%%m"=="kernel.sin" if not "%%m"=="kernel.sin.bak" move WORK\%%m TOOLS\tmp\original_installer\%%m >nul
	!busybox! cp -rf TOOLS/tmp/original_installer/data WORK/data
	!busybox! cp -rf TOOLS/tmp/original_installer/supersu WORK/supersu
	!busybox! cp -rf TOOLS/tmp/original_installer/META-INF/ADD-ONS/supersu WORK/supersu
	goto decideinstaller
	if exist "WORK\META-INF" set choicee=aa
	if exist "WORK\META-INF" goto metainfb
:decideinstaller
	set metatype=77
	set /p metatype=WHAT INSTALLER YOU WANT [1=AROMA 2=STANDALONE DEFAULT=BACK_TO_MAIN_MENU]:
	if "!metatype!"=="1" (
		echo BUILDING AROMA INSTALLER
		goto metaaroma
	)
	if "!metatype!"=="2" (
		echo BUILDING STANDALONE INSTALLER
		goto metastan
	)
	goto start
:metaaroma
	if not exist "WORK\META-INF" xcopy "TOOLS\installer\aroma\META-INF" "WORK\META-INF" /e /i /h /y >nul
	xcopy TOOLS\tmp\original_installer\META-INF\ADD-ONS\data WORK\META-INF\ADD-ONS\DATA /e /i /h /y >nul
	if exist "WORK\data" (
		xcopy "WORK\data" "WORK\META-INF\ADD-ONS\data" /e /i /h /y>nul
		rmdir /s /q WORK\data
	)
	move WORK\supersu WORK\META-INF\ADD-ONS\supersu >nul
	if exist "WORK\system\addon.d" if not exist "WORK\META-INF\ADD-ONS\install" (
		mkdir WORK\META-INF\ADD-ONS\install
		xcopy TOOLS\installer\addond\install WORK\META-INF\ADD-ONS\install /e /i /h /y>nul
	)
	set rom_name_ar=
	set rom_version=
	set rom_developer=
	set device_name=
	set android_version=
	set /p rom_name_ar=TYPE THE ROM NAME [AROMA INFO]:
	set /p rom_version=TYPE THE ROM VERSION [AROMA INFO]:
	set /p rom_developer=TYPE THE DEVELOPER NAME [AROMA INFO]:
	set /p device_name=TYPE THE DEVICE NAME [AROMA INFO]:
	set /p android_version=TYPE THE ANDROID NAME-VERSION [AROMA INFO]:
	set license=null
	set license_f=WORK/META-INF/com/google/android/aroma/license.txt
	set change_log_f=WORK/META-INF/com/google/android/aroma/changelog.txt
	set /p license=ADD LICENSE TO AROMA OR NOT [1=YES DEFAULT=NO]:
	if "!license!"=="1" (
		echo x>>!license_f!
		TOOLS\bin\dos2unix -q !license_f!>nul
		!busybox! sed -i '/^x/d' "!license_f!">nul
	)
	set changelog=null
	set /p changelog=ADD CHANGELOG TO AROMA OR NOT [1=YES DEFAULT=NO]:
	if "!changelog!"=="1" (
		echo x>>!change_log_f!
		TOOLS\bin\dos2unix -q !change_log_f!>nul
		!busybox! sed -i '/^x/d' "!change_log_f!">nul
	)
	set aroma_line=#################################################################################################################################################################
	echo WRITTING [aroma-config]
	if exist !aroma_config! del !aroma_config!
	echo # AUTO GENERATED BY ASSAYYED KITCHEN >> !aroma_config!
	echo !aroma_line! >> !aroma_config!
	echo ini_set("force_colorspace", "rgba");>> !aroma_config!
	echo ini_set("rom_name",             "%rom_name_ar% ROM");>> !aroma_config!
	echo ini_set("rom_version",          "%rom_version%");>> !aroma_config!
	echo ini_set("rom_author",           "%rom_developer%");>> !aroma_config!
	echo ini_set("rom_device",           "%device_name%");>> !aroma_config!
	echo ini_set("rom_date",             "%date%");>> !aroma_config!
	echo !aroma_line!>> !aroma_config!
	echo fontresload( "0", "ttf/DroidSans.ttf;ttf/DroidSansArabic.ttf;ttf/DroidSansFallback.ttf;", "12" );>> !aroma_config!
	echo theme("touchwiz");>> !aroma_config!
	echo !aroma_line!>> !aroma_config!
	echo viewbox(>> !aroma_config!
	echo "WELCOME",>> !aroma_config!
	echo "INSTALL <b>"+>> !aroma_config!
	echo ini_get("rom_name")+>> !aroma_config!
	echo "</b> FOR <b>"+ini_get("rom_device")+"</b>.\n\n"+>> !aroma_config!
	echo "INFORMATION OF THE ROM:\n\n"+>> !aroma_config!
	echo " THE NAME \t: <b><#selectbg_g>"+ini_get("rom_name")+"</#></b>\n"+>> !aroma_config!
	echo " THE VERSION\t: <b><#selectbg_g>"+ini_get("rom_version")+"</#></b>\n"+>> !aroma_config!
	echo " THE DATE\t: <b><#selectbg_g>"+ini_get("rom_date")+"</#></b>\n"+>> !aroma_config!
	echo " THE DEVELPER\t: <b><#selectbg_g>"+ini_get("rom_author")+"</#></b>\n"+>> !aroma_config!
	echo "<b><#f00>ONLY FOR !device_name!</#></b>\n\n\n"+	>> !aroma_config!
	echo "PRESS NEXT TO CONTINUE",>> !aroma_config!
	echo "@welcome">> !aroma_config!
	echo );>> !aroma_config!
	set s1=if exist "WORK\META-INF\com\google\android\aroma\license.txt"
	set s2=if exist "WORK\META-INF\com\google\android\aroma\changelog.txt"
	%s1% echo !aroma_line!>> !aroma_config!
	%s1% echo agreebox(>> !aroma_config!
	%s1% echo "TERMS AND CONDITIONS",>> !aroma_config!
	%s1% echo "TERMS AND CONDITIONS",>> !aroma_config!
	%s1% echo "@license",>> !aroma_config!
	%s1% echo resread("license.txt"),>> !aroma_config!
	%s1% echo "I AGREE WITH TERMS AND CONDITIONS",>> !aroma_config!
	%s1% echo "YOU MUST AGREE WITH TERMS AND CONDITIONS FIRST">> !aroma_config!
	%s1% echo );>> !aroma_config!
	%s2% echo !aroma_line!>> !aroma_config!
	%s2% echo textbox(>> !aroma_config!
	%s2% echo "CHANGE LOG",>> !aroma_config!
	%s2% echo "ROM CHANGE LOG",>> !aroma_config!
	%s2% echo "@agreement",>> !aroma_config!
	%s2% echo resread("changelog.txt")>> !aroma_config!
	%s2% echo );>> !aroma_config!
	echo !aroma_line!>> !aroma_config!
	echo checkbox(>> !aroma_config!
	echo "OPTIONS",>> !aroma_config!
	echo "SELECT WHAT YOU WANT TO DO:",>> !aroma_config!
	echo "@personalize",>> !aroma_config!
	echo "opt.prop",>> !aroma_config!
	echo "INSTALLTION OPTIONS",                                                                                "",          2,>> !aroma_config!
	IF "!factory!"=="samsung" echo "BACKUP EFS","RECOMMENDED",                                                  0, >> !aroma_config!
	echo "SAFE FORMAT","WIPE USER DATA WITHOUT INTERNAL STORAGE",                                               0, >> !aroma_config!
	echo "HARD FORMAT","WARNING: DELETE ALL DATA PARTITION WITH INTERNAL STORAGE",                              0  >> !aroma_config!
	echo );>> !aroma_config!
	echo !aroma_line!>> !aroma_config!
	echo viewbox(>> !aroma_config!
	echo "NOW THE INSTALLATION READY TO START",>> !aroma_config!
	echo "PRESS NEXT TO CONTINUE TO START\n"+>> !aroma_config!
	echo "TO CHANGE YOUR OPTIONS PRESS BACK",>> !aroma_config!
	echo "@flashing">> !aroma_config!
	echo );>> !aroma_config!
	echo !aroma_line!>> !aroma_config!
	echo setvar("retstatus",>> !aroma_config!
	echo install(>> !aroma_config!
	echo "",>> !aroma_config!
	echo "<b>"+ini_get("rom_name")+"</b> INSTALLATION\n"+>> !aroma_config!
	echo "PLEASE WAIT WHILE INSTALLATION FINISHING INSTALLING <b>"+ini_get("rom_name")+>> !aroma_config!
	echo "</b> THIS PROCESS WILL TAKE SOME TIME",	>> !aroma_config!
	echo "@install",	>> !aroma_config!
	echo "THE INSTALLATION FINISHED FROM INSTALLING <b>"+ini_get("rom_name")+>> !aroma_config!
	echo "</b> PRESS NEXT TO CONTINUE">> !aroma_config!
	echo )>> !aroma_config!
	echo );>> !aroma_config!
	echo !aroma_line!>> !aroma_config!
	echo checkviewbox(>> !aroma_config!
	echo "",>> !aroma_config!
	echo "<#selectbg_g><b>INSTALLTION COMPLETED</b></#>\n\n"+>> !aroma_config!
	echo "<b>"+ini_get("rom_name")+"</b> NOW INSTALLED IN YOUR PHONE",>> !aroma_config!
	echo "@welcome",>> !aroma_config!
	echo "REBOOT DEVICE",>> !aroma_config!
	echo "1",>> !aroma_config!
	echo "reboot_it">> !aroma_config!
	echo );>> !aroma_config!
	echo if>> !aroma_config!
	echo getvar("reboot_it")=="1">> !aroma_config!
	echo then>> !aroma_config!
	echo reboot("onfinish");>> !aroma_config!
	echo endif;>> !aroma_config!
	TOOLS\bin\dos2unix -q !aroma_config!>nul
	if exist !updater_script! del !updater_script!
	echo # AUTO GENERATED BY ASSAYYED KITCHEN >> !updater_script!
	echo #--INFORMATION>> !updater_script!
	echo WRITTING [updater-script]
	echo ui_print("************************************************");>> !updater_script!
	echo ui_print("* Installing !rom_name_ar! ROM");>> !updater_script!
	echo ui_print("* For !device_name!");>> !updater_script!
	echo ui_print("* Running android !android_version!");>> !updater_script!
	echo ui_print("* Developed by !rom_developer!");>> !updater_script!
	echo ui_print("************************************************");>> !updater_script!
	echo set_progress(0.10);>> !updater_script!
	echo #--PREPARE DEVICE PARTITIONS>> !updater_script!
	echo ui_print("-- Preparing device partitions");>> !updater_script!
	echo package_extract_dir("META-INF/SCRIPTS", "/tmp");>> !updater_script!
	echo run_program("/sbin/mount", "-t", "auto", "/system");>> !updater_script!
	echo run_program("/sbin/mount", "-t", "auto", "/data");>> !updater_script!
	set s1=if exist "WORK\META-INF\ADD-ONS\install"
	%s1% echo ui_print("-- Backing up addon.d scripts");>> !updater_script!
	%s1% echo package_extract_dir("META-INF/ADD-ONS/install", "/tmp/install");>> !updater_script!
	%s1% echo set_metadata_recursive("/tmp/install", "uid", 0, "gid", 0, "dmode", 0755, "fmode", 0644);>> !updater_script!
	%s1% echo set_metadata_recursive("/tmp/install/bin", "uid", 0, "gid", 0, "dmode", 0755, "fmode", 0755);>> !updater_script!
	%s1% echo run_program("/tmp/install/bin/backuptool.sh", "backup");>> !updater_script!
	echo delete_recursive("/system");>> !updater_script!
	echo #--AROMA OPTIONS>> !updater_script!
	echo set_progress(0.20);>> !updater_script!
	if "!factory!"=="samsung" echo if file_getprop("/tmp/aroma/opt.prop", "item.1.1") == "1" then >> !updater_script!
	if "!factory!"=="samsung" echo ui_print("-- Backing up efs partition");>> !updater_script!
	if "!factory!"=="samsung" echo set_metadata("/tmp/efs_backup.sh", "uid", 0, "gid", 0, "mode", 0777);>> !updater_script!
	if "!factory!"=="samsung" echo run_program("/tmp/efs_backup.sh");>> !updater_script!
	if "!factory!"=="samsung" echo else>> !updater_script!
	if "!factory!"=="samsung" echo ui_print("-- Continue without efs backup");>> !updater_script!
	if "!factory!"=="samsung" echo endif;>> !updater_script!
	if "!factory!"=="samsung" echo if file_getprop("/tmp/aroma/opt.prop", "item.1.2") == "1" then >> !updater_script!
	if not "!factory!"=="samsung" echo if file_getprop("/tmp/aroma/opt.prop", "item.1.1") == "1" then >> !updater_script!
	echo ui_print("-- Wiping all user data files");>> !updater_script!
	echo set_metadata("/tmp/wipe.sh", "uid", 0, "gid", 0, "mode", 0777);>> !updater_script!
	echo run_program("/tmp/wipe.sh");>> !updater_script!
	echo else>> !updater_script!
	echo ui_print("-- Continue without safe format");>> !updater_script!
	echo endif;>> !updater_script!
	if "!factory!"=="samsung" echo if file_getprop("/tmp/aroma/opt.prop", "item.1.3") == "1" then >> !updater_script!
	if not "!factory!"=="samsung" echo if file_getprop("/tmp/aroma/opt.prop", "item.1.2") == "1" then >> !updater_script!
	echo ui_print("-- Cleaning up all device partitions");>> !updater_script!
	echo delete_recursive("/system");>> !updater_script!
	echo delete_recursive("/sdcard");>> !updater_script!
	echo delete_recursive("/data");>> !updater_script!
	echo delete_recursive("/cache");>> !updater_script!
	echo delete_recursive("/preload");>> !updater_script!
	echo else>> !updater_script!
	echo ui_print("-- Continue without hard format");>> !updater_script!
	echo endif;>> !updater_script!
	echo #--INSTALLATION>> !updater_script!
	echo show_progress(0.7, xxxx);>> !updater_script!
	echo ui_print("-- Extracting system & data");>> !updater_script!
	echo package_extract_dir("system", "/system");>> !updater_script!
	echo package_extract_dir("META-INF/ADD-ONS/DATA", "/data");>> !updater_script!
	echo #--SYMLINKS>> !updater_script!
	echo ui_print("-- Creating symbolic links");>> !updater_script!
	echo set_progress(0.93);>> !updater_script!
	call :write_symlinks
	echo #--PERMISSIONS>> !updater_script!
	echo ui_print("-- Setting & fixing permissions");>> !updater_script!
	echo set_progress(0.95);>> !updater_script!
	call :write_permissions
	call :last_updater
	echo #--FINISH>> !updater_script!
	echo ui_print("-- Finishing installation");>> !updater_script!
	echo set_progress(1.00);>> !updater_script!>> !updater_script!
	echo ifelse(is_mounted("/system"), unmount("/system")); >> !updater_script!
	echo ui_print("Installation completed successfully");>> !updater_script!
	TOOLS\bin\dos2unix -q !updater_script!>nul
	if exist "WORK/META-INF/com/google/android/aroma/*.txt" (
		echo YOU CAN NOW WRITE LICENSE IN [WORK\META-INF\com\google\android\aroma\license.txt]
		echo AND WRITE ROM CHANGE LOG IN [WORK\META-INF\com\google\android\aroma\changelog.txt]
		TOOLS\bin\cecho {0E}VERY IMPORTANT: USE [Notepad++] ONLY TO EDIT THE ABOVE FILES{#}
		echo.
	)
	goto completed
:metastan
	if not exist "WORK\META-INF" xcopy "TOOLS\installer\standalone\META-INF" "WORK\META-INF" /e /i /h /y >nul
	xcopy TOOLS\tmp\original_installer\META-INF\ADD-ONS\data WORK\META-INF\ADD-ONS\data /e /i /h /y >nul
	if exist "WORK\data" (
		xcopy "WORK\data" "WORK\META-INF\ADD-ONS\data" /e /i /h /y >nul
		rmdir /s /q WORK\data
	)
	move WORK\supersu WORK\META-INF\ADD-ONS\supersu >nul
	if exist "WORK\system\addon.d" if not exist "WORK\META-INF\ADD-ONS\install" (
		mkdir WORK\META-INF\ADD-ONS\install
		xcopy TOOLS\installer\addond\install WORK\META-INF\ADD-ONS\install /e /i /h /y>nul
	)
	set rom_name=
	set /p rom_name=TYPE THE ROM NAME [SHOW DURING INSTALLATION]:
	if exist !updater_script! del !updater_script!
	echo # AUTO GENERATED BY ASSAYYED KITCHEN >> !updater_script!
	echo #--INFORMATION>> !updater_script!
	echo WRITTING [updater-script]
	echo ui_print(" "); ui_print("INSTALLING !rom_name! ROM STARTED");>> !updater_script!
	echo #--PREPARE DEVICE PARTITIONS>> !updater_script!
	echo ui_print("-- Preparing device partitions");>> !updater_script!
	echo package_extract_dir("META-INF/SCRIPTS", "/tmp");>> !updater_script!
	echo run_program("/sbin/mount", "-t", "auto", "/system");>> !updater_script!
	echo run_program("/sbin/mount", "-t", "auto", "/data");>> !updater_script!
	set s1=if exist "WORK\META-INF\ADD-ONS\install"
	%s1% echo ui_print("-- Backing up addon.d scripts");>> !updater_script!
	%s1% echo package_extract_dir("META-INF/ADD-ONS/install", "/tmp/install");>> !updater_script!
	%s1% echo set_metadata_recursive("/tmp/install", "uid", 0, "gid", 0, "dmode", 0755, "fmode", 0644);>> !updater_script!
	%s1% echo set_metadata_recursive("/tmp/install/bin", "uid", 0, "gid", 0, "dmode", 0755, "fmode", 0755);>> !updater_script!
	%s1% echo run_program("/tmp/install/bin/backuptool.sh", "backup");>> !updater_script!
	if exist "WORK\META-INF\SCRIPTS\efs_backup.sh" echo ui_print("-- Backing up efs partition");>> !updater_script!
	if exist "WORK\META-INF\SCRIPTS\efs_backup.sh" echo set_metadata("/tmp/efs_backup.sh", "uid", 0, "gid", 0, "mode", 0777);>> !updater_script!
	if exist "WORK\META-INF\SCRIPTS\efs_backup.sh" echo run_program("/tmp/efs_backup.sh");>> !updater_script!
	if exist "WORK\META-INF\SCRIPTS\wipe.sh" echo ui_print("-- Wiping all user data files");>> !updater_script!
	if exist "WORK\META-INF\SCRIPTS\wipe.sh" echo set_metadata("/tmp/wipe.sh", "uid", 0, "gid", 0, "mode", 0777);>> !updater_script!
	if exist "WORK\META-INF\SCRIPTS\wipe.sh" echo run_program("/tmp/wipe.sh");>> !updater_script!
	echo delete_recursive("/system");>> !updater_script!
	echo #--INSTALLATION>> !updater_script!
	echo ui_print("-- Extracting system & data"); >> !updater_script!
	echo package_extract_dir("system", "/system"); >> !updater_script!
	echo package_extract_dir("META-INF/ADD-ONS/DATA", "/data"); >> !updater_script!
	echo #--SYMLINKS>> !updater_script!
	echo ui_print("-- Creating symbolic links"); >> !updater_script!
	call :write_symlinks
	echo #--PERMISSIONS >> !updater_script!
	echo ui_print("-- Setting & fixing permissions"); >> !updater_script!
	call :write_permissions
	call :last_updater
	echo #--FINISH>> !updater_script!
	echo ui_print("-- Finishing installation");>> !updater_script!
	echo ifelse(is_mounted("/system"), unmount("/system")); >> !updater_script!
	echo ui_print("INSTALLING !rom_name! ROM FINISHED"); ui_print(" "); >> !updater_script!
	TOOLS\bin\dos2unix -q !updater_script!>nul
	goto completed
:write_symlinks
	if not exist "TOOLS\tmp\original_symlinks" for /f "delims=" %%a in ('TOOLS\bin\find WORK/system -type l ^| !busybox! sed "s/WORK//"') do (
		for /f "delims=" %%b in ('!busybox! readlink work%%a') do echo symlink("%%b", "%%a";;;| !busybox! sed "s/;;;/);/">>TOOLS\tmp\last
	)
	for /f "delims=" %%a in ('echo "%cd%" ^| !busybox! cut -d":" -f1') do set drive_up=%%a
	for /f "delims=" %%a in ('echo "%cd%"^| !busybox! cut -d":" -f2') do set second=%%a
	set drive_low=!drive_up!
	for %%b in (a b c d e f g h i j k l m n o p q r s t u v w x y z) DO SET drive_low=!drive_low:%%b=%%b!
	for /f "delims=" %%a in ('echo \cygdrive\!drive_low!!second!\WORK\system^| !busybox! tr \\ /') do set rm1=%%a
	for /f "delims=" %%a in ('echo \cygdrive\!drive_up!!second!\WORK\system^| !busybox! tr \\ /') do set rm2=%%a
	set rm1=!rm1:/=\/!
	set rm2=!rm2:/=\/!
	set rm1=!rm1:"=!
	set rm2=!rm2:"=!
	!busybox! sed -i -e "s/!rm1!//" TOOLS/tmp/last
	!busybox! sed -i -e "s/!rm2!//" TOOLS/tmp/last
	set symlink_test=0
	for /f "delims=" %%a in ('!busybox! grep -cw "symlink" TOOLS/tmp/last') do set symlink_test=%%a
	if not exist "TOOLS\tmp\original_symlinks" if !symlink_test! leq 5 (
		del tools\tmp\last
		tools\bin\cecho {0e}AN ERROR HAPPENED DURING DETECT SYMLINKS{#}
		echo.
		tools\bin\cecho {0e}THIS HAPPENED WHEN YOU WORK ON ZIP DOESN'T CONTENT{#}
		echo.
		tools\bin\cecho {0e}THE [update-script] FILE OR WORK ON STOCK IMAGE{#}
		echo.
		tools\bin\cecho {0e}DOESN'T CONTENT LOCAL SYMLINKS, THE IS A PROBLEM{#}
		echo.
		tools\bin\cecho {0e}HOWEVER, WE WILL CREATE SYMLINKS FROM OUR DATABASE{#}
		echo.
		tools\bin\cecho {0e}AND THIS WILL TAKE A LONG TIME PLEASE WAIT...{#}
		echo.
	)
	if not exist "TOOLS\tmp\original_symlinks" if !symlink_test! leq 5 for /f "delims=" %%a in ('type tools\txt_files\symlinks_list.txt') do (
		for /f "delims=" %%b in ('echo %%a ^| !busybox! cut -d"""" -f2') do (
			set first=%%b
			set search=%%~nb%%~xb
		)
		for /f "delims=" %%c in ('echo %%a ^| !busybox! cut -d"""" -f4') do set second=%%c
		for /f "delims=" %%e in ('!busybox! dirname !second!') do set dir=%%e
		set find=n
		for /f "delims=" %%d in ('TOOLS\bin\find WORK/system -name !search!') do set find=%%d
		if not "!find!"=="n" if exist "WORK!dir!" echo %%a>> tools\tmp\last
	)
	if exist "work\system\bin\app_process64" (
		!busybox! sed -i '/^symlink("app_process32", "\/system\/bin\/app_process"/d' tools/tmp/last
		!busybox! sed -i '/^symlink("dalvikvm32", "\/system\/bin\/dalvikvm"/d' tools/tmp/last
	)
	tools\bin\dos2unix tools\tmp\last
	if exist "TOOLS\tmp\last" !busybox! sort -u < "TOOLS/tmp/last" >> "TOOLS/tmp/original_symlinks"
	del TOOLS\tmp\last
	TOOLS\bin\find WORK/system -type l -delete
	if exist !updater_script! !busybox! sort TOOLS\tmp\original_symlinks >> !updater_script!
	goto:eof
:write_permissions
	!busybox! sed 's/--//g' TOOLS\tmp\kernel_file_contexts | !busybox! grep "^/system/" | !busybox! sort > TOOLS\tmp\system_contexts
	!busybox! sed 's/\\\././g; s/\\\+/+/g; s/(\/\.\*)?//g; s/\.\*//g; s/(\.\*)//g' TOOLS\tmp\system_contexts | TOOLS\bin\gawk "{ print $1, $NF }" | !busybox! sort > TOOLS\tmp\system_contexts2
	!busybox! mv TOOLS\tmp\system_contexts2 TOOLS\tmp\system_contexts
	if exist "TOOLS/tmp/kernel_file_contexts" for /f "delims=" %%f in ('!busybox! cat "TOOLS\txt_files\metadata.txt" ^| !busybox! cut -d"""" -f2') do (
		set replace=no
		for /f "delims=" %%a in ('!busybox! grep -m 1 "%%f " TOOLS\tmp\system_contexts ^| TOOLS\bin\gawk "{ print $NF }"') do set replace=%%a
		if "!replace!"=="no" set replace=u:object_r:system_file:s0
		if exist "WORK%%f" !busybox! grep -w '"%%f"' TOOLS/txt_files/metadata.txt | !busybox! sed "s/REPLACE_HERE/!replace!/">>TOOLS\tmp\rom_permissions
	)
	for /f "delims=" %%a in ('type TOOLS\tmp\system_contexts') do (
		for /f "delims=" %%b in ('echo %%a ^| TOOLS\bin\gawk "{print $1}"') do set file=%%b
		for /f "delims=" %%b in ('echo %%a ^| TOOLS\bin\gawk "{print $NF}"') do set contexts=%%b
		for /f "delims=" %%v in ('!busybox! grep -cw '"!file!"' TOOLS/tmp/rom_permissions') do set check=%%v
		for /f "delims=" %%z in ('echo !file!') do if "!check!"=="0" if not exist "WORK\system\bin\%%~nz" if exist "WORK!file!" echo set_metadata("!file!", "capabilities", 0x0, "selabel", "!contexts!";;; | !busybox! sed "s/;;;/);/">>TOOLS\tmp\rom_permissions
		for /f "delims=" %%z in ('echo !file!') do if exist "WORK\system\bin\%%~nz" echo set_metadata("!file!", "uid", 0, "gid", 2000, "mode", 0755, "capabilities", 0x0, "selabel", "!contexts!";;; | !busybox! sed "s/;;;/);/">>TOOLS\tmp\rom_permissions
	)
	if exist "TOOLS/tmp/kernel_file_contexts" (
		TOOLS\bin\dos2unix -q TOOLS\tmp\rom_permissions
		!busybox! sed -i -e "s/); /);/g" TOOLS/tmp/rom_permissions
		!busybox! sort -u < TOOLS/tmp/rom_permissions >> TOOLS/tmp/permissions_sorted
		!busybox! grep "set_metadata_recursive" TOOLS/tmp/permissions_sorted >> TOOLS/tmp/recursive
		!busybox! grep -v "set_metadata_recursive" TOOLS/tmp/permissions_sorted >> TOOLS/tmp/not_recursive
		!busybox! cat TOOLS/tmp/not_recursive >> TOOLS/tmp/recursive
		type TOOLS\tmp\recursive >> !updater_script!
	)
	del TOOLS\tmp\system_contexts TOOLS\tmp\*permissions* TOOLS\tmp\*recursive*
	if !api! leq 19 if not exist "TOOLS/tmp/kernel_file_contexts" for /f "delims=" %%a in ('!busybox! cat "TOOLS\txt_files\set_perm.txt" ^| !busybox! cut -d"""" -f2') do if exist "WORK%%a" !busybox! grep -w '"%%a"' TOOLS/txt_files/set_perm.txt>>!updater_script!
	if !api! geq 20 if not exist "TOOLS\tmp\kernel_file_contexts" (
		for /f "delims=" %%a in ('!busybox! cat "TOOLS\txt_files\random_metadata.txt" ^| !busybox! cut -d"""" -f2') do if exist "WORK%%a" !busybox! grep -w '"%%a"' TOOLS/txt_files/random_metadata.txt>>!updater_script!
		TOOLS\bin\cecho {0e}NO [boot.img] DETECTED OR NO [file_contexts] DETECTED{#}
		echo.
		TOOLS\bin\cecho {0e}FROM KERNEL, AND THIS ROM IS [Lollipop+] AND IT NEEDS{#}
		echo.
		TOOLS\bin\cecho {0e}THE ABOVE FILE TO GET CORRECT FILES CONTEXTS,{#}
		echo.
		TOOLS\bin\cecho {0e}WITHOUT IT THE ROM MAY CONTENTS PROBLEMS, HOWEVER WE HAVE CREATED{#}
		echo.
		TOOLS\bin\cecho {0e}INSTALLER WITH RANDOM [set_metadata] FILES CONTEXTS{#}
		echo.
		TOOLS\bin\cecho {0e}GOOD LUCK.....{#}
		echo.
	)
	goto:eof
:last_updater
	set chmod=06755
	if "!api!" geq "18" set chmod=0755
	!busybox! sed -i -e "s/SUMOD_REPLACE/!chmod!/g" !updater_script!
	if exist "WORK\system\xbin\su" if exist "WORK\system\addon.d" echo set_metadata("/system/xbin/su", "uid", 0, "gid", 0, "mode", 0755, "capabilities", 0x0, "selabel", "u:object_r:su_exec:s0"); >> !updater_script!
	if exist "WORK\system\xbin\su" if not exist "WORK\system\addon.d" echo run_program("/system/xbin/su", "--install"); >> !updater_script!
	if exist "WORK/system/xbin/busybox" echo run_program("/system/xbin/busybox", "--install", "-s", "/system/xbin");>>!updater_script!
	echo #--KERNEL>> !updater_script!
	echo package_extract_file("boot.img", "/tmp/boot.img");>> !updater_script!
	echo ui_print("-- Flashing kernel image");>> !updater_script!
	if exist "!aroma_config!" echo set_progress(0.99);>> !updater_script!
	echo set_metadata("/tmp/flash_kernel.sh", "uid", 0, "gid", 0, "mode", 0777);>> !updater_script!
	echo run_program("/tmp/flash_kernel.sh");>> !updater_script!
	echo #--CUSTOM SCRIPTS>> !updater_script!
	set s2=if not exist "WORK\META-INF\ADD-ONS\supersu"
	set s3=if exist "WORK\supersu\supersu.zip"
	set s4=if exist "WORK\META-INF\ADD-ONS\supersu"
	set s5=if exist "WORK\META-INF\ADD-ONS\install"
	%s2% %s3% echo ui_print("-- Rooting rom with supersu");>>!updater_script!
	%s2% %s3% echo package_extract_dir("supersu", "/tmp/supersu");>>!updater_script!
	%s2% %s3% echo run_program("/sbin/busybox", "unzip", "/tmp/supersu/supersu.zip", "META-INF/com/google/android/update-binary", "-d", "/tmp/supersu");>>!updater_script!
	%s2% %s3% echo run_program("/sbin/busybox", "sh", "/tmp/supersu/META-INF/com/google/android/update-binary", "dummy", "1", "/tmp/supersu/supersu.zip");>>!updater_script!
	%s4% echo ui_print("-- Rooting rom with supersu");>>!updater_script!
	%s4% echo package_extract_dir("META-INF/ADD-ONS/supersu", "/tmp/supersu");>>!updater_script!
	%s4% echo run_program("/sbin/busybox", "unzip", "/tmp/supersu/supersu.zip", "META-INF/com/google/android/update-binary", "-d", "/tmp/supersu");>>!updater_script!
	%s4% echo run_program("/sbin/busybox", "sh", "/tmp/supersu/META-INF/com/google/android/update-binary", "dummy", "1", "/tmp/supersu/supersu.zip");>>!updater_script!
	%s5% echo run_program("/sbin/mount", "-t", "auto", "/system"); >> !updater_script!
	%s5% echo ui_print("-- Restoring addon.d scripts");>> !updater_script!
	%s5% echo run_program("/tmp/install/bin/backuptool.sh", "restore");>> !updater_script!
	ECHO NOTE: IF YOU WANT TO ADD ANY THING TO ROM INSTALLER TO INSTALL
	ECHO IN DEVICE [DATA] ADD IT TO: [WORK/META-INF/ADD-ONS/DATA]
	goto:eof
:sign_zip
	set zip_file=%~n1
	set ask=
	echo SIGNING PROCESS WILL TAKE SOME TIME AND ITS DEPENDING ON THE ZIP SIZE
	set /p ask=DO YOU WANT TO SIGN CREATED ZIP? [DEFAULT=NO 1=YES]:
	if not "!ask!"=="1" goto:eof
	echo SIGNING [READY\!zip_file!.zip]
	java -jar tools\apktool\signapk.jar tools\apktool\testkey.x509.pem tools\apktool\testkey.pk8 READY\!zip_file!.zip READY\!zip_file!_SIGNED.zip >nul
	del READY\!zip_file!.zip
	goto:eof
:decidebuild
	if not %status% ==y (
		echo PLEASE FIX WARNING STATUS FIRST OR TRY [18] COMMAND
		pause>nul
		goto start
	)
	if %skipwarn% ==y (
		TOOLS\bin\cecho {0c}THIS OPTION FOR SKIP WARNING STATUS FOR ADVANCED USERS ONLY{#}
		echo.
	)
	set decidebuild=null
	echo THE KITCHEN CAN BUILD IN THIS METHODS:
	TOOLS\bin\cecho {0a}DAT:{#} FASTEST METHOD DURING INSTALLING [system.new.dat]
	echo.
	TOOLS\bin\cecho {0a}RAW:{#} GOOD METHOD, FLASHING RAW [system.img] TO YOUR DEVICE
	echo. 
	if "!factory!" =="samsung" (
		TOOLS\bin\cecho {0a}TAR:{#} BUILD SAME AS SAMSUNG OFFICIAL ROMS [tar.md5] INSTALL WITH ODIN
		echo.
	)
	TOOLS\bin\cecho {0a}ZIP:{#} BUILD SAME ANY ZIP ROM [NORMAL MODE]
	echo.
	if not "!factory!"=="samsung" set /p decidebuild=TYPE BUILD METHOD THAT YOU WANT [1=DAT 2=ZIP 3=RAW DEFAULT=BACK]:
	if "!factory!"=="samsung" set /p decidebuild=TYPE BUILD METHOD THAT YOU WANT [1=DAT 2=TAR 3=ZIP 4=RAW DEFAULT=BACK]:
	if not "!decidebuild!"=="1" if not "!decidebuild!"=="2" if not "!decidebuild!"=="3" if not "!decidebuild!"=="4" goto start
	copy WORK\file_contexts TOOLS\tmp\kernel_file_contexts >nul
	set search_kernel=n
	set ask=n
	if "!factory!"=="samsung" (
		if not "!decidebuild!"=="3" if "!api!" geq "20" if not exist "TOOLS\tmp\kernel_file_contexts" (
			echo THIS METHOD NEEDS [file_contexts] FROM KERNEL AND THE ROM MAY NOT BOOT WITHOUT IT
			set /p ask=DO YOU WANT TO CONTINUE [DEFAULT=YES 0=NO]:
			if "!ask!"=="0" goto start
		)
		if "!decidebuild!"=="1" goto builddat
		if "!decidebuild!"=="2" goto buildtar
		if "!decidebuild!"=="4" goto buildraw
	)
	if not "!factory!"=="samsung" (
		if not "!decidebuild!"=="2" if "!api!" geq "20" if not exist "TOOLS\tmp\kernel_file_contexts" (
			echo THIS METHOD NEEDS [file_contexts] FROM KERNEL AND THE ROM MAY NOT BOOT WITHOUT IT
			set /p ask=DO YOU WANT TO CONTINUE [DEFAULT=YES 0=NO]:
			if "!ask!"=="0" goto start
		)
		if "!decidebuild!"=="1" goto builddat
		if "!decidebuild!"=="3" goto buildraw
	)
	if not exist "WORK\META-INF" (
		echo THERE IS NO META-INF CAN'T BUILD IN ZIP METHOD
		pause>nul
		goto start
	)
:buildzip
	set nobootfound=ll
	if not exist "WORK\boot.img" set /p nobootfound=WARNING: NO BOOT.IMG FOUND CONTINUE BUILD OR NOT [DEFAULT=YES 0=BACK]:
	if "!nobootfound!"=="0" goto start
	for /f "delims=" %%a in ('TOOLS\bin\find WORK/system -type f ^| !busybox! wc -l') do !busybox! sed -i 's/xxxx/%%a/' !updater_script!
	set openup=open
	if exist !updater_script! set /p openup=REVIEW UPDATER-SCRIPT BEFORE BUILD [DEFAULT=NO 1=YES]:
	if "!openup!"=="1" if exist !updater_script! (
		start TOOLS\notepad_pp\notepad++ !updater_script!
		echo PRESS ANY KEY AFTER FINISH
		pause>nul
	)
	set openup=open
	set openar=openar
	if exist !aroma_config! set /p openar=REVIEW AROMA-CONFIG BEFORE BUILD [DEFAULT=NO 1=YES]:
	if "!openar!"=="1" if exist !aroma_config! (
		start TOOLS\notepad_pp\notepad++ !aroma_config!
		echo PRESS ANY KEY AFTER FINISH
		pause>nul
	)
	set openar=openar
	set build_zipalign=n
	set /p build_zipalign=DO YOU WANT TO ZIPALIGN APKS BEFOR BUILD [DEFAULT=YES 0=NO]:
	if not "!build_zipalign!"=="0" (
		set zipaligenq=y
		call :zipalign
	)
	set build_zipalign=n
	set compress=5
	set /p compress=TYPE COMPRESS LEVEL (0--9) [DEFAULT: 5]:
	for /f "delims=" %%a in ('!busybox! date '+%%y%%m%%d_%%H%%M%%S'') do set name=ASSAYYED_PROJECT_%%a
	set /p name=TYPE THE NAME FOR YOUR ZIP [DEFAULT=!name!]:
	if exist READY\"!name!".zip del READY\"!name!".zip
	TOOLS\bin\find WORK/system -type l -delete
	if not exist "WORK\META-INF\SCRIPTS\auto.sh" copy TOOLS\installer\aroma\META-INF\SCRIPTS\auto.sh WORK\META-INF\SCRIPTS\auto.sh >nul
	cd WORK
	"../TOOLS/bin/7za" u -mx!compress! -tzip "../READY/!name!.zip" *
	if errorlevel 1 (
		ECHO AN ERROR HAPPENED
		ECHO BE SURE FROM COMPRESS LEVEL NUMBER ITS MUST BE BETWEEN 0 AND 9
		ECHO PRESS ENTER TO CONTINUE.....
		pause>nul
		cd ..
		goto start
	)
	cd ..
	call :sign_zip !name!.zip
	goto completed
:buildtar
	cls
	echo.
	echo.
	echo PREPARING PROJECT FOR [tar] BUILD
	if exist "TOOLS\tmp\buildtar*" (
		echo REMOVING OLD BUILD FOLDER
		!busybox! rm -rf TOOLS/tmp/buildtar*
	)
	mkdir TOOLS\tmp\buildtar
	if not exist "TOOLS\tmp\kernel_file_contexts" call :get_kernel_file_contexts
	copy TOOLS\tmp\kernel_file_contexts TOOLS\tmp\buildtar\file_contexts >nul
	echo CREATING SYMLINKS
	if not exist "TOOLS\tmp\original_symlinks" call :write_symlinks
	call :creat_symlinks
	call :detect_size
	set build_zipalign=n
	set /p build_zipalign=DO YOU WANT TO ZIPALIGN APKS BEFOR BUILD [DEFAULT=YES 0=NO]:
	if not "!build_zipalign!"=="0" (
		set zipaligenq=y
		call :zipalign
	)
	set build_zipalign=n
	echo CREATING SPARSE [system.img] FROM SYSTEM FOLDER
	if exist "TOOLS\tmp\buildtar\file_contexts" TOOLS\bin\make_ext4fs -s -T 0 -S TOOLS\tmp\buildtar\file_contexts -l !sizesystem! -a /system TOOLS\tmp\buildtar\system.img WORK/system/ >nul
	if not exist "TOOLS\tmp\buildtar\file_contexts" TOOLS\bin\make_ext4fs -s -T 0 -l !sizesystem! -a /system TOOLS\tmp\buildtar\system.img WORK/system/ >nul
	del TOOLS\tmp\buildtar\file_contexts
	if not exist "TOOLS\tmp\buildtar\system.img" (
		TOOLS\bin\cecho {0c}ERROR DURING CREATE [system.img]{#} PRESS ENTER TO BACK
		echo.
		!busybox! rm -rf TOOLS/tmp/buildtar
		pause>nul
		goto start
	)
	copy WORK\boot.img TOOLS\tmp\buildtar\boot.img>nul
	set tarbuildbootnotfound=null
	for /f "delims=" %%a in ('!busybox! date '+%%y%%m%%d_%%H%%M%%S'') do set tarpackagename=ASSAYYED_PROJECT_%%a
	ECHO NOTE: YOU CAN NOW ADD FILES TO [TOOLS\tmp\buildtar] FOLDER TO ADD TO TAR FILE
	ECHO LIKE: [modem, recovery].....BUT IT MUST BE FOR SAME DEVICE MODEL
	TOOLS\bin\cecho PRESS ENTER AFTER FINISH
	set wait=n
	set /p wait=
	set wait=n
	ECHO PLEASE READ THE INSTRUCTIONS CARFULLY TO AVOID ERRORS:
	ECHO ********************************************************************
	ECHO WE HAVE CREATED SYSTEM.IMG WITH SPARSE HEADER [28BIT]
	ECHO BUT SOME SAMSUNG DEVICES NEED TO CONVERT TO SPARSE HEADER [32BIT]
	ECHO IF YOU KNOW WHAT SPARSE HEADER THAT THIS ROM NEEDS IT SELECT
	ECHO OTHERWISE LEAVE IT EMTPY THEN PRESS ENTER.. IN THIS CASE
	ECHO WE WILL CREATE TO COPIES OF TAR ROM FIRST [28BIT]
	ECHO AND SECOND [32BIT] TEST THE TOW COPIES ONE OF THEM
	ECHO WILL CAUSE ERROR DURING ODIN FLASH SYSTEM BUT DON'T WORRY
	ECHO REBOOT YOUR DEVICE TO DOWNLOAD MODE AND FLASH THE SECOND FILE 
	ECHO IT SHOULD BE SUCCESS
	ECHO SOME EXAMPLES:
	ECHO GALAXY: S4 - NOTE 3 - J1 - CORE* - S6 AND ALL OCTA CORE CPUs: ARE 32BIT
	ECHO GALAXY: S3 - NOTE 2 - GRAND PRIME - WIN: ARE 28BIT
	echo ********************************************************************
	set sparse_header=n
	set /p sparse_header=WHAT YOUR CHOICE [0=CANCEL DEFAULT=28 1=32 2=CREATE_BOTH]:
	if "!sparse_header!"=="0" (
		!busybox! rm -rf TOOLS/tmp/buildtar
		goto start 
	)
	if not "!sparse_header!"=="1" if not "!sparse_header!"=="2" ren TOOLS\tmp\buildtar buildtar_28
	if "!sparse_header!"=="1" (
		echo CONVERTING SPARSE HEADER TO 32BIT
		ren TOOLS\tmp\buildtar buildtar_32
		TOOLS\bin\sgs4ext4fs --bloat TOOLS/tmp/buildtar_32/system.img TOOLS/tmp/buildtar_32/system_new.img >nul
		del TOOLS\tmp\buildtar_32\system.img
		ren TOOLS\tmp\buildtar_32\system_new.img system.img >nul
	)
	if "!sparse_header!"=="2" (
		mkdir TOOLS\tmp\buildtar_32
		ren TOOLS\tmp\buildtar buildtar_28
		for %%f in (TOOLS\tmp\buildtar_28\*) do if not "%%~nf%%~xf"=="system.img" copy %%f TOOLS\tmp\buildtar_32\%%~nf%%~xf >nul
		echo CREATING NEW [system.img] WITH SPARSE HEADER 32BIT
		TOOLS\bin\sgs4ext4fs --bloat TOOLS/tmp/buildtar_28/system.img TOOLS/tmp/buildtar_32/system.img >nul
	)
	ECHO NOW THE LAST STEP:
	ECHO ********************************************************************
	ECHO SOME SAMSUNG TAR ROMS CONTENT [system.img.ext4] INSTEAD OF [system.img]
	ECHO SO YOU SHOULD LOOK TO ANY OFFICIAL ROM FOR THIS DEVICE AND OPEN IT
	ECHO WARNING: IF YOU DON'T DO THIS STEP AND SELECT RANDOM OPTION THE ROM MAY 
	ECHO NOT WORK
	echo ********************************************************************
	set img_or_ext4=nul
	set /p img_or_ext4=WHAT YOUR CHOICE [0=CANCEL DEFAULT=IMG 1=EXT4 2=CREATE_BOTH]:
	if "!img_or_ext4!"=="0" (
		!busybox! rm -rf TOOLS/tmp/buildtar*
		goto start
	)
	if "!img_or_ext4!"=="1" (
		ren TOOLS\tmp\buildtar_28 buildtar_28_ext4
		ren TOOLS\tmp\buildtar_32 buildtar_32_ext4
		ren TOOLS\tmp\buildtar_28_ext4\system.img system.img.ext4
		ren TOOLS\tmp\buildtar_32_ext4\system.img system.img.ext4
	)
	if "!img_or_ext4!"=="2" (
		if exist "TOOLS\tmp\buildtar_32" (
			echo CREATING [img] AND [ext4] COPIES FROM [32] BIT
			mkdir TOOLS\tmp\buildtar_32_ext4
			!busybox! cp -f TOOLS/tmp/buildtar_32/* TOOLS/tmp/buildtar_32_ext4/
			ren TOOLS\tmp\buildtar_32_ext4\system.img system.img.ext4
		)
		if exist "TOOLS\tmp\buildtar_28" (
			echo CREATING [img] AND [ext4] COPIES FROM [28] BIT
			mkdir TOOLS\tmp\buildtar_28_ext4
			!busybox! cp -f TOOLS/tmp/buildtar_28/* TOOLS/tmp/buildtar_28_ext4/
			ren TOOLS\tmp\buildtar_28_ext4\system.img system.img.ext4
		)
	)
	set /p tarpackagename=TYPE THE [tar] FILE NAME [DEFAULT=!tarpackagename!]:
	del "READY\!tarpackagename!*.tar*"
	if exist "TOOLS\tmp\buildtar_28" (
		echo PACKING [!tarpackagename!_28bit.tar]
		cd TOOLS\tmp\buildtar_28
		..\..\..\!busybox! tar -c *.* >> "..\..\..\READY\!tarpackagename!_28bit.tar"
		cd ..\..\..
	)
	if exist "TOOLS\tmp\buildtar_32" (
		echo PACKING [!tarpackagename!_32bit.tar]
		cd TOOLS\tmp\buildtar_32
		..\..\..\!busybox! tar -c *.* >> "..\..\..\READY\!tarpackagename!_32bit.tar"
		cd ..\..\..
	)
	if exist "TOOLS\tmp\buildtar_28_ext4" (
		echo PACKING [!tarpackagename!_28bit_ext4.tar]
		cd TOOLS\tmp\buildtar_28_ext4
		..\..\..\!busybox! tar -c *.* >> "..\..\..\READY\!tarpackagename!_28bit_ext4.tar"
		cd ..\..\..
	)
	if exist "TOOLS\tmp\buildtar_32_ext4" (
		echo PACKING [!tarpackagename!_32bit_ext4.tar]
		cd TOOLS\tmp\buildtar_32_ext4
		..\..\..\!busybox! tar -c *.* >> "..\..\..\READY\!tarpackagename!_32bit_ext4.tar"
		cd ..\..\..
	)
	!busybox! rm -rf TOOLS/tmp/buildtar*
	if exist "WORK\system\xbin\daemonsu" (
		ECHO BAD NEWS:
		ECHO WINDOWS DOESN'T SUPPORT PERMISSIONS TO FILES
		ECHO SO WE CAN'T SET CORRECT PERMISSIONS FOR ROOT
		ECHO IN WINDOWS IT IS IMPOSSIBLE AND THE ROOT MAY NOT WORK
		ECHO SORRY FOR THAT...BUT IF YOUR LUCK IS GOOD IT MAY WORK
	)
	if exist "READY\!tarpackagename!_32bit.tar" (
		TOOLS\bin\cecho {0a}CREATED [%tarpackagename%_32bit.tar] IN READY FOLDER{#}
		echo.
	)
	if exist "READY\!tarpackagename!_28bit.tar" (
		TOOLS\bin\cecho {0a}CREATED [%tarpackagename%_28bit.tar] IN READY FOLDER{#}
		echo.
	)
	if exist "READY\!tarpackagename!_32bit_ext4.tar" (
		TOOLS\bin\cecho {0a}CREATED [%tarpackagename%_32bit_ext4.tar] IN READY FOLDER{#}
		echo.
	)
	if exist "READY\!tarpackagename!_28bit_ext4.tar" (
		TOOLS\bin\cecho {0a}CREATED [%tarpackagename%_28bit_ext4.tar] IN READY FOLDER{#}
		echo.
	)
	set open_odin=y
	set /p open_odin=DO YOU WANT TO RUN ODIN TO FLASH THE ROM [DEFAULT=YES 0=NO]:
	if not "!open_odin!"=="0" (
		cd TOOLS\installer
		start odin
		cd ..\..
		goto completed
	)
	goto completed
:builddat
	cls
	echo.
	echo.
	set system_path=n
	ECHO THIS METHOD OF BUILDING WILL CREATE [system.new.dat] WITH TRANSFER LIST
	ECHO AND FLASH IT TO YOUR DEVICE SYSTEM BLOCK PATH
	ECHO THIS MEANS NO SYMLINKING DURING THE INSTALL AND NO PERMISSIONS
	ECHO TO SET, FAST AND CLEAN INSTALL AND IT IS A NEW METHOD AND A LOT OF 
	ECHO DEVELOPERS PREFER IT
	ECHO AND THIS NEED TO DETECT DEVICE BLOCK PATH
	call :system_path_for_build
	echo PREPARING WORK FOLDER FOR [dat] BUILD
	if exist "TOOLS\tmp\builddat" (
		echo REMOVING OLD BUILD FOLDER
		!busybox! rm -rf TOOLS/tmp/builddat
	)
	mkdir TOOLS\tmp\builddat
	xcopy TOOLS\installer\image_installer TOOLS\tmp\builddat /e /i /h /y>nul
	set root_dat=n
	for /f "delims=" %%a in ('TOOLS\bin\find WORK -name supersu.zip') do set root_dat=%%a
	if not "!root_dat!"=="n" (
		mkdir TOOLS\tmp\builddat\supersu
		copy "!root_dat!" TOOLS\tmp\builddat\supersu\supersu.zip>nul
	)
	if not exist "TOOLS\tmp\builddat\supersu\supersu.zip" rmdir /s /q TOOLS\tmp\builddat\supersu
	set rom_build_name=
	set /p rom_build_name=TYPE ROM NAME [SHOW DURING INSTALLATION]:
	echo PREPARING [updater-script] 
	call :prepare_updater_for_build builddat
	if exist "WORK\boot_unpacked" rmdir /s /q WORK\boot_unpacked
	copy WORK\boot.img TOOLS\tmp\builddat\boot.img>nul
	if not exist "WORK\boot.img" if exist "WORK\kernel.sin.bak" copy WORK\kernel.sin.bak TOOLS\tmp\builddat\boot.img>nul
	if not exist "TOOLS\tmp\kernel_file_contexts" call :get_kernel_file_contexts
	copy TOOLS\tmp\kernel_file_contexts TOOLS\tmp\builddat\file_contexts >nul
	echo CREATING SYMLINKS
	if not exist "TOOLS\tmp\original_symlinks" call :write_symlinks
	call :creat_symlinks
	call :detect_size
	set build_zipalign=n
	set /p build_zipalign=DO YOU WANT TO ZIPALIGN APKS BEFOR BUILD [DEFAULT=YES 0=NO]:
	if not "!build_zipalign!"=="0" (
		set zipaligenq=y
		call :zipalign
	)
	set build_zipalign=n
	echo CREATING EXT4 [system.img] FROM SYSTEM FOLDER
	if exist "TOOLS\tmp\builddat\file_contexts" TOOLS\bin\make_ext4fs -T 0 -S TOOLS\tmp\builddat\file_contexts -l !sizesystem! -a /system TOOLS\tmp\builddat\system.img WORK/system/ >nul
	if not exist "TOOLS\tmp\builddat\file_contexts" TOOLS\bin\make_ext4fs -T 0 -l !sizesystem! -a /system TOOLS\tmp\builddat\system.img WORK/system/ >nul
	if not exist "TOOLS\tmp\builddat\system.img" (
		!busybox! rm -rf TOOLS\tmp\builddat
		TOOLS\bin\cecho {0c}ERROR IN CREATING [system.img] CAN'T CONTINUE{#}
		echo.
		pause>nul
		goto start
	)
	echo CREATING [system.new.dat] [system.transfer.list] FROM [system.img]
	cd TOOLS\tmp\builddat
	..\..\..\TOOLS\bin\rimg2sdat >nul
	cd ..\..\..
	!busybox! touch TOOLS/tmp/builddat/system.patch.dat
	if not exist "TOOLS\tmp\builddat\system.new.dat" if not exist "TOOLS\tmp\builddat\system.transfer.list" (
		!busybox! rm -rf TOOLS/tmp/builddat
		TOOLS\bin\cecho {0c}ERROR IN CREATING [system.new.dat] [system.transfer.list] CAN'T CONTINUE{#}
		echo.
		pause>nul
		goto start
	)
	del TOOLS\tmp\builddat\system.img
	TOOLS\bin\dos2unix -q TOOLS/tmp/builddat/system.transfer.list>nul
	for /f "delims=" %%a in ('!busybox! date '+%%y%%m%%d_%%H%%M%%S'') do set builddatname=ASSAYYED_PROJECT_%%a
	set /p builddatname=TYPE THE ZIP FILE NAME [DEFAULT=!builddatname!]:
	set compresslevel=5
	set /p compresslevel=TYPE COMPRESS LEVEL [0--9] DEFAULT [5]:
	if exist READY\"!builddatname!".zip del READY\"!builddatname!".zip
	cd TOOLS\tmp\builddat
	"../../../TOOLS/bin/7za" u -mx!compresslevel! -tzip "../../../READY/!builddatname!.zip" *
	cd ..\..\..
	!busybox! rm -rf TOOLS/tmp/builddat
	if not exist "READY\!builddatname!.zip" (
		TOOLS\bin\cecho {0c}ERROR DURING CREATE ZIP FILE PLEASE SURE FROM COMPRESS LEVEL MUST BE NUMBER{#}
		echo.
		pause>nul
		goto start
	)
	call :sign_zip !builddatname!.zip
	if exist "READY\!builddatname!*.zip" goto completed
:buildraw
	cls
	set system_path=n
	echo.
	echo.
	ECHO THIS METHOD OF BUILDING WILL CREATE RAW EXT4 SYSTEM PARTITION
	ECHO AND FLASH IT TO YOUR DEVICE SYSTEM BLOCK PATH
	ECHO THIS MEANS NO SYMLINKING DURING THE INSTALL AND NO PERMISSIONS
	ECHO TO SET, FAST AND CLEAN INSTALL 
	ECHO AND THIS NEED TO DETECT DEVICE BLOCK PATH
	call :system_path_for_build
	if exist "TOOLS\tmp\buildraw" (
		echo REMOVING OLD BUILD FOLDER
		!busybox! rm -rf TOOLS/tmp/buildraw
	)
	echo PREPARING FOLDERS FOR [raw] BUILD
	mkdir TOOLS\tmp\buildraw
	xcopy TOOLS\installer\image_installer TOOLS\tmp\buildraw /e /i /h /y>nul
	set root_raw=n
	for /f "delims=" %%a in ('TOOLS\bin\find WORK -name supersu.zip') do set root_raw=%%a
	if not "!root_raw!"=="n" (
		mkdir TOOLS\tmp\buildraw\supersu
		copy "!root_raw!" TOOLS\tmp\buildraw\supersu\supersu.zip>nul
	)
	if not exist "TOOLS\tmp\buildraw\supersu\supersu.zip" rmdir /s /q TOOLS\tmp\buildraw\supersu
	set rom_build_name=
	set /p rom_build_name=TYPE ROM NAME [SHOW DURING INSTALLATION]:
	echo PREPARING [updater-script]
	call :prepare_updater_for_build buildraw
	if exist "WORK\boot_unpacked" rmdir /s /q WORK\boot_unpacked
	copy WORK\boot.img TOOLS\tmp\buildraw\boot.img>nul
	if not exist "WORK\boot.img" if exist "WORK\kernel.sin.bak" copy WORK\kernel.sin.bak TOOLS\tmp\buildraw\boot.img>nul
	if not exist "TOOLS\tmp\kernel_file_contexts" call :get_kernel_file_contexts
	copy TOOLS\tmp\kernel_file_contexts TOOLS\tmp\buildraw\file_contexts >nul
	echo CREATING SYMLINKS
	if not exist "TOOLS\tmp\original_symlinks" call :write_symlinks
	call :creat_symlinks
	call :detect_size
	set build_zipalign=n
	set /p build_zipalign=DO YOU WANT TO ZIPALIGN APKS BEFOR BUILD [DEFAULT=YES 0=NO]:
	if not "!build_zipalign!"=="0" (
		set zipaligenq=y
		call :zipalign
	)
	set build_zipalign=n
	echo CREATING SPARSE [system.img] FROM SYSTEM FOLDER
	if exist "TOOLS\tmp\buildraw\file_contexts" TOOLS\bin\make_ext4fs -s -T 0 -S TOOLS\tmp\buildraw\file_contexts -l !sizesystem! -a /system TOOLS\tmp\buildraw\sparse.img WORK/system/ >nul
	if not exist "TOOLS\tmp\buildraw\file_contexts" TOOLS\bin\make_ext4fs -s -T 0 -l !sizesystem! -a /system TOOLS\tmp\buildraw\sparse.img WORK/system/ >nul
	if not exist "TOOLS\tmp\buildraw\sparse.img" (
		!busybox! rm -rf TOOLS\tmp\buildraw
		TOOLS\bin\cecho {0c}ERROR IN CREATING [system.img] CAN'T CONTINUE{#}
		echo.
		pause>nul
		goto start
	)
	echo CONVERTING SPARSE IMAGE TO RAW EXT4
	TOOLS\bin\simg2img TOOLS/tmp/buildraw/sparse.img TOOLS/tmp/buildraw/system.img >nul
	del TOOLS\tmp\buildraw\sparse.img
	del TOOLS\tmp\buildraw\file_contexts
	for /f "delims=" %%a in ('!busybox! date '+%%y%%m%%d_%%H%%M%%S'') do set buildrawname=ASSAYYED_PROJECT_%%a
	set /p buildrawname=TYPE THE ZIP FILE NAME [DEFAULT=!buildrawname!]:
	set compresslevel=5
	set /p compresslevel=TYPE COMPRESS LEVEL [0--9] DEFAULT [5]:
	if exist READY\"!buildrawname!".zip del READY\"!buildrawname!".zip
	cd TOOLS\tmp\buildraw
	"../../../TOOLS/bin/7za" u -mx!compresslevel! -tzip "../../../READY/!buildrawname!.zip" *
	cd ..\..\..
	!busybox! rm -rf TOOLS/tmp/buildraw
	if not exist "READY\!buildrawname!.zip" (
		TOOLS\bin\cecho {0c}ERROR DURING CREATE ZIP FILE PLEASE SURE FROM COMPRESS LEVEL MUST BE NUMBER{#}
		echo.
		pause>nul
		goto start
	)
	call :sign_zip !buildrawname!.zip
	if exist "READY\!buildrawname!*.zip" goto completed
:system_path_for_build
	ECHO WE CAN DETECT SYSTEM PATH AUTOMATICALLY FROM [recovery.img] OR [boot.img]
	ECHO FOR THIS DEVICE OR YOU CAN WRITE IT MANUALLY
	set detect_system_path=n
	set /p detect_system_path=WHAT YOUR OPTION [DEFAULT=FROM_KERNEL 1=FROM_DEVICE 2=MANUALLY 0=CANCEL]:
	if "!detect_system_path!"=="0" (
		!busybox! rm -rf TOOLS/tmp/build*
		goto start
	)
	set system_path_manually=n
	if "!detect_system_path!"=="1" (
		ECHO PLEASE CONNECT YOUR DEVICE TO THIS PC AND ENABLE [Usb debugging]
		ECHO IN YOUR PHONE, PRESS ANY KEY WHEN YOU READY
		pause>nul
		ECHO DETECTING DEVICE RESPONSE
		call :device_response
		if "!error!"=="yes" (
			cls
			echo.
			echo.
			goto system_path_for_build
		)
		set system_adb_path=n
		for /f "delims=" %%a in ('TOOLS\bin\adb devices ^| !busybox! grep -cw recovery') do if "%%a"=="1" call :detect_from_recovery_mode system_adb_path /system
		if "!system_adb_path!"=="n" for /f "delims=" %%a in ('TOOLS\bin\adb shell mount ^| !busybox! grep -w '/SYSTEM' ^| TOOLS\bin\gawk "{print $1}"') do set system_adb_path=%%a
		if "!system_adb_path!"=="n" for /f "delims=" %%a in ('TOOLS\bin\adb shell mount ^| !busybox! grep -w '/system' ^| TOOLS\bin\gawk "{print $1}"') do set system_adb_path=%%a
		if not "!system_adb_path!"=="n" (
			ECHO DETECTED PATH: [!system_adb_path!]
			set system_path=!system_adb_path!
			goto:eof
		)
		if "!system_adb_path!"=="n" (
			ECHO SORRY WE CAN'T DETECT PATH FROM YOUR DEVICE
			ECHO PRESS ANY KEY TO BACK TO PATH DETECT METHODS
			pause>nul
			cls
			echo.
			echo.
			goto system_path_for_build
		)
	)
	if "!detect_system_path!"=="2" set /p system_path_manually=WRITE THE PATH HERE:
	if "!detect_system_path!"=="2" (
		set system_path=!system_path_manually!
		goto:eof
	)
	set system_path_auto=n
	if not exist "WORK\boot.img" (
		echo ERROR: NO [boot.img] FOUND IN THE ROM
		echo PRESS ANY KEY TO BACK TO DETECT PATH WINDOW
		PAUSE>NUL
		cls
		echo.
		echo.
		GOTO system_path_for_build
	)
	if exist "WORK\boot.img" (
		echo DETECTING SYSTEM PATH FROM [boot.img]
		call :detect_system_path
		!busybox! rm -rf WORK/boot_unpacked
		if not "!system_path_auto!"=="n" (
			echo DETECTED SYSTEM PATH: [!system_path_auto!]
			set system_path=!system_path_auto!
			goto:eof
		)
		echo ERROR IN DETECTING THE PATH FROM [boot.img]
	)
	set system_path_auto2=n
	set /p system_path_auto2=DO YOU WANT TO TRY FROM RECOVERY [DEFAULT=YES 0=BACK]:
	if "!system_path_auto2!"=="0" (
		cls
		echo.
		echo.
		GOTO system_path_for_build
	)
	echo PUT ANY RECOVERY FOR THIS DEVICE IN WORK FOLDE THEN PRESS ANY KEY
	pause>nul
	if not exist "WORK\recovery.img" (
		echo ERROR NO RECOVERY FOUND AND NO PATH DETECTED CAN'T CONTINUE
		echo PRESS ANY KEY TO BACK TO DETECT PATH WINDOW
		PAUSE>NUL
		cls
		echo.
		echo.
		GOTO system_path_for_build
	)
	set img_file=recovery.img
	set img_dir=recovery_unpacked
	call :detect_system_path
	!busybox! rm -rf WORK/recovery_unpacked
	del WORK\recovery.img
	if not "!system_path_auto!"=="n" (
		echo DETECTED SYSTEM PATH: [!system_path_auto!]
		set system_path=!system_path_auto!
		goto:eof
	)
	echo ERROR ALL OUR WORK FAILED WE CAN'T CONTINUE
	echo PRESS ANY KEY TO BACK TO DETECT PATH WINDOW
	PAUSE>NUL
	cls
	echo.
	echo.
	GOTO system_path_for_build
:detect_system_path
	set kernelunpackq=y
	if exist "WORK\!img_dir!" rmdir /s /q WORK\!img_dir!
	call :kernelunpack
	call :detect_from_fstab
	goto:eof
:detect_from_fstab
	set system_path_auto=n
	set first_character=
	set second_character=
	set third_character=
	for /f "delims=" %%a in ('TOOLS\bin\find WORK/!img_dir! -not -type l -name *fstab* ^| !busybox! grep -v charger ^| !busybox! grep -v goldfish ^| !busybox! grep -v ranchu') do (
		for /f "delims=" %%b in ('!busybox! grep -w /system %%a ^| !busybox! grep -v # ^| !busybox! grep -m 1 /system') do (
			for /f "delims=" %%c in ('echo %%b ^| TOOLS\bin\gawk "{print $1}"') do set first_character=%%c
			for /f "delims=" %%c in ('echo %%b ^| TOOLS\bin\gawk "{print $2}"') do set second_character=%%c
			for /f "delims=" %%c in ('echo %%b ^| TOOLS\bin\gawk "{print $3}"') do set third_character=%%c
			if "!first_character!"=="/system" echo !third_character!>>TOOLS\tmp\sort
			if "!second_character!"=="/system" echo !first_character!>>TOOLS\tmp\sort
		)
	)
	TOOLS\bin\dos2unix -q TOOLS\tmp\sort
	!busybox! sort -u < TOOLS\tmp\sort > TOOLS\tmp\path
	del TOOLS\tmp\sort
	set /p system_path_auto=<TOOLS\tmp\path
	del TOOLS\tmp\path
	goto:eof
:detect_size
	cls
	echo.
	echo.
	ECHO DETECTING SIZE OF SYSTEM FOLDER
	for /f "delims=" %%a in ('dir work\system /s ^| !busybox! tail -n 2 ^| !busybox! grep -w "File" ^| tools\bin\gawk "{print $3}" ^| !busybox! sed "s/,//g" ^| !busybox! sed "s/\.//g"') do set sizesystem1=%%a
	if !sizesystem1! GEQ 1000000000 set sizesystem=!sizesystem1:~0,4!M
	if !sizesystem1! LEQ 999999999 set sizesystem=!sizesystem1:~0,3!M
	echo WE HAVE DETECTED SYSTEM SIZE [!sizesystem!]
	ECHO IT IS HIGHLY RECOMMENDED THAT YOU DON'T CHANGE IT
	ECHO BUT IF YOU A DEVELOPER AND IF YOU KNOW WHAT YOU ARE DOING
	ECHO YOU CAN EXPAND IT AS YOUR DEVICE SYSTEM SIZE
	set change_size=n
	set /p change_size=WHAT YOUR CHOICE [DEFAULT=NO 0=CANCEL 1=YES 2=TRY_AUTO]:
	if not "!change_size!"=="0" if not "!change_size!"=="1" if not "!change_size!"=="2" goto:eof
	if "!change_size!"=="0" (
		!busybox! rm -rf TOOLS\tmp\builddat TOOLS\tmp\buildtar TOOLS\tmp\buildraw
		goto start
	)
	if "!change_size!" =="1" (
		set new_size=e
		ECHO NOTE: TYPE THE SIZE NUMBER WITH TYPE LIKE THIS:
		ECHO 1500000000 OR 1500000K OR 1500M
		ECHO IF THE TYPE WAS EMPTY LIKE [150000000] WILL USE BYTES
		ECHO WARNING: WRONG SIZES WILL CAUSE ERRORS.
		if "!change_size!"=="1" set /p new_size=TYPE THE NEW SIZE HERE:
		if not "!new_size!"=="e" set sizesystem=!new_size!
		goto:eof
	)
	ECHO THIS METHOD WILL DETECT SYSTEM SIZE IF POSSIBLE FROM YOUR DEVICE
	ECHO BE SURE FROM INSTALLING YOUR DEVICE DRIVERS IN THIS PC 
	ECHO THEN ENABLE [Usb debugging] AND CONNECT YOUR PHONE TO COMPUTER
	ECHO PRESS ANY KEY TO CONTINUE
	pause>nul
	echo DETECTING DEVICE RESPONSE
	call :device_response
	if "!error!"=="yes" goto detect_size
	ECHO DETECTING SYSTEM SIZE THROW ADB
	set size_k=0
	set link=n
	set file=n
	for /f "delims=" %%a in ('TOOLS\bin\adb devices ^| !busybox! grep -cw recovery') do if "%%a"=="1" call :detect_from_recovery_mode link /system
	if "!link!"=="n" for /f "delims=" %%a in ('TOOLS\bin\adb shell mount ^| !busybox! grep -e ' /system ' ^| TOOLS\bin\gawk "{print $1}"') do set link=%%a
	for /f "delims=" %%a in ('TOOLS\bin\adb shell ls -l !link! ^| TOOLS\bin\gawk "{print $NF}"') do set file=%%a
	for /f "delims=" %%a in ('tools\bin\busybox basename !file!') do set partition=%%a
	for /f "delims=" %%a in ('TOOLS\bin\adb shell cat /proc/partitions ^| !busybox! grep -w !partition! ^| TOOLS\bin\gawk "{print $3}"') do set size_k=%%a
	if "!size_k!"=="0" (
		echo SORRY BUT WE CAN'T DETECT SYSTEM SIZE
		pause>nul
		goto detect_size
	)
	if "!size_k!"=="" (
		echo SORRY BUT WE CAN'T DETECT SYSTEM SIZE
		pause>nul
		goto detect_size
	)
	set size_k=!size_k: =!
	if "!size_k!"=="0" (
		echo SORRY BUT WE CAN'T DETECT SYSTEM SIZE
		pause>nul
		goto detect_size
	)
	if "!size_k!"=="" (
		echo SORRY BUT WE CAN'T DETECT SYSTEM SIZE
		pause>nul
		goto detect_size
	)
	set test_size=0
	set test_size2=!sizesystem:M=!
	set /a test_size=!test_size2! * 1024
	if !test_size! gtr !size_k! (
		echo WE HAVE DETECTED SIZE [!size_k!] KBYTES
		echo BUT THE SYSTEM FOLDER SIZE IS [!test_size!] KBYTES
		echo AND AS YOU SEE THERE IS AN ERROR:
		echo THE SYSTEM FOLDER SIZE IS BIGGER THAN DEVICE SYSTEM SIZE
		echo IF WE CONTINUE YOUR DEVICE WILL BRICKED SO WE WILL STOP
		echo THIS HAPPENED IF THIS ROM NOT FOR THE SAME DEVICE
		echo THAT YOU DETECT SIZE FROM OR YOU PUT A LOT OF 
		echo FILES AND APKs IN THIS ROM
		echo PRESS ANY KEY TO BACK TO DETECT SIZES WINDOW
		pause>nul
		goto detect_size
	)
	echo DETECTED SIZE [!size_k!] KBYTES
	set sizesystem=!size_k!K
	goto:eof
:prepare_updater_for_build
	if not "!su_installer_detect!"=="0" (
		mkdir TOOLS\tmp\%1\supersu
		set root_size=n
		set root_size2=d
		for /f "delims=" %%s in ('TOOLS\bin\find WORK -name supersu.zip') do set root_size=%%~zs
		for %%z in (TOOLS\root\fast.zip) do set root_size2=%%~zz
		if "!root_size!"=="!root_size2!" ( copy TOOLS\root\fast.zip TOOLS\tmp\%1\supersu\supersu.zip > nul ) else ( copy TOOLS\root\classic.zip TOOLS\tmp\%1\supersu\supersu.zip > nul )
	)
	if not "%installertun2fs%"=="0" (
		copy TOOLS\installer\ext4.sh TOOLS\tmp\%1\META-INF\SCRIPTS\ext4.sh >nul
		copy TOOLS\installer\tune2fs TOOLS\tmp\%1\META-INF\SCRIPTS\tune2fs >nul
	)
	if not "%installerefs%"=="0" (
		copy TOOLS\installer\aroma\META-INF\SCRIPTS\efs_backup.sh TOOLS\tmp\%1\META-INF\SCRIPTS\efs_backup.sh >nul
	)
	if not "%installerwipe%"=="0" if not exist "!aroma_config!" (
		copy TOOLS\installer\aroma\META-INF\SCRIPTS\wipe.sh TOOLS\tmp\%1\META-INF\SCRIPTS\wipe.sh >nul
	)
	set updater_script2=TOOLS/tmp/%1/META-INF/com/google/android/updater-script
	echo # AUTO GENERATED BY ASSAYYED KITCHEN >> !updater_script2!
	echo ui_print("INSTALLING !rom_build_name! ROM STARTED");>>!updater_script2!
	echo ui_print("-- Preparing partitions");>>!updater_script2!
	echo package_extract_dir("META-INF/SCRIPTS", "/tmp");>> !updater_script2!
	set s1=if exist "WORK\system\addon.d"
	%s1% xcopy TOOLS\installer\addond TOOLS\tmp\%1\META-INF /e /i /h /y>nul
	%s1% echo mount("ext4", "EMMC", "!system_path!", "/system", "");>>!updater_script2!
	%s1% echo ui_print("-- Backing up addon.d scripts");>>!updater_script2!
	%s1% echo package_extract_dir("META-INF/install", "/tmp/install");>>!updater_script2!
	%s1% echo set_metadata_recursive("/tmp/install", "uid", 0, "gid", 0, "dmode", 0755, "fmode", 0644);>> !updater_script2!
	%s1% echo set_metadata_recursive("/tmp/install/bin", "uid", 0, "gid", 0, "dmode", 0755, "fmode", 0755);>> !updater_script2!
	%s1% echo run_program("/tmp/install/bin/backuptool.sh", "backup");>>!updater_script2!
	if exist "TOOLS\tmp\%1\META-INF\SCRIPTS\efs_backup.sh" echo ui_print("-- Backing up efs partition");>> !updater_script2!
	if exist "TOOLS\tmp\%1\META-INF\SCRIPTS\efs_backup.sh" echo set_metadata("/tmp/efs_backup.sh", "uid", 0, "gid", 0, "mode", 0777);>> !updater_script2!
	if exist "TOOLS\tmp\%1\META-INF\SCRIPTS\efs_backup.sh" echo run_program("/tmp/efs_backup.sh");>> !updater_script2!
	if exist "TOOLS\tmp\%1\META-INF\SCRIPTS\wipe.sh" echo ui_print("-- Wiping all user data files");>> !updater_script2!
	if exist "TOOLS\tmp\%1\META-INF\SCRIPTS\wipe.sh" echo run_program("/sbin/mount", "-t", "auto", "/data");>>!updater_script2!
	if exist "TOOLS\tmp\%1\META-INF\SCRIPTS\wipe.sh" echo set_metadata("/tmp/wipe.sh", "uid", 0, "gid", 0, "mode", 0777);>> !updater_script2!
	if exist "TOOLS\tmp\%1\META-INF\SCRIPTS\wipe.sh" echo run_program("/tmp/wipe.sh");>> !updater_script2!
	echo ifelse(is_mounted("/system"), unmount("/system"));>>!updater_script2!
	echo ui_print("-- Flashing system image");>>!updater_script2!
	if "%1"=="buildraw" echo package_extract_file("system.img", "%system_path%");>>!updater_script2!
	if "%1"=="builddat" echo block_image_update("%system_path%", package_extract_file("system.transfer.list"), "system.new.dat", "system.patch.dat");>>!updater_script2!
	echo mount("ext4", "EMMC", "%system_path%", "/system", "");>>!updater_script2!
	set chmod=06755
	if "!api!" geq "18" set chmod=0755
	if exist "WORK\system\etc\init.d\99supersudaemon" echo set_metadata("/system/etc/init.d/99supersudaemon", "uid", 0, "gid", 0, "mode", 0744, "capabilities", 0x0, "selabel", "u:object_r:system_file:s0"); >> !updater_script2!
	if exist "WORK\system\bin\app_process_init" echo set_metadata("/system/bin/app_process_init", "uid", 0, "gid", 2000, "mode", 0755, "capabilities", 0x0, "selabel", "u:object_r:system_file:s0"); >> !updater_script2!
	if exist "WORK\system\etc\install-recovery.sh" echo set_metadata("/system/etc/install-recovery.sh", "uid", 0, "gid", 0, "mode", 0755, "capabilities", 0x0, "selabel", "u:object_r:system_file:s0"); >> !updater_script2!
	if exist "WORK\system\app\superuser.apk" echo set_metadata("/system/app/Superuser.apk", "uid", 0, "gid", 0, "mode", 0644, "capabilities", 0x0, "selabel", "u:object_r:system_file:s0"); >> !updater_script2!
	if exist "WORK\system\app\supersu\supersu.apk" echo set_metadata("/system/app/SuperSU/SuperSU.apk", "uid", 0, "gid", 0, "mode", 0644, "capabilities", 0x0, "selabel", "u:object_r:system_file:s0"); >> !updater_script2!
	if exist "WORK\system\app\supersu" echo set_metadata("/system/app/SuperSU", "uid", 0, "gid", 0, "mode", 0755, "capabilities", 0x0, "selabel", "u:object_r:system_file:s0"); >> !updater_script2!
	if exist "WORK\system\lib64\libsupol.so" echo set_metadata("/system/lib64/libsupol.so", "uid", 0, "gid", 0, "mode", 0644, "capabilities", 0x0, "selabel", "u:object_r:system_file:s0"); >> !updater_script2!
	if exist "WORK\system\lib\libsupol.so" echo set_metadata("/system/lib/libsupol.so", "uid", 0, "gid", 0, "mode", 0644, "capabilities", 0x0, "selabel", "u:object_r:system_file:s0"); >> !updater_script2!
	if exist "WORK\system\xbin\supolicy" echo set_metadata("/system/xbin/supolicy", "uid", 0, "gid", 0, "mode", 0755, "capabilities", 0x0, "selabel", "u:object_r:system_file:s0"); >> !updater_script2!
	if exist "WORK\system\xbin\sugote" echo set_metadata("/system/xbin/sugote", "uid", 0, "gid", 0, "mode", 0755, "capabilities", 0x0, "selabel", "u:object_r:zygote_exec:s0"); >> !updater_script2!
	if exist "WORK\system\xbin\sugote-mksh" echo set_metadata("/system/xbin/sugote-mksh", "uid", 0, "gid", 0, "mode", 0755, "capabilities", 0x0, "selabel", "u:object_r:system_file:s0"); >> !updater_script2!
	if exist "WORK\system\xbin\daemonsu" echo set_metadata("/system/xbin/daemonsu", "uid", 0, "gid", 0, "mode", 0755, "capabilities", 0x0, "selabel", "u:object_r:system_file:s0"); >> !updater_script2!
	if exist "WORK\system\xbin\su" if not exist "WORK\system\addon.d" echo set_metadata("/system/xbin/su", "uid", 0, "gid", 0, "mode", !chmod!, "capabilities", 0x0, "selabel", "u:object_r:system_file:s0"); >> !updater_script2!
	if exist "WORK\system\xbin\su" if exist "WORK\system\addon.d" echo set_metadata("/system/xbin/su", "uid", 0, "gid", 0, "mode", 0755, "capabilities", 0x0, "selabel", "u:object_r:su_exec:s0"); >> !updater_script2!
	if exist "WORK\system\bin\.ext\.su" echo set_metadata("/system/bin/.ext/.su", "uid", 0, "gid", 0, "mode", !chmod!, "capabilities", 0x0, "selabel", "u:object_r:system_file:s0"); >> !updater_script2!
	if exist "WORK\system\bin\.ext" echo set_metadata("/system/bin/.ext", "uid", 0, "gid", 0, "mode", 0777, "capabilities", 0x0, "selabel", "u:object_r:system_file:s0"); >> !updater_script2!
	if exist "WORK\system\xbin\su" if not exist "WORK\system\addon.d" echo run_program("/system/xbin/su", "--install"); >> !updater_script2!
	if exist "WORK/system/xbin/busybox" echo run_program("/system/xbin/busybox", "--install", "-s", "/system/xbin");>>!updater_script2!
	if exist "TOOLS\tmp\%1\META-INF\SCRIPTS\ext4.sh" echo ui_print("-- Running rom configuration");>> !updater_script2!
	if exist "TOOLS\tmp\%1\META-INF\SCRIPTS\ext4.sh" echo set_metadata("/tmp/ext4.sh", "uid", 0, "gid", 0, "mode", 0777);>> !updater_script2!
	if exist "TOOLS\tmp\%1\META-INF\SCRIPTS\ext4.sh" echo set_metadata("/tmp/tune2fs", "uid", 0, "gid", 0, "mode", 0777);>> !updater_script2!
	if exist "TOOLS\tmp\%1\META-INF\SCRIPTS\ext4.sh" echo run_program("/tmp/ext4.sh"); >> !updater_script2!
	echo ui_print("-- Flashing kernel image");>>!updater_script2!
	set kernel_extract=boot.img
	if not exist "work\boot.img" if exist "work\kernel.sin.bak" set kernel_extract=kernel.sin.bak
	echo package_extract_file("!kernel_extract!", "/tmp/boot.img");>> !updater_script2!
	echo set_metadata("/tmp/flash_kernel.sh", "uid", 0, "gid", 0, "mode", 0777);>> !updater_script2!
	echo run_program("/tmp/flash_kernel.sh");>> !updater_script2!
	if exist "WORK\system\addon.d" echo ui_print("-- Restoring addon.d scripts");>>!updater_script2!
	if exist "WORK\system\addon.d" echo run_program("/tmp/install/bin/backuptool.sh", "restore");>>!updater_script2!
	if exist "TOOLS\tmp\%1\supersu" echo ui_print("-- Rooting rom with supersu");>>!updater_script2!
	if exist "TOOLS\tmp\%1\supersu" echo package_extract_dir("supersu", "/tmp/supersu");>>!updater_script2!
	if exist "TOOLS\tmp\%1\supersu" echo run_program("/sbin/busybox", "unzip", "/tmp/supersu/supersu.zip", "META-INF/com/google/android/update-binary", "-d", "/tmp/supersu");>>!updater_script2!
	if exist "TOOLS\tmp\%1\supersu" echo run_program("/sbin/busybox", "sh", "/tmp/supersu/META-INF/com/google/android/update-binary", "dummy", "1", "/tmp/supersu/supersu.zip");>>!updater_script2!
	echo ifelse(is_mounted("/system"), unmount("/system"));>>!updater_script2!
	echo ui_print("INSTALLING !rom_build_name! ROM FINISHED");>>!updater_script2!
	TOOLS\bin\dos2unix -q !updater_script2!>nul
	goto:eof
:detect_from_recovery_mode
	for /f "delims=" %%a in ('TOOLS\bin\adb shell cat /etc/recovery.fstab ^| !busybox! grep -w %2 ^| TOOLS\bin\gawk "{print $1}"') do set first_character=%%a
	for /f "delims=" %%a in ('TOOLS\bin\adb shell cat /etc/recovery.fstab ^| !busybox! grep -w %2 ^| TOOLS\bin\gawk "{print $2}"') do set second_character=%%a
	for /f "delims=" %%a in ('TOOLS\bin\adb shell cat /etc/recovery.fstab ^| !busybox! grep -w %2 ^| TOOLS\bin\gawk "{print $3}"') do set third_character=%%a
	if "!first_character!"=="%2" echo !third_character!>>TOOLS\tmp\sort
	if "!second_character!"=="%2" echo !first_character!>>TOOLS\tmp\sort
	TOOLS\bin\dos2unix -q TOOLS\tmp\sort
	!busybox! sort -u < TOOLS\tmp\sort > TOOLS\tmp\path
	del TOOLS\tmp\sort
	set /p %1=<TOOLS\tmp\path
	del TOOLS\tmp\path
	goto:eof
:instweaks
	if not exist "WORK\system\build.prop" (
		ECHO THERE IS NO [build.prop] FILE TO TWEAKING IT
		pause>nul
		goto start
	)
	set tweaks_test=0
	for /f "delims=" %%a in ('!busybox! grep -c ASSAYYED_KITCHEN_AUTO_TWEAKS WORK/system/build.prop') do set tweaks_test=%%a
	if not "!tweaks_test!"=="0" (
		echo REMOVING [build.prop] TWEAKS
		del TOOLS\tmp\build_prop_tweaken
		!busybox! sed -i '/^ASSAYYED_KITCHEN_AUTO_TWEAKS/d' "WORK\system\build.prop"
		for /f "delims=" %%a in ('type "TOOLS\tweaks\prop_tweaks_rm"') do !busybox! sed -i '/^%%a/d' "WORK\system\build.prop"
		goto completed
	)
	ECHO IT IS VERY GOOD CHOICE TO ADD TWEAKS
	ECHO WILL OPTIMIZE ROM PERFORMANCE IN GENERAL
	set tweak=null
	set /p tweak=START TWEAKING OR BACK [DEFAULT=YES 0=NO]:
	if "!tweak!"=="0" goto start
	set tweak=null
	echo REMOVING OLD TWEAKS IF EXISTS
	for /f "delims=" %%a in ('type "TOOLS\tweaks\prop_tweaks_rm"') do !busybox! sed -i '/^%%a/d' "WORK\system\build.prop"
	echo WRITTING NEW TWEAKS
	echo tweaken >>TOOLS\tmp\build_prop_tweaken
	echo. >>WORK\system\build.prop
	echo # ASSAYYED_KITCHEN_AUTO_TWEAKS>>WORK\system\build.prop
	!busybox! cat TOOLS\tweaks\prop_tweaks >> WORK/system/build.prop
	TOOLS\bin\dos2unix -q WORK/system/build.prop>nul
	goto completed
:init.d
	if not exist "WORK\system\build.prop" (
		echo NO ROM FOUND TO ADD INIT.D SUPPORT
		pause>nul
		goto start
	)
	if exist "WORK\system\bin\debuggerd.real" (
		echo REMOVING INIT.D SUPPORT
		del WORK\system\bin\debuggerd
		ren WORK\system\bin\debuggerd.real debuggerd
		if exist "WORK\system\etc\init.d\00archidroid_initd" del WORK\system\etc\init.d\00archidroid_initd
		goto completed
	)
	set decideromintid=null
	echo THIS WILL ENABLE RUN SCRIPT IN [system\etc\init.d]
	echo IT USED TO ADD SCRIPTS LIKE TWEAKS IN THIS FOLDER
	echo TO RUN ON EVERY BOOT..BY DEVELOPER [JustArchi]
	set /p decideromintid=DO YOU WANT TO ADD IT OR NOT [DEFAULT=YES 0=BACK]:
	if "%decideromintid%"=="0" goto start
	set decideromintid=null
	echo ADDING INIT.D SUPPORT
	ren WORK\system\bin\debuggerd debuggerd.real
	if exist "WORK\system\etc\init.d\00archidroid_initd" del WORK\system\etc\init.d\00archidroid_initd
	xcopy "TOOLS\init.d" "WORK/system" /e /i /h /y>nul
	goto completed
:knox
	if not exist "WORK\system" (
		echo NO ROM FOUND TO DEKNOX
		pause>nul
		goto start
	)
	if exist "WORK\knox" (
		echo RESTORING ALL KNOX FILES
		xcopy WORK\knox WORK\system /e /i /h /y >nul
		rmdir /s /q WORK\knox
		goto completed
	)
	if not exist "WORK\system\etc\secure_storage\com.sec.knox.seandroid" (
		if not exist "WORK\system\etc\secure_storage\com.sec.knox.store" (
			if not exist "WORK\system\container" (
				if not exist "WORK\system\containers" (
					if not exist "WORK\system\preloadedsso" (
						if not exist "WORK\system\app\knoxagent*" (
							if not exist "WORK\system\priv-app\knoxagent*" (
								echo THIS ROM DOESN'T CONTENT KNOX
								pause>nul
								goto start
							)
						)
					)
				)
			)
		)
	)
	set decideknox=null
	ECHO THIS WILL REMOVE ALL KNOX FILES [THAT SYSTEM PROTECT ROM FROM ROOT]
	ECHO ITS BAD ON CUSTOM ROMS AND RECOMMENDED TO REMOVE
	ECHO NOTE: [YOU CAN RESTORE THIS FILES BY SAME COMMAND]
	set /p decideknox=DO YOU WANT TO REMOVE IT OR NOT [DEFAULT=YES 0=BACK]:
	if "%decideknox%"=="0" goto start
	set decideknox=null
	call :clean_apks
	call :clean_rom KNOX knox
	goto completed
:clean_rom
	for /f "delims=" %%a in ('type "TOOLS\txt_files\%2.txt"') do (
		for /f "delims=" %%b in ('TOOLS\bin\find WORK/system -name %%a ^| !busybox! tr / \\') do (
			for /f "delims=" %%c in ('!busybox! dirname %%b') do (
				set orig_dir=%%c
				set test_folder=%%~nc%%~xc
			)
			for /f "delims=" %%d in ('!busybox! dirname %%b ^| !busybox! sed "s/WORK\\\system/WORK\\\%1/g"') do set dest_dir=%%d
			for /f "delims=" %%e in ('!busybox! dirname !dest_dir!') do set dest_dir2=%%e
			if "%%~nb"=="!test_folder!" (
				if exist !updater_script! if not exist "TOOLS\tmp\updater_script_backup" copy !updater_script! TOOLS\tmp\updater_script_backup >nul
				if not exist "TOOLS\tmp\original_symlinks_backup" copy TOOLS\tmp\original_symlinks TOOLS\tmp\original_symlinks_backup >nul
				!busybox! sed -i '/^\/%%~nb\//d' TOOLS/tmp/original_symlinks !updater_script!
				echo MOVING %1 CONTENT [%%~nb%%~xb]
				mkdir !dest_dir2!
				move !orig_dir! !dest_dir! >nul
			) else (
				echo MOVING %1 CONTENT [%%~nb%%~xb]
				mkdir !dest_dir!
				move %%b !dest_dir!\%%~nb%%~xb >nul
				move !orig_dir!\%%~nb.odex !dest_dir!\%%~nb.odex >nul
			)
		)
	)
	goto:eof
:bloat
	if not exist "WORK\system" (
		echo NO ROM FOUND TO DEBLOAT
		pause>nul
		goto start
	)
	if exist "WORK\bloat" (
		echo RESTORING ALL BLOAT FILES
		xcopy WORK\bloat WORK\system /e /i /h /y >nul
		rmdir /s /q WORK\bloat
		del TOOLS\tmp\debloated
		if exist "!updater_script!" if exist "TOOLS\tmp\updater_script_backup" (
			del !updater_script!
			move TOOLS\tmp\updater_script_backup !updater_script! >nul
		)
		if exist "TOOLS\tmp\original_symlinks_backup" if exist "TOOLS\tmp\original_symlinks" (
			del TOOLS\tmp\original_symlinks
			move TOOLS\tmp\original_symlinks_backup TOOLS\tmp\original_symlinks >nul
		)
		goto completed
	)
	set decidelbloat=null
	ECHO FOR AUTO DEBLOAT ONLY:
	ECHO THIS WILL REMOVE SOME APPS AND FILES THAT 
	ECHO UNNECCESARY TO GET MORE FREE RAM AND FASTER
	ECHO NOTE: [YOU CAN RESTORE THIS FILES BY SAME COMMAND]
	set /p decidelbloat=WHICH DEBLOAT YOU WANT [DEFAULT=CHOOSE_LIST 1=MANUAL 2=REMOVE_CSC_APKs 0=BACK]:
	if "%decidelbloat%"=="0" goto start
	if "%decidelbloat%"=="2" (
		if not exist "WORK\system\csc" (
			echo THERE IS [WORK\system\csc] FOLDER
			PAUSE>NUL
			goto start
		)
		for /f "delims=" %%a in ('TOOLS\bin\find WORK/system/csc -name *.apk ^| !busybox! wc -l') do if "%%a"=="0" (
			echo THE CSC FOLDER IS CLEAN
			PAUSE>NUL
			goto start
		)
		for /f "delims=" %%a in ('TOOLS\bin\find WORK/system/csc -name *.apk') do (
			ECHO REMOVING [%%~na%%~xa]
			!busybox! rm -rf %%a
		)
		goto completed
	)
	if "%decidelbloat%"=="1" (
		call :clean_apks
		goto mandebloat
	)
	set decidelbloat=null
	call :clean_apks
:print_lists
	cls
	echo.
	echo.
	echo IF YOU WANT TO ADD YOUR CUSTOM DEBLOAT LIST TO USE IT
	echo ADD IT TO [TOOLS/txt_files/*.txt] AND NAME IT AS YOU WANT
	echo BUT REMOVE SPACES FROM THE LIST NAME AND MAKE EXTENSION [.txt]
	echo --------------------------------------------------------------
	set count=0
	for %%f in (TOOLS\txt_files\*.txt) do (
		if not "%%~nf"=="tools_versions" if not "%%~nf"=="files" if not "%%~nf"=="knox" if not "%%~nf"=="metadata" if not "%%~nf"=="random_metadata" if not "%%~nf"=="set_perm" if not "%%~nf"=="symlinks_list" (
			set /a count=!count!+1
			if !count! leq 9 (
				if "%%~nf"=="bloat" echo    !count! == ASSAYYED KITCHEN LIST
				if "%%~nf"=="kushan_debloat_list" echo    !count! == KUSHAN02 DEV LIST
				if not "%%~nf"=="bloat" if not "%%~nf"=="kushan_debloat_list" echo    !count! == %%~nf%%~xf
			)
			if !count! geq 10 if !count! leq 99 (
				if "%%~nf"=="bloat" echo   !count! == ASSAYYED KITCHEN LIST
				if "%%~nf"=="kushan_debloat_list" echo   !count! == KUSHAN02 DEV LIST
				if not "%%~nf"=="bloat" if not "%%~nf"=="kushan_debloat_list" echo   !count! == %%~nf%%~xf
			)
		)
	)
	echo --------------------------------------------------------------
	echo.
	set filenumber=rr
	set /p filenumber=SELECT LIST YOU WANT [ENTER=REFRESH] [0=BACK]:
	set filenumber=%filenumber: =x%
	if "!filenumber!"=="0" goto start
	if "!filenumber!"=="rr" goto print_lists
	set count=0
	set file=n
	for %%f in (TOOLS\txt_files\*.txt) do (
		if not "%%~nf"=="tools_versions" if not "%%~nf"=="files" if not "%%~nf"=="knox" if not "%%~nf"=="metadata" if not "%%~nf"=="random_metadata" if not "%%~nf"=="set_perm" if not "%%~nf"=="symlinks_list" (
			set /a count=!count!+1
			if "!count!"=="!filenumber!" set file=%%~nf
		)
	)
	if "!file!"=="n" goto print_lists
	call :clean_rom BLOAT !file!
	if not exist "WORK\bloat" (
		echo IT SEEMS THIS ROM DOESN'T NEED TO DEBLOAT
		echo debloated>>TOOLS\tmp\debloated
		pause>nul
		goto start
	)
	echo debloated>>TOOLS\tmp\debloated
	goto completed
:clean_apks
	echo CLEANING UP APKS
	for /f "delims=" %%c in ('TOOLS\bin\find WORK/system -name *.apk') do (
		set file=%%c
		set file=!file:/=\!
		if "%%~zc"=="0" !busybox! rm -rf %%c
		move !file! TOOLS\tmp\apk_cleaned.apk >nul
		if exist "%%c" !busybox! rm -rf %%c
		move TOOLS\tmp\apk_cleaned.apk !file! >nul
	)
	goto:eof
:mandebloat
	cls
	echo.
	echo.
	echo --------------------------------------------------------------
	set count=0
	for /f "delims=" %%f in ('TOOLS\bin\find work/system ^| !busybox! grep \.apk$') do (
		set /a count=!count!+1
		if !count! leq 9 echo    !count! == %%~nf%%~xf
		if !count! geq 10 if !count! leq 99 echo   !count! == %%~nf%%~xf
		if !count! geq 100 echo  !count! == %%~nf%%~xf
	)
	echo --------------------------------------------------------------
	echo.
	set filenumber=rr
	set /p filenumber=SELECT FILE TO REMOVE [0=BACK]:
	set filenumber=%filenumber: =x%
	if "!filenumber!"=="0" goto start
	if "!filenumber!"=="rr" goto mandebloat
	set count=0
	set file=n
	for /f "delims=" %%f in ('TOOLS\bin\find work/system ^| !busybox! grep \.apk$') do (
		set /a count=!count!+1
		if "!count!"=="!filenumber!" set file=%%~nf
	)
	for /f "delims=" %%a in ('TOOLS\bin\find WORK/system -name !file!* ^| !busybox! grep -w !file!') do !busybox! rm -rf %%a
	goto mandebloat
:kernelunpack
	if exist "WORK\!img_dir!" (
		echo REMOVING UNPACKED [!img_file!]
		rmdir /s /q WORK\!img_dir!
		goto kernel_recovery_menu
	)
	if exist "work\kernel.sin" if not exist "work\boot.img" (
		echo CONVERTING [kernel.sin] TO [boot.img]
		set img_dir=converting_sin
		set img_file=kernel.sin
		call :kernelunpack3
		set img_file=boot.img
		set img_dir=boot_unpacked
		set kernelunpackq=y
		echo UNPACKING [!img_file!] TO [WORK\!img_dir!]
		call :kernelunpack
		goto kernel_recovery_menu
	)
	if not !kernelunpackq! ==y if not exist "WORK\!img_file!" (
		echo NO [!img_file!] FOUND TO UNPACK
		pause>nul
		goto kernel_recovery_menu
	)
	for /f "delims=" %%a in ('!busybox! od -A n -h -j 0 -N 8 WORK/!img_file! ^| !busybox! sed "s/ //g"') do if not "%%a"=="4e415244494f2144" (
		if not "!kernelunpackq!"=="y" echo THE [!img_file!] HEADER IS NOT STANDARD, DETECTING THE NEW OFFSET
		for /f "delims=" %%b in ('!busybox! od -x -A x WORK/!img_file! ^| !busybox! grep -m 1 "4e41 [ ]*5244 [ ]*494f [ ]*2144" ^| !busybox! sed -e "s/ .*//g"') do set hex_offset=%%b
		if not "!hex_offset!"=="" (
			for /f "delims=" %%b in ('!busybox! printf "%%d" 0x!hex_offset!') do set dd_skip=%%b
			if not "!kernelunpackq!"=="y" echo DETECTED NEW OFFSET [!dd_skip!], RESTORING IT TO THE STANDARD [2048]
			!busybox! dd if=WORK/!img_file! of=WORK/fixed_header.img bs=1 skip=!dd_skip!
			del WORK\!img_file!
			ren WORK\fixed_header.img !img_file!
		) else ( if not "!kernelunpackq!"=="y" echo ERROR: UNSOPPORTED HEADER OFFSET, CONTINUE ANYWAY )
	)
	if not !kernelunpackq! ==y echo UNPACKING [!img_file!] TO [WORK\!img_dir!]
	mkdir WORK\!img_dir!\split_img
	cd WORK\!img_dir!\split_img
	"../../../TOOLS/kernel/unpackbootimg" -i "../../!img_file!">nul
	if !kernelunpackq! ==y if errorlevel ==1 (
		cd ..\..\..
		!busybox! rm -rf WORK\!img_dir!
		goto kernelunpack2
	)
	if not !kernelunpackq! ==y if errorlevel ==1 (
		cd ..\..\..
		"TOOLS\bin\cecho" {0c}FAILED...TRYING SECOND METHOD{#}
		!busybox! rm -rf WORK\!img_dir!
		goto kernelunpack2 
	)
	"../../../TOOLS/kernel/file" -m ../../../TOOLS/kernel/magic *-ramdisk.gz | ..\..\..\!busybox! cut -d: -f2 | ..\..\..\!busybox! cut -d" " -f2 > "!img_file!-ramdiskcomp"
	for /f "delims=" %%a in ('type "!img_file!-ramdiskcomp"') do @set ramdiskcomp=%%a
	if "%ramdiskcomp%" == "gzip" (
		set unpackcmd=gzip -dc
		set "compext=gz"
	)
	if "%ramdiskcomp%" == "lzop" (
		set unpackcmd=lzop -dc
		set "compext=lzo"
	)
	if "%ramdiskcomp%" == "lzma" (
		set unpackcmd=xz -dc
		set "compext=lzma"
	)
	if "%ramdiskcomp%" == "xz" (
		set unpackcmd=xz -dc
		set "compext=xz"
	)
	if "%ramdiskcomp%" == "bzip2" (
		set unpackcmd=bzip2 -dc
		set "compext=bz2"
	)
	if "%ramdiskcomp%" == "lz4" (
		set unpackcmd=lz4
		set "extra=stdout 2>nul"
		set "compext=lz4"
	) else ( set "extra= " )
	ren *ramdisk.gz *ramdisk.cpio.%compext%
	cd ..
	mkdir ramdisk
	cd ramdisk
	if !kernelunpackq! ==y if "!compext!" == "" (
		cd ..\..\..
		!busybox! rm -rf WORK\!img_dir!
		goto kernelunpack2
	)
	if not !kernelunpackq! ==y if "!compext!" == "" (
		cd ..\..\..
		"TOOLS\bin\cecho" {0c}FAILED...TRYING SECOND METHOD{#}
		!busybox! rm -rf WORK\!img_dir!
		goto kernelunpack2
	)
	..\..\..\TOOLS\kernel\%unpackcmd% "../split_img/!img_file!-ramdisk.cpio.!compext!" !extra! | ..\..\..\TOOLS\kernel\cpio -i 
	if !kernelunpackq! ==y if errorlevel == 1 (
		cd ..\..\..
		!busybox! rm -rf WORK\!img_dir!
		goto kernelunpack2
	)
	if not !kernelunpackq! ==y if errorlevel == 1 (
		cd ..\..\..
		"TOOLS\bin\cecho" {0c}FAILED...TRYING SECOND METHOD{#}
		!busybox! rm -rf WORK\!img_dir!
		goto kernelunpack2
	)
	cd ..\..\..
	if exist "WORK\!img_dir!\ramdisk\sbin\ramdisk.cpio" (
		move WORK\!img_dir!\ramdisk WORK\!img_dir!\ramdisk_origin>nul
		mkdir WORK\!img_dir!\ramdisk
		cd WORK\!img_dir!\ramdisk
		..\..\..\TOOLS\kernel\cpio -i <..\ramdisk_origin\sbin\ramdisk.cpio>nul
		cd ..\..\..
	)
	if !kernelunpackq! ==y goto:eof
	if not !kernelunpackq! ==y goto kernel_recovery_menu
:kernelunpack2
	mkdir WORK\!img_dir!
	copy WORK\!img_file! WORK\!img_dir!\boot.img>nul
	copy TOOLS\kernel\bootimg.exe WORK\!img_dir!>nul
	cd WORK\!img_dir!
	bootimg --unpack-bootimg>nul
	cd ..\..
	if not !kernelunpackq! ==y if not exist "WORK\!img_dir!\initrd\sbin" (
		echo.
		TOOLS\bin\cecho {0c}SECOND METHOD FAILED...TRYING LAST METHOD{#}
		echo.
		!busybox! rm -rf WORK\!img_dir!
		goto kernelunpack3
	)
	if !kernelunpackq! ==y if not exist "WORK\!img_dir!\initrd\sbin" (
		!busybox! rm -rf WORK\!img_dir!
		goto kernelunpack3
	)
	move WORK\!img_dir!\initrd WORK\!img_dir!\ramdisk>nul
	if exist "WORK\!img_dir!\ramdisk\sbin\ramdisk.cpio" (
		move WORK\!img_dir!\ramdisk WORK\!img_dir!\ramdisk_origin>nul
		mkdir WORK\!img_dir!\ramdisk
		cd WORK\!img_dir!\ramdisk
		..\..\..\TOOLS\kernel\cpio -i <..\ramdisk_origin\sbin\ramdisk.cpio>nul
		cd ..\..\..
	)
	if !kernelunpackq! ==y goto:eof
	if not !kernelunpackq! ==y goto kernel_recovery_menu
:kernelpack
	if exist "WORK\!img_dir!\ramdisk_origin" (
		rmdir /s /q WORK\!img_dir!\ramdisk
		move WORK\!img_dir!\ramdisk_origin WORK\!img_dir!\ramdisk>nul
	)
	if exist "WORK\!img_dir2!" (
		echo REMOVING [!img_dir2!]
		rmdir /s /q WORK\!img_dir2!
		goto kernel_recovery_menu
	)
	if not exist "WORK\!img_dir!" (
		echo NO [!img_file!] UNPACKED FOUND
		pause>nul
		goto kernel_recovery_menu
	)
	if exist "WORK\!img_dir!\bootimg.exe" goto kernelpack2
	if not exist "WORK\!img_dir!\bootimg.exe" if not exist "WORK\!img_dir!\split_img" goto kernelpack3
	if not "!kernelunpackq!"=="y" echo REPACKING [!img_file!] FILE TO WORK FOLDER
	for /f "delims=" %%a in ('dir /b WORK\!img_dir!\split_img\*-ramdiskcomp') do @set ramdiskcname=%%a
	for /f "delims=" %%a in ('type "WORK\!img_dir!\split_img\%ramdiskcname%"') do @set ramdiskcomp=%%a
	if "%ramdiskcomp%" == "gzip" (
		set "repackcmd=gzip "
		set "compext=gz"
	)
	if "%ramdiskcomp%" == "lzop" (
		set "repackcmd=lzop "
		set "compext=lzo"
	)
	if "%ramdiskcomp%" == "lzma" (
		set "repackcmd=xz -Flzma "
		set "compext=lzma"
	)
	if "%ramdiskcomp%" == "xz" (
		set "repackcmd=xz  -Ccrc32"
		set "compext=xz"
	)
	if "%ramdiskcomp%" == "bzip2" (
		set "repackcmd=bzip2 "
		set "compext=bz2"
	)
	if "%ramdiskcomp%" == "lz4" (
		set "repackcmd=lz4  stdin stdout 2>nul"
		set "compext=lz4"
	)
	TOOLS\kernel\mkbootfs WORK\!img_dir!\ramdisk  | TOOLS\kernel\%repackcmd%  > ramdisk-new.cpio.%compext%
	if errorlevel == 1 (
		"TOOLS\bin\cecho" {0c}CAN'T REPACK THIS KERNEL{#}
		pause>nul
		goto start
	)
	for /f "delims=" %%a in ('dir /b WORK\!img_dir!\split_img\*-zimage') do @set kernel=%%a
	for /f "delims=" %%a in ('dir /b WORK\!img_dir!\split_img\*-ramdisk.cpio*') do @set ramdisk=%%a
	if not "%1" == "--original" set "ramdisk=--ramdisk ramdisk-new.cpio.%compext%"
	for /f "delims=" %%a in ('dir /b WORK\!img_dir!\split_img\*-cmdline') do @set cmdname=%%a
	for /f "delims=" %%a in ('type "WORK\!img_dir!\split_img\%cmdname%"') do @set cmdline=%%a
	for /f "delims=" %%a in ('dir /b WORK\!img_dir!\split_img\*-board') do @set boardname=%%a
	for /f "delims=" %%a in ('type "WORK\!img_dir!\split_img\%boardname%"') do @set board=%%a
	for /f "delims=" %%a in ('dir /b WORK\!img_dir!\split_img\*-base') do @set basename=%%a
	for /f "delims=" %%a in ('type "WORK\!img_dir!\split_img\%basename%"') do @set base=%%a
	for /f "delims=" %%a in ('dir /b WORK\!img_dir!\split_img\*-pagesize') do @set pagename=%%a
	for /f "delims=" %%a in ('type "WORK\!img_dir!\split_img\%pagename%"') do @set pagesize=%%a
	for /f "delims=" %%a in ('dir /b WORK\!img_dir!\split_img\*-kerneloff') do @set koffname=%%a
	for /f "delims=" %%a in ('type "WORK\!img_dir!\split_img\%koffname%"') do @set kerneloff=%%a
	for /f "delims=" %%a in ('dir /b WORK\!img_dir!\split_img\*-ramdiskoff') do @set roffname=%%a
	for /f "delims=" %%a in ('type "WORK\!img_dir!\split_img\%roffname%"') do @set ramdiskoff=%%a
	for /f "delims=" %%a in ('dir /b WORK\!img_dir!\split_img\*-tagsoff') do @set toffname=%%a
	for /f "delims=" %%a in ('type "WORK\!img_dir!\split_img\%toffname%"') do @set tagsoff=%%a
	if exist "WORK\!img_dir!\split_img\*-second" for /f "delims=" %%a in ('dir /b WORK\!img_dir!\split_img\*-second') do @set second=%%a
	if exist "WORK\!img_dir!\split_img\*-second" set "second=--second "WORK\!img_dir!\split_img\%second%""
	if exist "WORK\!img_dir!\split_img\*-second" for /f "delims=" %%a in ('dir /b WORK\!img_dir!\split_img\*-secondoff') do @set soffname=%%a
	if exist "WORK\!img_dir!\split_img\*-second" for /f "delims=" %%a in ('type "WORK\!img_dir!\split_img\%soffname%"') do @set secondoff=%%a
	if exist "WORK\!img_dir!\split_img\*-second" set "second_offset=--second_offset %secondoff%"
	if exist "WORK\!img_dir!\split_img\*-dtb" for /f "delims=" %%a in ('dir /b WORK\!img_dir!\split_img\*-dtb') do @set dtb=%%a
	if exist "WORK\!img_dir!\split_img\*-dtb" set "dtb=--dt "WORK\!img_dir!\split_img\%dtb%""
	TOOLS\kernel\mkbootimg --kernel "WORK\!img_dir!\split_img/%kernel%" %ramdisk% %second% --cmdline "%cmdline%" --board "%board%" --base %base% --pagesize %pagesize% --kernel_offset %kerneloff% --ramdisk_offset %ramdiskoff% %second_offset% --tags_offset %tagsoff% %dtb% -o work\image-new.img 
	if errorlevel == 1 (
		TOOLS\bin\cecho {0c}CAN'T REPACK THIS KERNEL{#}
		pause>nul
		goto kernel_recovery_menu
	)
	del ramdisk-new.cpio.%compext%
	if not "!kernelunpackq!"=="y" if %ramdiskcomp% ==lzop (
		echo WARNING: THIS [!img_file!] IS DEVELOPED BY HIGH PROFESSIONAL TOOLS
		ECHO AND SO THE KITCHEN REPACKED IT USING [LZOP] METHOD AND 
		echo SOMTIMES THIS METHOD CAUSE BOOTLOOP SO PLEASE BACKUP YOUR [!img_file!] FIRST.
	)
	set movehardkernel=null
	if not "!kernelunpackq!"=="y" if %ramdiskcomp% ==lzop set /p movehardkernel=REPLACE THE REPACKED [!img_file!] WITH ORIGINAL ONE [DEFAULT=NO 1=YES]:
	if not "!kernelunpackq!"=="y" if %ramdiskcomp% ==lzop if "%movehardkernel%"=="1" del WORK\!img_file!
	if not "!kernelunpackq!"=="y" if %ramdiskcomp% ==lzop if "%movehardkernel%"=="1" move work\image-new.img WORK\!img_file!>nul
	if not "!kernelunpackq!"=="y" if %ramdiskcomp% ==lzop if not "%movehardkernel%"=="1" echo YOUR REPACKED [!img_file!] IN [WORK\!img_dir2!]
	if not "!kernelunpackq!"=="y" if %ramdiskcomp% ==lzop if not "%movehardkernel%"=="1" (
		mkdir WORK\!img_dir2!
		move work\image-new.img WORK\!img_dir2!\!img_file!>nul
	)
	if not "!kernelunpackq!"=="y" if not %ramdiskcomp% ==lzop del WORK\!img_file!
	if not "!kernelunpackq!"=="y" if not %ramdiskcomp% ==lzop move work\image-new.img WORK\!img_file!>nul
	if "!kernelunpackq!"=="y" (
		del WORK\!img_file!
		move WORK\image-new.img WORK\!img_file! >nul
	)
	rmdir /s /q WORK\!img_dir!
	if not "!kernelunpackq!"=="y" ( goto kernel_recovery_menu ) else ( goto:eof )
:kernelpack2
	if exist "WORK\!img_dir!\ramdisk_origin" (
		rmdir /s /q WORK\!img_dir!\ramdisk
		move WORK\!img_dir!\ramdisk_origin WORK\!img_dir!\ramdisk>nul
	)
	if not "!kernelunpackq!"=="y" echo REPACKING [!img_file!] TO WORK FOLDER
	move WORK\!img_dir!\ramdisk WORK\!img_dir!\initrd>nul
	cd WORK\!img_dir!
	bootimg --repack-bootimg>nul
	cd ..\..
	if not exist "WORK\!img_dir!\boot-new.img" (
		TOOLS\bin\cecho {0c}FAILED...CAN'T REPACK THIS KERNEL{#}
		pause>nul
		goto kernel_recovery_menu
	)
	del WORK\!img_file!
	copy WORK\!img_dir!\boot-new.img WORK\!img_file!>nul
	!busybox! rm -rf WORK\!img_dir!
	if not "!kernelunpackq!"=="y" ( goto kernel_recovery_menu ) else ( goto:eof )
:kernelunpack3
	TOOLS\kernel\sfk166.exe hexfind WORK\!img_file! -pat -bin /000000000000a0e10000a0e1/ -case >TOOLS\kernel\offset.txt
	TOOLS\kernel\sfk166.exe hexfind WORK\!img_file! -pat -bin /000000001f8b08/ -case >>TOOLS\kernel\offset.txt 
	TOOLS\kernel\sfk166.exe find TOOLS\kernel\offset.txt -pat offset>TOOLS\kernel\off2.txt
	TOOLS\kernel\sfk166.exe replace TOOLS\kernel\off2.txt -binary /20/0a/ -yes>nul
	if exist WORK\!img_dir! rd /s /q WORK\!img_dir! >nul
	set /a n=0
	for /f %%g in (TOOLS\kernel\off2.txt) do (
		if !n!==1 (
			set /a ofs1=%%g
			set /a n+=1
		)
		if !n!==3 (
			set /a ofs2=%%g
			set /a n+=1
		)
		if !n!==5 (
			set /a ofs3=%%g+4
			set /a n+=1
		)
		if `%%g` equ `offset` (
			set /a n+=1
		)
	)
	for %%i in (WORK\!img_file!) do ( set /a boot_size=%%~zi )
	set /a real_ofs=!ofs2!+4
	md WORK\!img_dir!
	set /a ps=!ofs1!+4
	echo !ps!>WORK\!img_dir!\pagesize.txt
	del TOOLS\kernel\offset.txt
	del TOOLS\kernel\off2.txt
	TOOLS\kernel\sfk166.exe partcopy WORK\!img_file! -fromto !ps! !real_ofs! WORK\!img_dir!\kernel -yes>nul
	TOOLS\kernel\sfk166.exe partcopy WORK\!img_file! -fromto !real_ofs! !boot_size! WORK\!img_dir!\ram_disk.gz -yes>nul
	if errorlevel 1 (
		!busybox! rm -rf WORK\!img_dir!
		goto kernelunpack3mtk
	)
	TOOLS\bin\7za -tgzip x -y WORK\!img_dir!\ram_disk.gz -owork\!img_dir! >nul
	md WORK\!img_dir!\rmdisk
	cd WORK\!img_dir!
	cd rmdisk
	..\..\..\TOOLS\kernel\cpio.exe -i <../ram_disk>nul
	if not exist "../ram_disk" (
		cd ..\..\..
		!busybox! rm -rf WORK\!img_dir!
		goto kernelunpack3mtk
	)
	cd ..\..\..
	if not "!kernelunpackq!"=="y" if not "!img_file!"=="kernel.sin" (
		ren work\boot_unpacked\rmdisk ramdisk
		goto kernel_recovery_menu
	)
	if "!kernelunpackq!"=="y" if not "!img_file!"=="kernel.sin" (
		ren work\boot_unpacked\rmdisk ramdisk
		goto:eof
	)
:kernelpack3
	if not "!img_file!"=="kernel.sin" (
		ren work\boot_unpacked\ramdisk rmdisk
		if not "!kernelunpackq!"=="y" echo REPACKING [!img_file!] TO WORK FOLDER
	)
	copy WORK\!img_file! WORK\!img_dir!  >nul 
	del WORK\!img_dir!\pagesize.txt
	cd WORK\!img_dir!
	!busybox! chmod og=xr rmdisk
	cd rmdisk
	..\..\..\TOOLS\bin\find . | ..\..\..\TOOLS\kernel\cpio.exe -o -H newc -F ../new_ram_disk >nul
	move ..\ram_disk ..\ram_disk_old >nul
	move ..\new_ram_disk ..\ram_disk>nul
	..\..\..\TOOLS\kernel\gzip -n -f ../ram_disk
	..\..\..\TOOLS\kernel\mkbootimg --kernel ../kernel --ramdisk ../ram_disk.gz -o ../new_image.img 
	if errorlevel 1 if not "!img_file!"=="kernel.sin" (
		cd ..\..\..
		goto kernelpack3mtk
	)
	if errorlevel 1 if "!img_file!"=="kernel.sin" (
		cd ..\..\..
		!busybox! rm -rf WORK\!img_dir!
		TOOLS\bin\cecho {0c}FAILED IN CONVERTING PRESS ANY KEY TO CONTINUE{#}
		echo.
		!busybox! rm -rf WORK\!img_dir!
		ren WORK\kernel.sin kernel.sin.bak
		pause>nul
		goto:eof
	)
	copy ..\new_image.img ..\..\!img_file!  >nul 
	cd ..\..\..
	if "!img_file!"=="kernel.sin" ren WORK\kernel.sin boot.img
	rmdir /s /q WORK\!img_dir!
	if exist "WORK\boot.img" del WORK\kernel.sin
	if not "!img_file!"=="kernel.sin" if not "!kernelunpackq!"=="y" ( goto kernel_recovery_menu ) else ( goto:eof )
	if "!img_file!"=="kernel.sin" goto:eof
:kernelunpack3mtk
	TOOLS\kernel\sfk166.exe hexfind WORK\!img_file! -pat -bin /88168858/ -case >TOOLS\kernel\offset.txt
	TOOLS\kernel\sfk166.exe hexfind WORK\!img_file! -pat -bin /ffffffff1f8b08/ -case >>TOOLS\kernel\offset.txt 
	TOOLS\kernel\sfk166.exe find TOOLS\kernel\offset.txt -pat offset>TOOLS\kernel\off2.txt
	TOOLS\kernel\sfk166.exe replace TOOLS\kernel\off2.txt -binary /20/0a/ -yes>nul
	if exist WORK\!img_dir! rd /s /q WORK\!img_dir! >nul
	set /a n=0
	for /f %%g in (TOOLS\kernel\off2.txt) do (
		if !n!==1 (
			set /a ofs1=%%g
			set /a n+=1
		)
		if !n!==3 (
			set /a ofs2=%%g
			set /a n+=1
		)
		if !n!==5 (
			set /a ofs3=%%g+4
			set /a n+=1
		)
		if `%%g` equ `offset` (
			set /a n+=1
		)
	)
	for %%i in (WORK\kernel.sin) do ( set /a boot_size=%%~zi )
	del TOOLS\kernel\offset.txt
	del TOOLS\kernel\off2.txt
	md WORK\!img_dir!
	TOOLS\kernel\sfk166.exe partcopy WORK\!img_file! -fromto 0x0 !ofs1! WORK\!img_dir!\kernel_header -yes>nul
	TOOLS\kernel\sfk166.exe partcopy WORK\!img_file! -fromto !ofs1! !ofs2! WORK\!img_dir!\kernel -yes>nul
	TOOLS\kernel\sfk166.exe partcopy WORK\!img_file! -fromto !ofs2! !ofs3! WORK\!img_dir!\ram_header -yes>nul
	TOOLS\kernel\sfk166.exe partcopy WORK\!img_file! -fromto !ofs3! !boot_size! WORK\!img_dir!\ram_disk.gz -yes>nul
	if errorlevel 1 if not !kernelunpackq! ==y if "!img_file!"=="kernel.sin" (
		TOOLS\bin\cecho {0c}FAILED IN CONVERTING PRESS ANY KEY TO CONTINUE{#}
		echo.
		!busybox! rm -rf WORK\!img_dir!
		ren WORK\kernel.sin kernel.sin.bak
		pause>nul
		goto:eof
	)
	if errorlevel 1 if not !kernelunpackq! ==y if not "!img_file!"=="kernel.sin" (
		TOOLS\bin\cecho {0c}SORRY ALL METHODS FAILED CAN'T UNPACK THIS [!img_file!]{#}
		echo.
		!busybox! rm -rf WORK\!img_dir!
		pause>nul
		goto kernel_recovery_menu
	)
	if errorlevel 1 if !kernelunpackq! ==y (
		!busybox! rm -rf WORK\!img_dir!
		goto:eof
	)
	TOOLS\bin\7za -tgzip x -y WORK\!img_dir!\ram_disk.gz -owork\!img_dir! >nul
	md WORK\!img_dir!\rmdisk
	cd WORK\!img_dir!\rmdisk
	..\..\..\TOOLS\kernel\cpio.exe -i <../ram_disk
	cd ..\..\..
	if not "!kernelunpackq!"=="y" ( goto kernel_recovery_menu ) else ( goto:eof )
:kernelpack3mtk
	copy WORK\!img_file! WORK\!img_dir!>nul
	copy WORK\!img_dir!\ram_header WORK\!img_dir!\new_ram_with_header >nul
	cd WORK\!img_dir!
	!busybox! chmod og=xr rmdisk
	cd rmdisk
	..\..\..\TOOLS\bin\find . | ..\..\..\TOOLS\kernel\cpio.exe -o -H newc -F ../new_ram_disk.cpio >nul
	move ..\ram_disk ..\ram_disk_old >nul
	copy ..\new_ram_disk.cpio ..\ram_disk>nul
	..\..\..\TOOLS\kernel\gzip -n -f ../ram_disk
	..\..\..\TOOLS\kernel\dd if=../ram_disk.gz >> ../new_ram_with_header
	for %%i in (../ram_disk.gz) do ( set /a size=%%~zi )
	..\..\..\TOOLS\kernel\sfk166 hex !size! -digits=8 >../../size.txt
	for %%i in (../../size.txt) do ( set /a size=%%~zi )
	..\..\..\TOOLS\kernel\sfk166 split 1 ../../size.txt ../../1 >nul
	for /f  %%i in (../../1.part7) do (set a1=%%i)
	for /f  %%i in (../../1.part8) do (set a2=%%i)
	for /f  %%i in (../../1.part5) do (set a3=%%i)
	for /f  %%i in (../../1.part6) do (set a4=%%i)
	for /f  %%i in (../../1.part3) do (set a5=%%i)
	for /f  %%i in (../../1.part4) do (set a6=%%i)
	for /f  %%i in (../../1.part1) do (set a7=%%i)
	for /f  %%i in (../../1.part2) do (set a8=%%i)
	echo !a7%%a8!>size.txt
	echo !a5%%a6!>>size.txt
	echo !a3%%a4!>>size.txt
	echo !a1%%a2!>>size.txt
	..\..\..\TOOLS\kernel\sfk166.exe echo !a1%%a2! !a3%%a4! !a5%%a6! !a7%%a8! +hextobin ../../tmp1.dat>nul
	..\..\..\TOOLS\kernel\sfk166.exe partcopy ../../tmp1.dat 0 4 ../new_ram_with_header 4 -yes>nul
	..\..\..\TOOLS\kernel\mkbootimg.exe --kernel ../kernel --ramdisk ../new_ram_with_header -o ../new_image.img>nul 
	if errorlevel 1 if "!img_file!"=="kernel.sin" (
		cd ..\..\..
		TOOLS\bin\cecho {0c}FAILED IN CONVERTING PRESS ANY KEY TO CONTINUE{#}
		echo.
		!busybox! rm -rf WORK\!img_dir!
		ren WORK\kernel.sin kernel.sin.bak
	)
	if errorlevel 1 if not "!img_file!"=="kernel.sin" (
		cd ..\..\..
		TOOLS\bin\cecho {0c}SORRY CAN'T REPACKING THIS [!img_file!]{#}
		echo.
		!busybox! rm -rf WORK\!img_dir!
		pause>nul
		goto kernel_recovery_menu
	)
	del size.txt >nul
	copy ..\new_image.img ..\..\!img_file!>nul
	if "!img_file!"=="kernel.sin" ren WORK\kernel.sin boot.img
	move ..\ram_disk_old ..\ram_disk >nul
	cd ..\..
	del size.txt >nul
	del tmp1.dat>nul
	del 1.part*>nul
	cd ..
	rmdir /s /q WORK\!img_dir!
	if exist "WORK\boot.img" del WORK\kernel.sin
	if "!img_file!"=="kernel.sin" goto:eof
	if not "!img_file!"=="kernel.sin" if not "!kernelunpackq!"=="y" ( goto kernel_recovery_menu ) else ( goto:eof )
:enablekernelfea
	if not exist "WORK\boot_unpacked" (
		echo NO KERNEL UNPACKED FOUND UNPACK KERNEL FIRST
		pause>nul
		goto kernel_recovery_menu
	)
	if exist "WORK\boot_unpacked\ramdisk\default.prop" if !kerneladb! ==y (
		echo RESTORING OFFICIAL STATUS FOR KERNEL ADB SETTING
		!busybox! sed -i "s/ro.secure=0/ro.secure=1/" WORK/boot_unpacked/ramdisk/default.prop
		!busybox! sed -i "s/ro.debuggable=1/ro.debuggable=0/" WORK/boot_unpacked/ramdisk/default.prop
		!busybox! sed -i "s/ro.adb.secure=0/ro.adb.secure=1/" WORK/boot_unpacked/ramdisk/default.prop
		!busybox! sed -i "s/persist.sys.usb.config=mtp,adb/persist.sys.usb.config=mtp/" WORK/boot_unpacked/ramdisk/default.prop
		goto kernel_recovery_menu
	)
	set decideadb=null
	ECHO THIS WILL MAKE ANDROID DEPUGGING DEFAULT ENABLED
	set /p decideadb=DO YOU WANT TO ADD IT OR NOT [DEFAULT=YES 0=BACK]:
	if "!decideadb!"=="0" goto kernel_recovery_menu
	set decideadb=null
	echo ENABLING ADB INSCURE IN KERNEL
	!busybox! sed -i "s/persist.sys.usb.config=none/persist.sys.usb.config=mtp,adb/" WORK/boot_unpacked/ramdisk/default.prop
	!busybox! sed -i "s/ro.secure=1/ro.secure=0/" WORK/boot_unpacked/ramdisk/default.prop
	!busybox! sed -i "s/ro.debuggable=0/ro.debuggable=1/" WORK/boot_unpacked/ramdisk/default.prop
	!busybox! sed -i "s/ro.adb.secure=1/ro.adb.secure=0/" WORK/boot_unpacked/ramdisk/default.prop
	!busybox! sed -i "s/persist.sys.usb.config=mtp,adb/persist.sys.usb.config=mtp/" WORK/boot_unpacked/ramdisk/default.prop
	!busybox! sed -i "s/persist.sys.usb.config=mtp/persist.sys.usb.config=mtp,adb/" WORK/boot_unpacked/ramdisk/default.prop
	goto kernel_recovery_menu
:sqlite
	if exist "WORK\system\xbin\sqlite*" (
		if exist "WORK\system\etc\init.d\*sqlite*" (
			echo REMOVING SQLITE SCRIPT
			for %%f in (WORK\system\etc\init.d\*sqlite*) do del %%f
			del WORK\system\xbin\sqlite3
			goto completed
		)
	)
	if exist "WORK\system\xbin\sqlite*" (
		echo REMOVING SQLITE SCRIPT
		del WORK\system\xbin\sqlite*
		goto completed
	)
	if not exist "WORK\system\build.prop" (
		echo NO ROM FOUND TO ADD SQLITE
		pause>nul
		goto start
	)
	set decidesqlite=null
	echo THIS SCRIPT NECCESARY TO RUN SOME APPS LIKE [Titanuim Backup]
	set /p decidesqlite=DO YOU WANT TO ADD IT OR NOT [DEFAULT=YES 0=BACK]:
	if "!decidesqlite!"=="0" goto start
	set decidesqlite=null
	if not exist "WORK\system\xbin" mkdir WORK\system\xbin
	echo INSTALLING SQLITE SCRIPT
	copy "TOOLS\xbin\sqlite3" "WORK\system\xbin\sqlite3">nul
	if exist "WORK\system\etc\init.d" copy "TOOLS\xbin\85sqlite" "WORK\system\etc\init.d\85sqlite">nul
	goto completed
:sysrorw
	set needsedrorw=null
	if exist "WORK\system\xbin\sysro" if exist "WORK\system\xbin\sysrw" (
		echo REMOVING SYSRO-SYSRW
		del WORK\system\xbin\sysro
		del WORK\system\xbin\sysrw
		goto completed
	)
	if not exist "WORK\system\build.prop" (
		echo NO ROM FOUND TO ADD SYSRO-SYSRW
		pause>nul
		goto start
	)
	if not exist "WORK\system\xbin" mkdir WORK\system\xbin
	set sysrorw=sysy
	set /p sysrorw=THIS SCRIPTS TO IMPROVE ADB CONNECT [DEFAULT=YES 0=NO]:
	if "!sysrorw!"=="0" goto start
	if not exist "WORK\system\xbin\busybox" set needsedrorw=y
	echo INSTALLING SYSRO-SYSRW SCRIPTS
	copy "TOOLS\xbin\sysro" "WORK\system\xbin\sysro">nul
	copy "TOOLS\xbin\sysrw" "WORK\system\xbin\sysrw">nul
	if not exist "WORK\system\xbin\busybox" (
		set busyboxq=y
		call :busybox
	)
	goto completed
:wipedata
	set needsedwipe=null
	if exist "WORK\META-INF" if not exist "WORK\META-INF\SCRIPTS" if not exist "WORK\META-INF\ADD-ONS" (
		echo THIS FEATURE FOR INSTALLER MADE BY THIS KITCHEN ONLY
		pause>nul
		goto start
	)
	if exist !aroma_config! (
		ECHO AROMA INSTALLER ALREADY HAS THIS FEATURE AND NO NEED TO REMOVE IT
		ECHO YOU CAN SELECT WIPE YOUR DATA OR NOT DURING THE INSTALL
		pause>nul
		goto start
	)
	if exist "WORK\META-INF\SCRIPTS\wipe.sh" (
		echo REMOVING WIPE DATA FROM INSTALLER
		del WORK\META-INF\SCRIPTS\wipe.sh
		del WORK\META-INF\SCRIPTS\bash
		set needsedwipe=y
	)
	if !needsedwipe! ==y (
		!busybox! sed -i '/^ui_print("-- Wiping all user data files"/d' !updater_script!
		!busybox! sed -i '/^set_metadata("\/tmp\/wipe.sh", "uid", 0, "gid", 0, "mode", 0777/d' !updater_script!
		!busybox! sed -i '/^set_perm(0, 0, 0777, "\/tmp\/bash"/d' !updater_script!
		!busybox! sed -i '/^run_program("\/tmp\/wipe.sh"/d' !updater_script!
		goto completed
	)
	if not exist "WORK\META-INF" (
		echo NO STANDALONE INSTALLER FOUND BUILD IT FIRST
		pause>nul
		goto start
	)
	set wipedata=wipe
	ECHO THIS FEATURE TO WIPE DEVICE DATA WITHOUT INTERNAL STORAGE
	ECHO BEFORE INSTALLING THE ROM
	set /p wipedata=CONTINUE OR NOT [DEFAULT=YES 0=NO]:
	if "!wipedata!"=="0" goto start
	echo INSTALLING WIPE DATA FEATURE
	copy TOOLS\installer\aroma\META-INF\SCRIPTS\wipe.sh WORK\META-INF\SCRIPTS\wipe.sh>nul
	for /f "delims=" %%a in ('!busybox! grep -cw "#--INSTALLATION" !updater_script!') do if "%%a"=="0" !busybox! sed -i -e 's/package_extract_dir("system", "/system");/#--INSTALLATION\npackage_extract_dir("system", "/system");/' !updater_script!
	!busybox! sed -i -e 's/#--INSTALLATION/ui_print("-- Wiping all user data files");\nset_metadata("\/tmp\/wipe.sh", "uid", 0, "gid", 0, "mode", 0777);\nrun_program("\/tmp\/wipe.sh");\n#--INSTALLATION/' !updater_script!
	goto completed
:editproject
	rmdir WORK
	if not exist "WORK" (
		mkdir WORK
		echo NO PROJECT FOUND TO EDIT IT
		pause>nul
		goto start
	)
	for /f "delims=" %%a in ('!busybox! date '+%%y%%m%%d_%%H%%M%%S'') do set saveprojectname=PROJECT_%%a
	set editproject=edit
	if !rmproject!==y set /p editproject=WHAT YOU WANT TO DO IN THIS PROJECT [1=SAVE 2=REMOVE DEFAULT=BACK]:
	if not !rmproject!==y set /p editproject=WHAT YOU WANT TO DO [1=SAVE 2=REMOVE 3=SAVE_AND_REMOVE DEFAULT=BACK]:
	if !editproject! ==1 set /p saveprojectname=TYPE NAME TO SAVE PROJECT [DEFAULT=!saveprojectname!]:
	if not !rmproject!==y if "!editproject!"=="3" set /p saveprojectname=TYPE NAME TO SAVE PROJECT [DEFAULT=!saveprojectname!]:
	if !editproject! ==1 set saveprojectname2=!saveprojectname: =_!
	if !editproject! ==1 if not "!saveprojectname2!" =="!saveprojectname!" echo RENAMING [!saveprojectname!] TO [!saveprojectname2!]
	if not !rmproject!==y if "!editproject!"=="3" set saveprojectname2=!saveprojectname: =_!
	if not !rmproject!==y if "!editproject!"=="3" if not "!saveprojectname2!" =="!saveprojectname!" echo RENAMING [!saveprojectname!] TO [!saveprojectname2!]
	if !editproject! ==1 if exist "TOOLS\projects\!saveprojectname2!" (
		echo THE [!saveprojectname2!] ALREADY EXIST..PLEASE CHOOSE OTHER NAME
		pause>nul
		cls
		echo.
		echo.
		goto editproject
	)
	if not !rmproject!==y if "!editproject!"=="1" if not exist "TOOLS\projects\!saveprojectname2!" (
		echo SAVING [!saveprojectname2!] IN [TOOLS\projects]
		move WORK TOOLS\projects\!saveprojectname2!>nul
		mkdir WORK
		xcopy TOOLS\projects\!saveprojectname2! WORK /e /i /h /y>nul
		move TOOLS\tmp TOOLS\projects\!saveprojectname2!\tmp>nul
		mkdir TOOLS\tmp
		goto completed
	)
	if !rmproject!==y if "!editproject!"=="1" if not exist "TOOLS\projects\!saveprojectname2!" (
		echo SAVING [!saveprojectname2!] IN [TOOLS\projects]
		move WORK TOOLS\projects\!saveprojectname2!>nul
		move TOOLS\tmp TOOLS\projects\!saveprojectname2!\tmp>nul
		mkdir TOOLS\tmp
		mkdir WORK
		goto:eof
	)
	if not !rmproject!==y if "!editproject!"=="3" if exist "TOOLS\projects\!saveprojectname2!" (
		echo THE [!saveprojectname2!] ALREADY EXIST..PLEASE CHOOSE OTHER NAME
		pause>nul
		cls
		echo.
		echo.
		goto editproject
	)
	if not !rmproject!==y if "!editproject!"=="3" if not exist "TOOLS\projects\!saveprojectname2!" (
		echo MOVING [!saveprojectname2!] TO [TOOLS\projects]
		move WORK TOOLS\projects\!saveprojectname2!>nul
		move TOOLS\tmp TOOLS\projects\!saveprojectname2!\tmp>nul
		mkdir TOOLS\tmp
		mkdir WORK
		goto completed
	)
	if "!editproject!"=="2" echo REMOVING PROJECT
	if !rmproject!==y if "!editproject!"=="2" (
		!busybox! rm -rf WORK TOOLS/tmp
		mkdir WORK TOOLS\tmp
		goto:eof
	)
	if not !rmproject!==y if "!editproject!"=="2" (
		!busybox! rm -rf WORK TOOLS/tmp
		mkdir WORK TOOLS\tmp
		goto completed
	)
	set editproject=edit
	goto start
:openwork
	%systemroot%\explorer.exe "WORK"
	goto start
:kernelinitd
	set decidekernelinitd=null
	if not exist "WORK\boot_unpacked" (
		echo NO KERNEL UNPACKED FOUND PLEASE UNPACK THE KERNEL FIRST
		pause>nul
		goto kernel_recovery_menu
	)
	if !kernelinitd! ==null (
		if not exist "WORK\boot_unpacked\ramdisk\init.rc" (
			echo NO [init.rc] FOUND THIS IS A PROBLEM CAN'T CONTINUE
			pause>nul
			goto kernel_recovery_menu
		)
		set decidekernelinitd=null
		echo THIS WILL ENABLE RUN SCRIPTS IN [system\etc\init.d]
		ECHO BY KERNEL IN EVERY BOOT AND THIS ALLOWED TO ADD
		echo SCRIPTS IN THIS FOLDER LIKE TWEAKS
		set /p decidekernelinitd=DO YOU WANT TO ADD IT OR NOT [DEFAULT=YES 0=BACK]:
		if "!decidekernelinitd!"=="0" goto kernel_recovery_menu
		echo ADDING INIT.D SUPPORT
		mkdir WORK\system\etc\init.d
		!busybox! touch WORK/system/etc/init.d/placeholder>nul
		copy WORK\boot_unpacked\ramdisk\init.rc TOOLS\tmp\stock_init.rc>nul
		copy TOOLS\init.d\kernel-init.sh WORK\boot_unpacked\ramdisk\sbin\kernel-init.sh >nul
		echo. >>WORK\boot_unpacked\ramdisk\init.rc
		echo # start init.d support>>WORK\boot_unpacked\ramdisk\init.rc
		echo service kernel-init /sbin/kernel-init.sh>>WORK\boot_unpacked\ramdisk\init.rc
		echo 	class main>>WORK\boot_unpacked\ramdisk\init.rc
		echo 	user root>>WORK\boot_unpacked\ramdisk\init.rc
		echo 	oneshot>>WORK\boot_unpacked\ramdisk\init.rc
		goto kernel_recovery_menu
	)
	if !kernelinitd! ==y if exist "TOOLS\tmp\stock_init.rc" (
		echo REMOVING INIT.D SUPPORT
		del WORK\boot_unpacked\ramdisk\sbin\kernel-init.sh WORK\boot_unpacked\ramdisk\init.rc WORK\system\etc\init.d\placeholder
		move TOOLS\tmp\stock_init.rc WORK\boot_unpacked\ramdisk\init.rc>nul
		goto kernel_recovery_menu
	)
	echo WE CAN'T DISABLE PREVIOUS INIT.D SUPPORT AUTOMATICALLY
	set manully=man
	set /p manully=DO YOU WANT TO D OTHAT MANUALLY [ENTER=YES 0=BACK]:
	if "!manully!"=="0" goto kernel_recovery_menu
	set manully=man
	if exist "WORK\boot_unpacked\ramdisk\init.rc" start TOOLS\notepad_pp\notepad++ WORK\boot_unpacked\ramdisk\init.rc>nul
	ECHO IN [Notepad++] WINDOW PRESS CTRL+F TO OPEN 
	ECHO SEARCH WINDOW AND TYPE IN SEARCH BOX [kernel-init.sh]
	ECHO THEN PRESS [Find next] YOU WILL SEE A LINE CONTENT
	ECHO [kernel-init.sh] DELETE IT WITH THE THREE LINES
	echo UNDER IT THEN IN [Notepad++] WINDOW PRESS CTRL+S TO SAVE
	pause>nul
	ECHO AFTER FINISH CLOSE [Notepad++] AND PRESS ENTER
	pause>nul
	del WORK\boot_unpacked\ramdisk\sbin\kernel_init.sh
	echo CHECKING THE [init.rc]
	set kernelinitd=n
	for /f "delims=" %%a in ('!busybox! grep -cw "kernel-init.sh" "WORK/boot_unpacked/ramdisk/init.rc"') do set kernelinitd=%%a
	if "!kernelinitd!"=="0" (
		echo OK! INIT.D REMOVED SUCCESSFULLY
		del WORK\system\etc\init.d\placeholder WORK\boot_unpacked\ramdisk\sbin\kernel-init.sh
	) else (
		echo AN ERROR HAPPENED THE KERNEL STILLS HAVE INIT SUPPORT
		pause>nul
		goto kernel_recovery_menu
	)
	goto kernel_recovery_menu
:ext4-tune2fs
	set needsedext=null
	if not exist "WORK\META-INF" (
		echo NO INSTALLER FOUND BUILD IT FIRST
		pause>nul
		goto start
	)
	if exist "WORK\META-INF" if not exist "WORK\META-INF\ADD-ONS" if not exist "WORK\META-INF\SCRIPTS" (
		echo THIS FEATURE FOR INSTALLER MADE BY THIS KITCHEN ONLY
		pause>nul
		goto start
	)
	if exist "WORK\META-INF\SCRIPTS\tune2fs" (
		set needsedext=y
		echo REMOVING EXT4-TUNE2FS SCRIPTS
		del WORK\META-INF\SCRIPTS\ext4*
		del WORK\META-INF\SCRIPTS\tune2fs
	)
	if %needsedext% ==y (
		!busybox! sed -i '/^ui_print("-- Running rom configuration"/d' !updater_script!
		!busybox! sed -i '/^set_metadata("\/tmp\/tune2fs", "uid", 0, "gid", 0, "mode", 0777/d' !updater_script!
		!busybox! sed -i '/^set_metadata("\/tmp\/ext4.sh", "uid", 0, "gid", 0, "mode", 0777/d' !updater_script!
		!busybox! sed -i '/^set_perm(0, 0, 0777, "\/tmp\/tune2fs"/d' !updater_script!
		!busybox! sed -i '/^run_program("\/tmp\/ext4"/d' !updater_script!
		!busybox! sed -i '/^delete("\/tmp\/ext4"/d' !updater_script!
		!busybox! sed -i '/^run_program("\/tmp\/ext4.sh"/d' !updater_script!
		!busybox! sed -i '/^delete("\/tmp\/ext4.sh"/d' !updater_script!
		!busybox! sed -i '/^delete("\/tmp\/tune2fs"/d' !updater_script!
		goto completed
	)
	for /f "delims=" %%a in ('!busybox! grep -c "#--CUSTOM SCRIPTS" !updater_script!') do if "%%a"=="0" !busybox! sed -i -e 's/#--FINISH/#--CUSTOM SCRIPTS\n#--FINISH/' !updater_script!
	ECHO THESE SCRIPTS TO TUNING FILESYSTEMS INTO EXT4 FORMAT
	ECHO FOR SYSTEM,DATA,CACHE PARTITIONS
	set ext4=ext
	set /p ext4=DO YOU WANT TO ADD IT OR NOT [DEFAULT=YES 0=NO]:
	if "!ext4!"=="0" goto start
	echo ADDING EXT4-TUNE2FS SCRIPTS
	copy TOOLS\installer\ext4.sh WORK\META-INF\SCRIPTS\ext4.sh>nul
	copy TOOLS\installer\tune2fs WORK\META-INF\SCRIPTS\tune2fs>nul
	!busybox! sed -i -e 's/#--CUSTOM SCRIPTS/#--CUSTOM SCRIPTS\nui_print("-- Running rom configuration");\nset_metadata("\/tmp\/tune2fs", "uid", 0, "gid", 0, "mode", 0777);\nset_metadata("\/tmp\/ext4.sh", "uid", 0, "gid", 0, "mode", 0777);\nrun_program("\/tmp\/ext4.sh");/' !updater_script!
	goto completed
:custom_animation
	if not exist "WORK\system\build.prop" (
		echo THERE IS NO ROM TO ADD CUSTOM BOOTANIMATION
		pause>nul
		goto start
	)
	if exist "WORK\system\media\bootanimation*.zip" if not exist "WORK\system\bin\bootanimation.bak" (
		echo THIS ROM ALREADY SUPPORTS CUSTOM BOOTANIMATION
		echo YOU CAN ADD YOUR ANIMATION IN [WORK/system/media/bootanimation.zip]
		pause>nul
		goto start
	)
	if exist "WORK\system\bin\bootanimation.bak" (
		set sure=n
		echo WILL REMOVE THE CUSTOM BOOTANIMATION AND RE-BACK TO STOCK ONE
		echo AND WILL REMOVE [WORK\system\media\bootanimation*.zip] IF EXISTS
		set /p sure=CONTINUE OR NOT [DEFAULT=YES 0=BACK]:
		if "!sure!"=="0" goto start
		echo RESTORING ORIGINAL BOOTANIMATION
		del WORK\system\bin\bootanimation
		ren WORK\system\bin\bootanimation.bak bootanimation
		del WORK\system\media\bootanimation*.zip
		goto completed
	)
	if not exist "WORK\system\bin\bootanimation.bak" (
		set sure=n
		echo WILL ADD SCRIPT TO RUN CUSTOM ANIMATION DURING BOOT
		echo YOU CAN ADD IT IN [WORK\system\media\bootanimation.zip]
		set /p sure=CONTINUE OR NOT [DEFAULT=YES 0=BACK]:
		if "!sure!"=="0" goto start
		echo ENABLING CUSTOM BOOTANIMATION
		ren WORK\system\bin\bootanimation bootanimation.bak
		copy TOOLS\xbin\bootanimation_kk WORK\system\bin\bootanimation >nul
		if !api! geq 20 (
			del WORK\system\bin\bootanimation
			copy TOOLS\xbin\bootanimation_ll WORK\system\bin\bootanimation >nul
		)
		if !api! geq 23 (
			del WORK\system\bin\bootanimation
			copy TOOLS\xbin\bootanimation_mm WORK\system\bin\bootanimation >nul
		)
		if !api! geq 24 (
			del WORK\system\bin\bootanimation
			copy TOOLS\xbin\bootanimation_n WORK\system\bin\bootanimation >nul
		)
		goto completed
	)
:efsinstaller
	SET needsedefs=n/a
	if not exist "WORK\META-INF" (
		echo NO INSTALLER FOUND BUILD IT FIRST
		pause>nul
		goto start
	)
	if exist "WORK\META-INF" if not exist "WORK\META-INF\ADD-ONS" if not exist "WORK\META-INF\SCRIPTS" (
		echo THIS FEATURE FOR INSTALLER MADE BY THIS KITCHEN ONLY
		pause>nul
		goto start
	)
	if not "!factory!"=="samsung" (
		echo THIS FEATURE FOR SAMSUNG DEVICES ONLY 
		echo [!factory!] DEVICES DON'T NEED FOR THIS
		pause>nul
		goto start
	)
	if exist !aroma_config! (
		ECHO AROMA INSTALLER ALREADY HAS THIS FEATURE AND NO NEED FOR THAT
		ECHO YOU CAN SELECT BACKUP EFS OR NOT DURING THE INSTALL
		pause>nul
		goto start
	)
	IF exist "work\meta-inf\SCRIPTS\efs_backup.sh" (
		set needsedefs=y
		ECHO REMOVING EFS BACKUP FROM INSTALLER
		DEL work\meta-inf\SCRIPTS\efs_backup.sh
	)
	if "!needsedefs!"=="y" (
		!busybox! sed -i '/^ui_print("-- Backing up efs partition"/d' !updater_script!
		!busybox! sed -i '/^ui_print("-- backing up efs partition"/d' !updater_script!
		!busybox! sed -i '/^set_metadata("\/tmp\/efs_backup.sh", "uid", 0, "gid", 0, "mode", 0777/d' !updater_script!
		!busybox! sed -i '/^run_program("\/tmp\/efs_backup.sh"/d' !updater_script!
		goto completed
	)
	ECHO THIS SCRIPT TO BACKEUP EFS PARTITION
	ECHO TO RESTORE NETWORK IF IT LOST!
	set efsbackeup=efs
	set /p efsbackeup=DO YOU WANT TO ADD IT OR NOT [DEFAULT=YES 0=NO]:
	IF "!efsbackeup!"=="0" goto start
	ECHO ADDING EFS BACKEUP SCRIPT
	copy TOOLS\installer\aroma\META-INF\SCRIPTS\efs_backup.sh work\meta-inf\SCRIPTS\efs_backup.sh>nul
	for /f "delims=" %%a in ('!busybox! grep -cw "#--INSTALLATION" !updater_script!') do if "%%a"=="0" !busybox! sed -i -e 's/package_extract_dir("system", "/system");/#--INSTALLATION\npackage_extract_dir("system", "/system");/' !updater_script!
	!busybox! sed -i -e 's/#--INSTALLATION/ui_print("-- Backing up efs partition");\nset_metadata("\/tmp\/efs_backup.sh", "uid", 0, "gid", 0, "mode", 0777);\nrun_program("\/tmp\/efs_backup.sh");\n#--INSTALLATION/' !updater_script!
	goto completed
:initdmenu
	if not exist "WORK\system" (
		echo NO ROM FOUND TO ADD INIT.D TWEAKS
		pause>nul
		goto start
	)
	rmdir WORK\system\etc\init.d>nul
	if not exist "WORK\system\etc\init.d" (
		echo NO INIT.D SUPPORT IN THE ROM ADD IT FIRST
		pause>nul
		goto start
	)
	cls
	echo.
	echo NOTE: YOU CAN ADD YOUR CUSTOM INIT TWEAKS IN [TOOLS\tweaks]
	echo.
	echo --------------------------------------------------------------
	set count=0
	for %%f in (TOOLS\tweaks\*) do if not "%%~nf%%~xf"=="prop_tweaks" if not "%%~nf%%~xf"=="prop_tweaks_rm" (
		set /a count=!count!+1
		if !count! leq 9 if not exist "WORK\system\etc\init.d\%%~nf%%~xf" ( echo    !count! == ADD [%%~nf%%~xf] ) else ( echo    !count! == REMOVE [%%~nf%%~xf] )
		if !count! geq 10 if not exist "WORK\system\etc\init.d\%%~nf%%~xf" ( echo   !count! == ADD [%%~nf%%~xf] ) else ( echo   !count! == REMOVE [%%~nf%%~xf] )
		if !count! geq 100 if not exist "WORK\system\etc\init.d\%%~nf%%~xf" ( echo  !count! == ADD [%%~nf%%~xf] ) else ( echo  !count! == REMOVE [%%~nf%%~xf] )
	)
	echo --------------------------------------------------------------
	echo.
	SET filenumber=rr
	set file=n
	set /p filenumber=SELECT FILE TO ADD [DEFAULT=REFRESH 0=BACK]:
	set filenumber=%filenumber: =x%
	set filenumber=%filenumber:,=x%
	set filenumber=%filenumber:"=x%
	if "!filenumber!"=="0" goto start
	IF "!filenumber!"=="rr" goto initdmenu
	set count=0
	for %%f in (TOOLS\tweaks\*) do if not "%%~nf%%~xf"=="prop_tweaks" if not "%%~nf%%~xf"=="prop_tweaks_rm" (
		set /a count=!count!+1
		if !count! ==%filenumber% (
			SET FILE=%%f
			set basename=%%~nf%%~xf
		)
	)
	echo !file!
	echo !basename!
	if "!file!"=="n" ( goto initdmenu ) else (
		if exist "WORK\system\etc\init.d\!basename!" (
			del WORK\system\etc\init.d\!basename!
			goto initdmenu
		) else (
			copy TOOLS\tweaks\!basename! WORK\system\etc\init.d\!basename! >nul
			goto initdmenu
		)
	)
:removecleaned
	!busybox! rm -rf WORK\bloat WORK\knox
	goto start
:worksavedprojects
	rmdir TOOLS\projects
	if not exist "TOOLS\projects" (
		mkdir TOOLS\projects
		echo NO PROJECTS SAVED FOUND
		pause>nul
		goto start
	)
	set count=0
	for /f %%s in ('dir TOOLS\projects\ /ad /b' ) do set /a count+=1
	if !count! ==0 (
		echo NO PROJECTS SAVED FOUND
		pause>nul
		goto start
	)
	cls
	set count=0
	echo.
	echo.
	echo ===========================================
	for /f %%s in ('dir TOOLS\projects\ /ad /b' ) do (
		set /a count=!count!+1
		if !count! leq 9 echo   !count! == %%s
		if !count! geq 10 echo  !count! == %%s
	)
	echo ===========================================
	echo.
	set selectproject=sele
	set projectselected=null
	set /p selectproject=SELECT WHAT YOU WANT TO REMOVE OR RESTORE [ENTER=REFRESH 0=BACK 00=REMOVE ALL]:
	if "!selectproject!"=="0" goto start
	if "!selectproject!"=="00" (
		echo REMOVING ALL PROJECTS
		rmdir /s /q TOOLS\projects
		goto completed
	)
	set selectproject=!selectproject:"=!
	set count=0
	for /f %%s in ('dir TOOLS\projects\ /ad /b' ) do (
		set /a count=!count!+1
		if !count! ==!selectproject! set projectselected=%%s
	)
	set selectproject=sele
	if !projectselected! ==null goto worksavedprojects
	echo YOU HAVE SELECTED [!projectselected!]
	set decidedoproject=removeorrestore
	set /p decidedoproject=WHAT YOU WANT TO DO WITH IT [DEFAULT=RESTORE 1=RESTORE_AND_REMOVE 0=REMOVE]:
	if "!decidedoproject!"=="0" (
		echo REMOVING [!projectselected!]
		!busybox! rm -rf TOOLS\projects\!projectselected!
		rmdir TOOLS\projects
		if not exist "TOOLS\projects" (
			mkdir TOOLS\projects
			goto completed
		)
		goto worksavedprojects
	)
	rmdir WORK
	if not exist "WORK" if "!decidedoproject!"=="1" (
		echo MOVING [!projectselected!]
		rmdir /s /q TOOLS\tmp
		move TOOLS\projects\!projectselected!\tmp TOOLS\tmp>nul
		move TOOLS\projects\!projectselected! WORK>nul
		goto completed
	)
	if not exist "WORK" (
		echo RESTORING [!projectselected!]
		rmdir /s /q TOOLS\tmp
		mkdir TOOLS\tmp
		xcopy TOOLS\projects\!projectselected!\tmp TOOLS\tmp /e /i /h /y>nul
		xcopy TOOLS\projects\!projectselected! WORK /e /i /h /y>nul
		goto completed
	)
	echo WORK FOLDER CONTENTS OTHER PROJECT
	set saveprojectname=
	set editproject=edit
	set /p editproject=WHAT YOU WANT TO DO IN THE CURRENT PROJECT [1=SAVE 2=REMOVE DEFAULT=BACK]:
	for /f "delims=" %%a in ('!busybox! date '+%%y%%m%%d_%%H%%M%%S'') do set saveprojectname=PROJECT_%%a
	if !editproject! ==1 set /p saveprojectname=TYPE THE NAME TO SAVE PROJECT [DEFAULT=!saveprojectname!]:
	set saveprojectname2=%saveprojectname: =_%
	if not "!saveprojectname2!" =="!saveprojectname!" echo RENAMING [!saveprojectname!] TO [!saveprojectname2!]
	if !editproject! ==2 rmdir /s /q TOOLS\tmp
	if !editproject! ==1 if exist "TOOLS\projects\!saveprojectname2!" (
		echo THE [!saveprojectname2!] ALREADY EXIST PLEASE CHOOSE ANOTHE NAME
		pause>nul
		goto worksavedprojects
	)
	if !editproject! ==1 if not exist "TOOLS\projects\!saveprojectname2!" (
		echo SAVING [!saveprojectname2!] IN [TOOLS\projects]
		move WORK TOOLS\projects\!saveprojectname2!>nul
		move TOOLS\tmp TOOLS\projects\!saveprojectname2!\tmp>nul
		echo RESTORING [!projectselected!]
		move TOOLS\projects\!projectselected!\tmp TOOLS\tmp>nul
		move TOOLS\projects\!projectselected! WORK>nul
		goto completed
	)
	if !editproject! ==2 (
		echo REMOVING PROJECT
		rmdir /s /q WORK
		if !decidedoproject! ==1 (
			echo MOVING [!projectselected!]
			rmdir /s /q TOOLS\tmp
			move TOOLS\projects\!projectselected!\tmp TOOLS\tmp>nul
			move TOOLS\projects\!projectselected! WORK>nul
			goto completed
		)
		echo RESTORING [!projectselected!]
		rmdir /s /q TOOLS\tmp
		mkdir TOOLS\tmp
		xcopy TOOLS\projects\!projectselected!\tmp TOOLS\tmp /e /i /h /y>nul
		xcopy TOOLS\projects\!projectselected! WORK /e /i /h /y>nul
		goto completed
	)
	set editproject=edit
	goto worksavedprojects
:change_prop_info
	if not exist "WORK\system\build.prop" (
		echo NO [build.prop] FOUND TO EDIT IT
		pause>nul
		goto start
	)
	for /f "delims=" %%a in ('!busybox! grep -i "ro.build.display.id=" WORK/system/build.prop ^| !busybox! cut -d"=" -f2') do set short_build_number=%%a
	if exist "TOOLS\tmp\changed_build_number" (
		echo RESTORING ORIGINAL BUILD NUMBER STRING
		set /p original_build_number=<TOOLS\tmp\changed_build_number
		set for_sed1=!short_build_number:"=\"!
		set for_sed2=!original_build_number:"=\"!
		!busybox! sed -i -e 's/!for_sed1!/!for_sed2!/' "WORK/system/build.prop"
		del TOOLS\tmp\changed_build_number
		goto completed
	)
	cls
	echo.
	echo.
	ECHO THE BUILD NUMBER YOU WIIL CHANGE IT IS
	ECHO THAT THE STRING YOU SEE IT IN ABOUT DEVICE OF YOUR DEVICE SETTING
	ECHO YOU CAN WRITE ANY THING YOU WANT LIKE YOUR NAME...ETC
	echo THE CURRENTLY STRING IS: [!short_build_number!]
	set change_build_number=n
	set /p change_build_number=DO YOU WANT TO CONTINUE OR NOT [DEFAULT=YES 0=NO]:
	if "!change_build_number!"=="0" goto start
	set new_build_number=!short_build_number!
	set /p new_build_number=WRITE THE NEW STRING [LEAVE IT EMPTY TO STAY SAME STRING]:
	if not "!new_build_number!"=="!short_build_number!" echo !short_build_number!>>TOOLS\tmp\changed_build_number
	set for_sed1=!short_build_number:"=\"!
	set for_sed2=!new_build_number:"=\"!
	!busybox! sed -i -e 's/ro.build.display.id=!for_sed1!/ro.build.display.id=!for_sed2!/' "WORK/system/build.prop"
	goto completed
:build.prop
	if not exist "WORK\system\build.prop" (
		echo NO [build.prop] FOUND TO OPEN
		pause>nul
		goto start
	)
	if exist "WORK\system\build.prop" start TOOLS\notepad_pp\notepad++ WORK\system\build.prop>nul
	goto start
:openupdater
	if not exist !updater_script! (
		echo NO [updater-script] FOUND TO OPEN
		pause>nul
		goto start
	)
	if exist !updater_script! start TOOLS\notepad_pp\notepad++ !updater_script!
	goto start
:openaroma
	if not exist !aroma_config! (
		echo NO [aroma-config] FOUND TO OPEN
		pause>nul
		goto start
	)
	if exist !aroma_config! start TOOLS\notepad_pp\notepad++ !aroma_config!
	goto start
:pushfiles
	rmdir READY
	if not exist "READY" (
		mkdir READY
		echo READY FOLDER IS EMPTY
		pause>nul
		goto start
	)
	cls
	echo.
	TOOLS\bin\cecho {0c}BE SURE FROM INSTALLING YOUR DEVICE DRIVERS IN PC SYSTEM THEN CONTINUE{#}
	echo.
	echo.
	echo --------------------------------------------------------------
	set count=0
	for %%f in (READY/*) do (
		set /a count=!count!+1
		if !count! leq 9 echo   !count! == %%f
		if !count! geq 10 echo  !count! == %%f
	)
	echo --------------------------------------------------------------
	echo.
	set filenumber=rr
	set /p filenumber=SELECT FILE TO PUSH [ENTER=REFRESH 0=BACK]:
	set filenumber=%filenumber: =x%
	if "!filenumber!"=="0" goto start
	if "!filenumber!"=="rr" goto pushfiles
	set count=0
	set file=n
	for %%f in (READY/*) do (
		set /a count=!count!+1
		if !count! ==%filenumber% (
			set file=%%f
			set kind=%%~xf
		)
	)
	if !file! ==n goto pushfiles
	set pushplace=sdcard
	ECHO NOTE: BE SURE FROM YOUR EXTERNAL SDCARD IN YOUR PHONE 
	ECHO IF YOU WANT TO PUSH FILES TO IT.
	set /p pushplace=WHERE YOU WANT TO PUSH THE FILE [DEFAULT=SDCARD 1=EXTERNAL_SDCARD 0=BACK]:
	if "!pushplace!"=="0" goto pushfiles
	echo DETECTING DEVICE RESPONSE
	call :device_response
	if "!error!"=="yes" goto pushfiles
	if not "!pushplace!"=="sdcard" echo PUSHING [%file%] TO EXTERNAL SDCARD
	if not "!pushplace!"=="sdcard" TOOLS\bin\adb push READY/"!file!" /storage/extSdCard/"!file!"
	if not "!pushplace!"=="sdcard" if errorlevel 1 TOOLS\bin\adb push READY/"!file!" /storage/8993-131FC/"!file!"
	if not "!pushplace!"=="sdcard" if errorlevel 1 (
		TOOLS\bin\cecho {0c}FAILED TO PUSH FILE TO EXTERNAL SDCARD{#}
		echo.
		echo TRYING TO PUSH TO SDCARD
		set pushplace=sdcard
	)
	if "!pushplace!"=="sdcard" echo PUSHING [!file!] TO SDCARD
	if "!pushplace!"=="sdcard" TOOLS\bin\adb push READY/"%file%" /sdcard/"%file%"
	if "!pushplace!"=="sdcard" if errorlevel 1 (
		TOOLS\bin\cecho {0c}FAILED PUSH THE FILE TO YOUR PHONE{#}
		echo.
		pause>nul
		goto start
	)
	goto completed
:grepboot
	for /f "delims=" %%a in ('TOOLS\bin\find WORK TOOLS/tmp/original_installer ^| !busybox! grep -v 'WORK/system/' ^| !busybox! grep -c \.img$') do if "%%a"=="0" (
		echo ERROR: NO KERNEL DETECTED IN THIS ROM
		if "!search_q!"=="y" ( goto:eof ) else (
			pause>nul
			goto start
		)
	)
	cls
	echo.
	echo.
	echo --------------------------------------------------------------
	set count=0
	for /f "delims=" %%a in ('TOOLS\bin\find WORK TOOLS/tmp/original_installer ^| !busybox! grep -v 'WORK/system/' ^| !busybox! grep \.img$') do (
		set /a count=!count!+1
		if !count! leq 9 echo   !count! == %%a
		if !count! geq 10 echo  !count! == %%a
	)
	echo --------------------------------------------------------------
	echo.
	set filenumber=rr
	set /p filenumber=SELECT IMG YOU THINK IT IS A KERNEL [0=BACK]:
	set filenumber=%filenumber: =x%
	set filenumber=%filenumber:"=x%
	if "!filenumber!"=="0" if "!search_q!"=="y" ( goto:eof ) else ( goto start )
	if "!filenumber!"=="rr" goto grepboot
	set count=0
	set file=n
	for /f "delims=" %%a in ('TOOLS\bin\find WORK TOOLS/tmp/original_installer ^| !busybox! grep \.img$') do (
		set /a count=!count!+1
		if !count! ==%filenumber% set file=%%a
	)
	if "!file!"=="n" goto grepboot
	echo CHECKING IF [!file!] IS A KERNEL
	set file2=!file:/=\!
	copy "!file2!" "WORK/boot.img">nul
	set kernelunpackq=y
	call :kernelunpack
	if exist "WORK\boot_unpacked\ramdisk\etc\recovery.fstab" (
		echo IT SEEMS THIS IS A RECOVERY NOT A KERNEL....ERROR
		!busybox! rm -rf WORK\boot_unpacked
		del WORK\boot.img
		pause>nul
		goto grepboot
	)
	if exist "WORK\boot_unpacked\ramdisk\sbin" (
		echo YES [!file!] IS A KERNEL
		!busybox! rm -rf WORK/boot_unpacked
		if "!search_q!"=="y" ( goto:eof ) else ( goto completed )
	)
	if not exist "WORK\boot_unpacked\ramdisk\sbin" (
		echo SORRY BUT [!file!] SEEMS NOT A KERNEL PLEASE TRY AGAIN
		!busybox! rm -rf WORK\boot_unpacked
		del WORK\boot.img
		pause>nul
		goto grepboot
	)
:completed
	TOOLS\bin\cecho {0a}COMPLETED. PRESS ENTER TO CONTINUE
	set /p press=
	goto start
:adbd_root
	if not exist "WORK\boot_unpacked\ramdisk\sbin" (
		echo NO KERNEL UNPACKED FOUND PLEASE UNPACK A KERNEL FIRST
		pause>nul
		goto kernel_recovery_menu
	)
	if exist "TOOLS\tmp\adbd.bak" (
		echo RESTORING ORIGINAL ADBD IN KERNEL
		del WORK\boot_unpacked\ramdisk\sbin\adbd
		move TOOLS\tmp\adbd.bak WORK\boot_unpacked\ramdisk\sbin\adbd >nul
		goto kernel_recovery_menu
	)
	set sure=n
	echo THIS WILL ENABLE [adb root] COMMAND THAT MEANS THE DEVICE
	echo WILL ALLOWS FOR ADB TO RUN AS ROOT
	TOOLS\bin\cecho {0e}WARNING: THIS FEATURE STILLS IN BETA MODE{#}
	echo.
	TOOLS\bin\cecho {0e}AND IT IS VERY ADVANCED AND DANGEROUS AND MAY CAUSE BOOTLOOP{#}
	echo.
	set /p sure=DO YOU WANT TO CONTINUE [DEFAULT=NO 1=YES]:
	if not "!sure!"=="1" goto kernel_recovery_menu
	echo ENABLING ADBD ROOT DIRECT IN KERNEL
	move WORK\boot_unpacked\ramdisk\sbin\adbd TOOLS\tmp\adbd.bak >nul
	copy TOOLS\xbin\adbd WORK\boot_unpacked\ramdisk\sbin\adbd >nul
	goto kernel_recovery_menu
:kernel_verity
	if not exist "WORK\boot_unpacked\ramdisk\sbin" (
		echo NO KERNEL UNPACKED FOUND PLEASE UNPACK A KERNEL FIRST
		pause>nul
		goto kernel_recovery_menu
	)
	if not "!dm_verity!"=="y" (
		echo THE DM-VERITY IS ALREADY DISABLED
		pause>nul
		goto kernel_recovery_menu
	)
	echo DM-VERITY IS A FEATURE TO CHECK YOUR DEVICE
	echo BLOCK PARTITIONS IF THEM STAY IN THE ORIGINAL STATUS
	echo AND IF NOT YOU WILL SEE A RED LINE IN THE STOCK RECOVERY
	echo FOR YOUR DEVICE [dm-verity failed]
	echo SO IT IS RECOMMENDED TO REMOVE IT
	set kernel_verity_rm=n
	set /p kernel_verity_rm=WHAT YOU WANT TO DO [DEFAULT=REMOVE 0=BACK]:
	if "!kernel_verity_rm!"=="0" goto kernel_recovery_menu
	echo REMOVING DM-VERITY FROM KERNEL
	for /f "delims=" %%a in ('TOOLS\bin\find WORK/!img_dir! -not -type l -name *fstab* ^| !busybox! grep -v charger ^| !busybox! grep -v goldfish ^| !busybox! grep -v ranchu') do (
		!busybox! sed -i "/\/system/s/,verify=//g" %%a
		!busybox! sed -i "/\/system/s/,verify//g" %%a
		!busybox! sed -i "/\/system/s/verify=//g" %%a
		!busybox! sed -i "/\/system/s/verify//g" %%a
	)
	set dm_verity=n
	for /f "delims=" %%a in ('TOOLS\bin\find WORK/!img_dir! -not -type l -name *fstab* ^| !busybox! grep -v charger ^| !busybox! grep -v goldfish ^| !busybox! grep -v ranchu ^| !busybox! grep -m 1 fstab') do (
		for /f "delims=" %%b in ('!busybox! grep -cw "verify" "%%a"') do if not "%%b"=="0" set dm_verity=y
	)
	if "!dm_verity!"=="y" (
		echo AN ERROR HAPPENED THE DM-VERITY IS STILLS ENABLED
		pause>nul
		goto kernel_recovery_menu
	)
	goto kernel_recovery_menu
:kernel_encrypt
	if not exist "WORK\boot_unpacked\ramdisk\sbin" (
		echo NO KERNEL UNPACKED FOUND PLEASE UNPACK A KERNEL FIRST
		pause>nul
		goto kernel_recovery_menu
	)
	IF "!force_encypt_allow!"=="n" (
		echo THIS KERNEL DOESN'T SUPPORT FORCE-ENCRYPT
		pause>nul
		goto kernel_recovery_menu
	)
	if "!force_encypt!"=="y" (
		echo REMOVING FORCE-ENCRYPT FROM KERNEL
		for /f "delims=" %%a in ('TOOLS\bin\find WORK/!img_dir! -not -type l -name *fstab* ^| !busybox! grep -v charger ^| !busybox! grep -v goldfish ^| !busybox! grep -v ranchu') do (
			for /f "delims=" %%b in ('!busybox! grep -cw "forceencrypt" %%a') do if not "%%b"=="0" (
				!busybox! sed -i "/\/data/s/forceencrypt/encryptable/g" %%a
				echo force>>TOOLS\tmp\forceencrypt
			)
			for /f "delims=" %%b in ('!busybox! grep -cw "forcefdeorfbe" %%a') do if not "%%b"=="0" (
				!busybox! sed -i "/\/data/s/forcefdeorfbe/encryptable/g" %%a
				echo force>>TOOLS\tmp\forcefdeorfbe
			)
		)
		goto kernel_recovery_menu
	) else (
		echo ADDING FORCE-ENCRYPT IN KERNEL
		for /f "delims=" %%a in ('TOOLS\bin\find WORK/!img_dir! -not -type l -name *fstab* ^| !busybox! grep -v charger ^| !busybox! grep -v goldfish ^| !busybox! grep -v ranchu') do (
			if not exist "TOOLS\tmp\forceencrypt" if not exist "TOOLS\tmp\forcefdeorfbe" !busybox! sed -i "/\/data/s/encryptable/forceencrypt/g" %%a
			if exist "TOOLS\tmp\forceencrypt" (
				del TOOLS\tmp\forceencrypt
				!busybox! sed -i "/\/data/s/encryptable/forceencrypt/g" %%a
			)
			if exist "TOOLS\tmp\forcefdeorfbe" (
				del TOOLS\tmp\forcefdeorfbe
				!busybox! sed -i "/\/data/s/encryptable/forcefdeorfbe/g" %%a
			)
		)
		goto kernel_recovery_menu
	)
:kernel_fix_seandroid
	echo THIS FEATURE WILL REMOVE THE [KERNEL/RECOVERY IS NOT SEANDROID ENFORCEING] 
	echo ON EVERY BOOT AND YOU NEED THIS IF YOU REPACKED THE KERNEL/RECOVERY
	echo OR FOR A CUSTOM RECOVERY [TWRP.....]
	echo ENSURE THERE IS [boot.img] OR [recovery.img] OR BOTH IN WORK FOLDER
	set /p press_enter=THEN PRESS ENTER TO CONTINUE
	if not exist "WORK\boot.img" if not exist "WORK\recovery.img" (
		echo ERROR THERE IS NO [kernel/recovery] IN WORK FOLDER
		pause>nul
		goto kernel_recovery_menu
	)
	if exist "WORK\boot.img" (
		echo CHECKING KERNEL ENFORCE STATUS
		for /f "delims=" %%a in ('!busybox! grep -c "SEANDROIDENFORCE" WORK/boot.img') do (
			if "%%a"=="0" (
				echo FIXING THE KERNEL ENFORCE STATUS
				!busybox! echo -n "SEANDROIDENFORCE" >> WORK/boot.img
			) else ( echo THE KERNEL IS IN OFFICIAL STATUS NO NEED FOR THIS )
		)
	)
	if exist "WORK\recovery.img" (
		echo CHECKING RECOVERY ENFORCE STATUS
		for /f "delims=" %%a in ('!busybox! grep -c "SEANDROIDENFORCE" WORK/recovery.img') do (
			if "%%a"=="0" (
				echo FIXING THE RECOVERY ENFORCE STATUS
				!busybox! echo -n "SEANDROIDENFORCE" >> WORK/recovery.img
			) else ( echo THE RECOVERY IS IN OFFICIAL STATUS NO NEED FOR THIS )
		)
	)
	TOOLS\bin\cecho {0a}COMPLETED. PRESS ENTER TO CONTINUE{#}
	set /p press=
	goto kernel_recovery_menu
:elf_2_img
	mkdir PLACE\elf_convert
	echo PUT [kernel.elf] IN [PLACE\elf_convert]
	set /p wait=PRESS ENTER WHEN YOU READY
	if not exist "PLACE\elf_convert\kernel.elf" (
		echo ERROR: NO [kernel.elf] FOUND
		pause>nul
		goto kernel_recovery_menu
	)
	echo CONVERTING [kernel.elf] TO [boot.img]
	call :convert_elf2img PLACE
	if not exist "PLACE\elf_convert\boot.img" (
		TOOLS\bin\cecho {0C}AN ERROR HAPPENED DURING THE CONVERT{#}
		echo.
		pause>nul
		goto kernel_recovery_menu
	)
	if exist "PLACE\elf_convert\boot.img" echo YOUR [boot.img] IN [PLACE\elf_convert]
	TOOLS\bin\cecho {0a}COMPLETED. PRESS ENTER TO CONTINUE{#}
	set /p press=
	goto kernel_recovery_menu
:convert_elf2img
	TOOLS\bin\7za x -y %1\elf_convert\kernel.elf -o"%1\elf_convert" >nul
	set second=
	set cmdline=
	set dt=
	if exist "%1\elf_convert\2" for /f "delims=" %%a in ('!busybox! grep -c "DT" %1\elf_convert\2') do (
		if not "%%a"=="0" set dt=--dt %1\elf_convert\2 
		if "%%a"=="0" set second=--second %1\elf_convert\2 
	)
	if exist "%1\elf_convert\3" set cmdline=--cmdline %1\elf_convert\3 
	TOOLS\kernel\mkbootimg --kernel %1\elf_convert\0 --ramdisk %1\elf_convert\1 %cmdline%%dt%%second%-o %1\elf_convert\boot.img >nul
	for %%a in (%1\elf_convert\boot.img) do if "%%~za"=="0" del %1\elf_convert\boot.img
	for %%a in (%1\elf_convert\*) do if not "%%~na%%~xa"=="boot.img" if not "%%~na%%~xa"=="kernel.elf" del %%a
	goto:eof
:papktool
	echo CHECKING JAVA STATUS.....
	java -version 2>TOOLS\tmp\java_test
	if errorlevel ==1 (
		echo YOU HAVN'T [JAVA] INSTALLED IN THIS COMPUTER CAN'T USE APKTOOL WITHOUT IT
		pause>nul
		goto start
	)
	for /f "delims=" %%a in ('!busybox! grep -w version TOOLS/tmp/java_test ^| TOOLS\bin\gawk "{print $3}" ^| !busybox! cut -d"""" -f2') do set java_version=%%a
	del TOOLS\tmp\java_test
	if not exist "WORK\system" (
		echo THERE IS NO [WORK/system]...AND THIS PATH USED TO WORK
		echo PLEASE CREATE ROM FIRST
		pause>nul
		goto start
	)
	TITLE ASSAYYED APKTOOLS
	IF EXIST WORK\apktool\working1 rmdir WORK\apktool\working1
	IF EXIST WORK\apktool\working2 rmdir WORK\apktool\working2
	CLS
	echo.
	echo.
	echo VERY IMPORTANT:
	echo NOW WE WILL USE APKs IN [WORK/system] TO WORK
	echo IF YOU DON'T HAVE A ROM UNDER WORK YOU CAN PUT
	echo ANY [APKs, JARs, AND DEXs] IN THE ABOVE PATH 
	echo THE MOST IMPORTANT THING: [REMOVE SPACES FROM FILES NAMES IF ANY]
	echo PRESS ANY KEY TO CONTINUE
	pause>nul
:apktool
	CLS
	color 07
	ECHO.
	ECHO.
	ECHO ___________________________________________________________
	ECHO     1  DECOMPILE FIRST METHOD [ANDROID 5.X.X+]
	ECHO.
	ECHO     2  COMPILE FIRST METHOD [ANDROID 5.X.X+]
	ECHO.
	ECHO     3  DECOMPILE SECOND METHOD [ANDROID 4.X.X-]
	ECHO.
	ECHO     4  COMPILE SECOND METHOD [ANDROID 4.X.X-]
	ECHO.
	ECHO     5  SIGNING APKs
	ECHO.
	ECHO     6  INSTALL SOURCES APKs
	ECHO.
	ECHO     7  CLEAR WORK FOLDER [FIRST METHOD]
	ECHO.
	ECHO     8  CLEAR WORK FOLDER [SECOND METHOD]
	ECHO.
	ECHO     9  CLEAR ALL WORKS DATA
	ECHO.
	ECHO     0  BACK TO THE KITCHEN
	ECHO ___________________________________________________________
	SET CHOICE=AS
	SET /P CHOICE=TYPE WHAT YOU WANT:
	SET CHOICE=%CHOICE:"=X%
	IF "!CHOICE!"=="1" GOTO DECFIRST
	IF "!CHOICE!"=="2" GOTO COMFIRST
	IF "!CHOICE!"=="3" GOTO DECSECOND
	IF "!CHOICE!"=="4" GOTO COMSECOND
	IF "!CHOICE!"=="5" GOTO SIGNING
	IF "!CHOICE!"=="6" GOTO PINSTALL
	IF "!CHOICE!"=="7" GOTO CLEANWORK1
	IF "!CHOICE!"=="8" GOTO CLEANWORK2
	IF "!CHOICE!"=="9" GOTO CLEANALL
	IF "!CHOICE!"=="0" GOTO START
	SET CHOICE=AS
	GOTO apktool
:decfirst
	color 07
	set type=n
	set /p type=WHAT DO YOU WANT TO DECOMPILE [DEFAULT=APK 1=JAR 2=DEX 0=BACK]:
	if "!type!"=="0" goto apktool
	if "!type!"=="1" goto decfirst_jar
	if "!type!"=="2" goto decfirst_dex
	goto decfirst_apk
:decfirst_jar
	color 07
	for /f "delims=" %%a in ('TOOLS\bin\find WORK/system -name *.jar ^| !busybox! wc -l') do if "%%a"=="0" (
		echo NO JAR FILES FOUND IN [WORK/system]
		pause>nul
		cls
		echo.
		echo.
		goto apktool
	)
	cls
	echo.
	echo.
	echo --------------------------------------------------------------
	set count=0
	for /f "delims=" %%f in ('TOOLS\bin\find WORK/system -name *.jar') do (
		set /a count=!count!+1
		if !count! leq 9 echo    !count! == %%~nf%%~xf
		if !count! geq 10 if !count! leq 99 echo   !count! == %%~nf%%~xf
		if !count! geq 100 echo  !count! == %%~nf%%~xf
	)
	echo --------------------------------------------------------------
	echo.
	SET filenumber=rr
	SET file=n
	set /p filenumber=SELECT FILE TO DECOMPILE [DEFAULT=REFRESH 0=BACK]:
	set filenumber=%filenumber: =x%
	set filenumber=%filenumber:,=x%
	set filenumber=%filenumber:"=x%
	if "!filenumber!"=="0" goto apktool
	IF "!filenumber!"=="rr" goto decfirst_jar
	set count=0
	for /f "delims=" %%f in ('TOOLS\bin\find WORK/system -name *.jar ^| !busybox! tr / \\') do (
		set /a count=!count!+1
		if !count! ==%filenumber% (
			SET FILE=%%f
			set basename=%%~nf%%~xf
		)
	)
	if "!file!"=="n" goto decfirst_jar
	IF EXIST WORK\apktool\working1\!basename! (
		ECHO REMOVING OLD [!basename!]
		RMDIR /S /Q WORK\apktool\working1\!basename!
	)
	ECHO EXTRACTING [!basename!]
	"TOOLS/bin/7za" x "!FILE!" -o"WORK\apktool\working1\!basename!\TMP_!basename!">nul
	copy !FILE! WORK\apktool\working1\!basename!\TMP_!basename!\!basename!>NUL
	if not exist "WORK\apktool\working1\!basename!\TMP_!basename!\*.dex" (
		echo ERROR THE JAR FILE [!basename!] DOESN'T CONTENT [classes.dex]
		rmdir /s /q WORK\apktool\working1\!basename!
		pause>nul
		goto decfirst_jar
	)
	FOR %%D IN (WORK\apktool\working1\!basename!\TMP_!basename!\*.dex) DO (
		ECHO DECOMPILING [%%~nD%%~xD]
		del TOOLS\tmp\apk_log.txt
		java -Xmx1024M -jar TOOLS\apktool\baksmali_new.jar disassemble %%D -o WORK\apktool\working1\!basename!\%%~nD%%~xD 1>>NUL 2>>TOOLS\tmp\apk_log.txt
	)
	IF errorlevel 1 (
		RMDIR /S /Q WORK\apktool\working1\!basename!
		tools\bin\cecho {0C}ERROR IN THE PROCESS WE CAN'T CONTINUE{#}
		echo PRESS ANY KEY TO OPEN THE ERROR LOG
		PAUSE>NUL
		Start TOOLS\notepad_pp\notepad++.exe TOOLS\tmp\apk_log.txt
		goto decfirst_jar
	)
	TOOLS\bin\cecho {0A}COMPLETED. PRESS ENTER TO CONTINUE{#}
	ECHO.
	PAUSE>NUL
	GOTO decfirst_jar
:decfirst_dex
	color 07
	for /f "delims=" %%a in ('TOOLS\bin\find WORK/system -name *.dex ^| !busybox! wc -l') do if "%%a"=="0" (
		echo NO DEX FILES FOUND IN [WORK/system]
		pause>nul
		cls
		echo.
		echo.
		goto apktool
	)
	cls
	echo.
	echo.
	echo --------------------------------------------------------------
	set count=0
	for /f "delims=" %%f in ('TOOLS\bin\find WORK/system -name *.dex') do (
		set /a count=!count!+1
		if !count! leq 9 echo    !count! == %%~nf%%~xf
		if !count! geq 10 if !count! leq 99 echo   !count! == %%~nf%%~xf
		if !count! geq 100 echo  !count! == %%~nf%%~xf
	)
	echo --------------------------------------------------------------
	echo.
	SET filenumber=rr
	set file=n
	set /p filenumber=SELECT FILE TO DECOMPILE [DEFAULT=REFRESH 0=BACK]:
	set filenumber=%filenumber: =x%
	set filenumber=%filenumber:,=x%
	set filenumber=%filenumber:"=x%
	if "!filenumber!"=="0" goto apktool
	IF "!filenumber!"=="rr" goto decfirst_dex
	set count=0
	for /f "delims=" %%f in ('TOOLS\bin\find WORK/system -name *.dex ^| !busybox! tr / \\') do (
		set /a count=!count!+1
		if !count! ==%filenumber% (
			SET FILE=%%f
			set basename=%%~nf%%~xf
		)
	)
	if "!file!"=="n" goto decfirst_dex
	IF EXIST WORK\apktool\working1\!basename! (
		ECHO REMOVING OLD [!basename!]
		RMDIR /S /Q WORK\apktool\working1\!basename!
	)
	ECHO DECOMPILING [!basename!]
	del TOOLS\tmp\apk_log.txt
	java -Xmx1024M -jar TOOLS\apktool\baksmali_new.jar disassemble !FILE! -o WORK\apktool\working1\!basename! 1>>NUL 2>>TOOLS\tmp\apk_log.txt
	IF errorlevel 1 (
		RMDIR /S /Q WORK\apktool\working1\!basename!
		tools\bin\cecho {0C}ERROR IN THE PROCESS WE CAN'T CONTINUE{#}
		echo PRESS ANY KEY TO OPEN THE ERROR LOG
		PAUSE>NUL
		Start TOOLS\notepad_pp\notepad++.exe TOOLS\tmp\apk_log.txt
		goto decfirst_dex
	)
	TOOLS\bin\cecho {0A}COMPLETED. PRESS ENTER TO CONTINUE{#}
	ECHO.
	PAUSE>NUL
	GOTO decfirst_dex
:decfirst_apk
	color 07
	for /f "delims=" %%a in ('TOOLS\bin\find WORK/system -name *.apk ^| !busybox! wc -l') do if "%%a"=="0" (
		echo NO APK FILES FOUND IN [WORK/system]
		pause>nul
		cls
		echo.
		echo.
		goto apktool
	)
	cls
	echo.
	echo.
	echo --------------------------------------------------------------
	set count=0
	for /f "delims=" %%f in ('TOOLS\bin\find WORK/system -name *.apk') do (
		set /a count=!count!+1
		if !count! leq 9 echo    !count! == %%~nf%%~xf
		if !count! geq 10 if !count! leq 99 echo   !count! == %%~nf%%~xf
		if !count! geq 100 echo  !count! == %%~nf%%~xf
	)
	echo --------------------------------------------------------------
	echo.
	SET filenumber=rr
	set file=n
	set /p filenumber=SELECT FILE TO DECOMPILE [DEFAULT=REFRESH 0=BACK]:
	set filenumber=%filenumber: =x%
	set filenumber=%filenumber:,=x%
	set filenumber=%filenumber:"=x%
	if "!filenumber!"=="0" goto apktool
	IF "!filenumber!"=="rr" goto decfirst_apk
	set count=0
	for /f "delims=" %%f in ('TOOLS\bin\find WORK/system -name *.apk ^| !busybox! tr / \\') do (
		set /a count=!count!+1
		if !count! ==%filenumber% (
			SET FILE=%%f
			set basename=%%~nf%%~xf
		)
	)
	if "!file!"=="n" goto decfirst_apk
	IF EXIST WORK\apktool\working1\!basename! (
		ECHO REMOVING OLD [!basename!]
		RMDIR /S /Q WORK\apktool\working1\!basename!
	)
	echo DECOMPILING [!basename!]
	IF NOT EXIST WORK\apktool\working1 MKDIR WORK\apktool\working1
	del TOOLS\tmp\apk_log.txt
	java -Xmx1024M -jar tools\apktool\apktool_new.jar d -f -o WORK\apktool\working1\!basename! !FILE! 1>>NUL 2>>TOOLS\tmp\apk_log.txt
	IF errorlevel 1 (
		RMDIR /S /Q WORK\apktool\working1\!basename!
		tools\bin\cecho {0C}ERROR IN THE PROCESS WE CAN'T CONTINUE{#}
		echo PRESS ANY KEY TO OPEN THE ERROR LOG
		PAUSE>NUL
		Start TOOLS\notepad_pp\notepad++.exe TOOLS\tmp\apk_log.txt
		goto decfirst_apk
	)
	TOOLS\bin\cecho {0A}COMPLETED. PRESS ENTER TO CONTINUE{#}
	ECHO.
	PAUSE>NUL
	GOTO decfirst_apk
:comfirst
	color 07
	IF EXIST WORK\apktool\working1 rmdir WORK\apktool\working1
	if not exist WORK\apktool\working1 (
		ECHO THERE IS NO WORKs TO COMPILING
		PAUSE>NUL
		GOTO apktool
	)
	cls
	echo.
	echo.
	echo --------------------------------------------------------------
	set count=0
	for /f %%F in ('dir WORK\apktool\working1 /ad /b' ) DO (
		set /a count=!count!+1
		if !count! LEQ 9 echo   !count! == %%F
		if !count! GEQ 10 echo  !count! == %%F
	)
	echo --------------------------------------------------------------
	echo.
	echo.
	SET filenumber=rr
	set KIND=n/a
	set /p filenumber=SELECT FOLDER TO COMPILE [DEFAULT=REFRESH 0=BACK]:
	set filenumber=%filenumber: =x%
	set filenumber=%filenumber:,=x%
	set filenumber=%filenumber:"=x%
	if "!filenumber!"=="0" goto apktool
	IF "!filenumber!"=="rr" goto comfirst
	set count=0
	for /f %%F in ('dir WORK\apktool\working1 /ad /b' ) DO (
		set /a count=!count!+1
		if !count! ==%filenumber% (
			SET FILE=%%F
			SET KIND=%%~xF
		)
	)
	IF %KIND% ==.apk (
		IF EXIST "WORK\apktool\working1\%FILE%\dist" RMDIR /S /Q WORK\apktool\working1\%FILE%\dist
		ECHO COMPILING [%FILE%]
		del tools\tmp\apk_log.txt
		java -Xmx1024M -jar tools\apktool\apktool_new.jar b WORK\apktool\working1\%FILE% 1>>NUL 2>>TOOLS\tmp\apk_log.txt
		IF NOT EXIST "WORK\apktool\working1\%FILE%\dist\%FILE%" (
			tools\bin\cecho {0C}ERROR IN THE PROCESS CAN'T CONTINUE{#}
			echo PRESS ANY KEY TO OPEN THE ERROR LOG
			PAUSE>NUL
			Start TOOLS\notepad_pp\notepad++.exe TOOLS\tmp\apk_log.txt
			goto comfirst
		)
		IF EXIST "WORK\apktool\working1\%FILE%\dist\%FILE%" (
			MOVE WORK\apktool\working1\%FILE%\original\META-INF WORK\apktool\working1\%FILE%\dist\META-INF>NUL
			MOVE WORK\apktool\working1\%FILE%\original\AndroidManifest.xml WORK\apktool\working1\%FILE%\dist\AndroidManifest.xml>NUL
			CD WORK\apktool\working1\%FILE%\dist
			"../../../../../tools/bin/7za" u -tzip %FILE% "AndroidManifest.xml">nul
			"../../../../../tools/bin/7za" u -tzip %FILE% "META-INF">nul
			CD ..\..\..\..\..
			MOVE WORK\apktool\working1\!FILE!\dist\META-INF WORK\apktool\working1\!FILE!\original\META-INF>NUL
			MOVE WORK\apktool\working1\!FILE!\dist\AndroidManifest.xml WORK\apktool\working1\!FILE!\original\AndroidManifest.xml>NUL
			ECHO ZIPALIGNING [%FILE%]
			"tools/bin/zipalign" -f -p 4 "WORK\apktool\working1\%FILE%\dist\%FILE%" "WORK\apktool\working1\%FILE%\dist\%FILE%.zip" > NUL
			del "WORK\apktool\working1\%FILE%\dist\%FILE%" >nul
			rename "WORK\apktool\working1\%FILE%\dist\%FILE%.zip" "%FILE%"
			echo SEARCHING FOR ORIGINAL FILE LOCATION
			SET location=n
			for /f "delims=" %%a in ('TOOLS\bin\find WORK/system -name !FILE! ^| !busybox! tr / \\') do set location=%%a
			if "!location!"=="n" (
				echo FATAL ERROR: WE CAN'T DETECT THE ORIGINAL LOCATION FOR
				echo THE [!FILE!] THIS HAPPENED IF YOU DELETED THE ORIGINAL FILE
				echo ANY WAY THE NEW COMPILED FILE IN [WORK\apktool\working1\!FILE!\dist\!file!]
			)
			if not "!location!"=="n" (
				del !location!
				echo MOVING [!FILE!] TO [!location!]
				move WORK\apktool\working1\!FILE!\dist\!file! !location! >nul
			)
			TOOLS\bin\cecho {0A}COMPLETED. PRESS ENTER TO CONTINUE{#}
			ECHO.
			PAUSE>NUL
			GOTO comfirst
		)
	)
	IF %KIND% ==.jar (
		MOVE WORK\apktool\working1\%FILE%\TMP_%FILE% WORK\apktool\working1\TMP_%FILE%>NUL
		del WORK\apktool\working1\TMP_%FILE%\*.dex
		ECHO COMPILING [%FILE%]
		del TOOLS\tmp\apk_log.txt
		for /f "delims=" %%z in ('TOOLS\bin\find WORK\apktool\working1\!FILE! -type d -name classes*.dex ^| !busybox! tr / \\') do java -Xmx1024M -jar tools\apktool\smali_new.jar assemble %%z -o WORK\apktool\working1\TMP_%FILE%\%%~nz%%~xz 1>>NUL 2>>TOOLS\tmp\apk_log.txt
		IF NOT EXIST "WORK\apktool\working1\TMP_%FILE%\*.dex" (
			tools\bin\cecho {0C}ERROR IN THE PROCESS CAN'T CONTINUE{#}
			echo PRESS ANY KEY TO OPEN THE ERROR LOG
			PAUSE>NUL
			Start TOOLS\notepad_pp\notepad++.exe TOOLS\tmp\apk_log.txt
			goto comfirst
		)
		ECHO CREATING [%FILE%]
		cd WORK\apktool\working1\TMP_%FILE%
		"../../../../tools/bin/7za" u -tzip %FILE% "*.dex">nul
		cd ..\..\..\..
		MOVE WORK\apktool\working1\TMP_%FILE% WORK\apktool\working1\%FILE%\TMP_%FILE%>NUL
		SET location=n
		for /f "delims=" %%a in ('TOOLS\bin\find WORK/system -name !FILE! ^| !busybox! tr / \\') do set location=%%a
		if "!location!"=="n" (
			echo FATAL ERROR: WE CAN'T DETECT THE ORIGINAL LOCATION FOR
			echo THE [!FILE!] THIS HAPPENED IF YOU DELETED THE ORIGINAL FILE
			echo ANY WAY THE NEW COMPILED FILE IN [WORK\apktool\working1\%FILE%\TMP_%FILE%\%FILE%]
		)
		if not "!location!"=="n" (
			del !location!
			echo COPYING [!FILE!] TO [!location!]
			COPY WORK\apktool\working1\%FILE%\TMP_%FILE%\%FILE% !location!>NUL
		)
		TOOLS\BIN\cecho {0A}COMPLETED. PRESS ENTER TO CONTINUE{#}
		ECHO.
		PAUSE>NUL
		GOTO comfirst
	)
	IF %KIND% ==.dex (
		ECHO COMPILING [%FILE%]
		del TOOLS\tmp\apk_log.txt
		java -Xmx1024M -jar tools\apktool\smali_new.jar assemble WORK\apktool\working1\%FILE% -o WORK\apktool\working1\%FILE%\%FILE% 1>>NUL 2>>TOOLS\tmp\apk_log.txt
		IF NOT EXIST "WORK\apktool\working1\%FILE%\%FILE%" (
			tools\bin\cecho {0C}ERROR IN THE PROCESS CAN'T CONTINUE{#}
			echo PRESS ANY KEY TO OPEN THE ERROR LOG
			PAUSE>NUL
			Start TOOLS\notepad_pp\notepad++.exe TOOLS\tmp\apk_log.txt
			goto comfirst
		)
		IF exist "WORK\apktool\working1\%FILE%\%FILE%" echo THE COMPILED FILE IN [WORK\apktool\working1\%FILE%\%FILE%]
		TOOLS\bin\cecho {0A}COMPLETED. PRESS ENTER TO CONTINUE{#}
		ECHO.
		PAUSE>NUL
		GOTO comfirst
	)
	IF NOT %KIND% ==.apk if not %KIND% ==.dex if not %KIND% ==.jar if not %KIND% ==n/a (
		ECHO ERROR...UNKNOWN FILE TYPE
		PAUSE>NUL
		GOTO comfirst
	)
	SET filenumber=rr
	goto comfirst
:decsecond
	color 07
	set type=n
	set /p type=WHAT DO YOU WANT TO DECOMPILE [DEFAULT=APK 1=JAR 2=DEX 0=BACK]:
	if "!type!"=="0" goto apktool
	if "!type!"=="1" goto decsecond_jar
	if "!type!"=="2" goto decsecond_dex
	goto decsecond_apk
:decsecond_jar
	color 07
	for /f "delims=" %%a in ('TOOLS\bin\find WORK/system -name *.jar ^| !busybox! wc -l') do if "%%a"=="0" (
		echo NO JAR FILES FOUND IN [WORK/system]
		pause>nul
		cls
		echo.
		echo.
		goto apktool
	)
	cls
	echo.
	echo.
	echo --------------------------------------------------------------
	set count=0
	for /f "delims=" %%f in ('TOOLS\bin\find WORK/system -name *.jar') do (
		set /a count=!count!+1
		if !count! leq 9 echo    !count! == %%~nf%%~xf
		if !count! geq 10 if !count! leq 99 echo   !count! == %%~nf%%~xf
		if !count! geq 100 echo  !count! == %%~nf%%~xf
	)
	echo --------------------------------------------------------------
	echo.
	SET filenumber=rr
	SET file=n
	set /p filenumber=SELECT FILE TO DECOMPILE [DEFAULT=REFRESH 0=BACK]:
	set filenumber=%filenumber: =x%
	set filenumber=%filenumber:,=x%
	set filenumber=%filenumber:"=x%
	if "!filenumber!"=="0" goto apktool
	IF "!filenumber!"=="rr" goto decsecond_jar
	set count=0
	for /f "delims=" %%f in ('TOOLS\bin\find WORK/system -name *.jar ^| !busybox! tr / \\') do (
		set /a count=!count!+1
		if !count! ==%filenumber% (
			SET FILE=%%f
			set basename=%%~nf%%~xf
		)
	)
	if "!file!"=="n" goto decsecond_jar
	IF EXIST WORK\apktool\working2\!basename! (
		ECHO REMOVING OLD [!basename!]
		RMDIR /S /Q WORK\apktool\working2\!basename!
	)
	ECHO EXTRACTING [!basename!]
	"TOOLS/bin/7za" x "!FILE!" -o"WORK\apktool\working2\!basename!\TMP_!basename!">nul
	copy !FILE! WORK\apktool\working2\!basename!\TMP_!basename!\!basename!>NUL
	if not exist "WORK\apktool\working2\!basename!\TMP_!basename!\*.dex" (
		echo ERROR THE JAR FILE [!basename!] DOESN'T CONTENT [classes.dex]
		rmdir /s /q WORK\apktool\working2\!basename!
		pause>nul
		goto decsecond_jar
	)
	FOR %%D IN (WORK\apktool\working2\!basename!\TMP_!basename!\*.dex) DO (
		ECHO DECOMPILING [%%~nD%%~xD]
		del TOOLS\tmp\apk_log.txt
		java -Xmx1024M -jar TOOLS\deodex\baksmali.jar -o WORK\apktool\working2\!basename!\%%~nD%%~xD %%D 1>>NUL 2>>TOOLS\tmp\apk_log.txt
	)
	IF errorlevel 1 (
		RMDIR /S /Q WORK\apktool\working2\!basename!
		tools\bin\cecho {0C}ERROR IN THE PROCESS WE CAN'T CONTINUE{#}
		echo PRESS ANY KEY TO OPEN THE ERROR LOG
		PAUSE>NUL
		Start TOOLS\notepad_pp\notepad++.exe TOOLS\tmp\apk_log.txt
		goto decsecond_jar
	)
	TOOLS\bin\cecho {0A}COMPLETED. PRESS ENTER TO CONTINUE{#}
	ECHO.
	PAUSE>NUL
	GOTO decsecond_jar
:decsecond_dex
	color 07
	for /f "delims=" %%a in ('TOOLS\bin\find WORK/system -name *.dex ^| !busybox! wc -l') do if "%%a"=="0" (
		echo NO DEX FILES FOUND IN [WORK/system]
		pause>nul
		cls
		echo.
		echo.
		goto apktool
	)
	cls
	echo.
	echo.
	echo --------------------------------------------------------------
	set count=0
	for /f "delims=" %%f in ('TOOLS\bin\find WORK/system -name *.dex') do (
		set /a count=!count!+1
		if !count! leq 9 echo    !count! == %%~nf%%~xf
		if !count! geq 10 if !count! leq 99 echo   !count! == %%~nf%%~xf
		if !count! geq 100 echo  !count! == %%~nf%%~xf
	)
	echo --------------------------------------------------------------
	echo.
	SET filenumber=rr
	set file=n
	set /p filenumber=SELECT FILE TO DECOMPILE [DEFAULT=REFRESH 0=BACK]:
	set filenumber=%filenumber: =x%
	set filenumber=%filenumber:,=x%
	set filenumber=%filenumber:"=x%
	if "!filenumber!"=="0" goto apktool
	IF "!filenumber!"=="rr" goto decsecond_dex
	set count=0
	for /f "delims=" %%f in ('TOOLS\bin\find WORK/system -name *.dex ^| !busybox! tr / \\') do (
		set /a count=!count!+1
		if !count! ==%filenumber% (
			SET FILE=%%f
			set basename=%%~nf%%~xf
		)
	)
	if "!file!"=="n" goto decsecond_dex
	IF EXIST WORK\apktool\working2\!basename! (
		ECHO REMOVING OLD [!basename!]
		RMDIR /S /Q WORK\apktool\working2\!basename!
	)
	ECHO DECOMPILING [!basename!]
	del TOOLS\tmp\apk_log.txt
	java -Xmx1024M -jar TOOLS\deodex\baksmali.jar -o WORK\apktool\working2\!basename! !FILE! 1>>NUL 2>>TOOLS\tmp\apk_log.txt
	IF errorlevel 1 (
		RMDIR /S /Q WORK\apktool\working2\!basename!
		tools\bin\cecho {0C}ERROR IN THE PROCESS WE CAN'T CONTINUE{#}
		echo PRESS ANY KEY TO OPEN THE ERROR LOG
		PAUSE>NUL
		Start TOOLS\notepad_pp\notepad++.exe TOOLS\tmp\apk_log.txt
		goto decsecond_dex
	)
	TOOLS\bin\cecho {0A}COMPLETED. PRESS ENTER TO CONTINUE{#}
	ECHO.
	PAUSE>NUL
	GOTO decsecond_dex
:decsecond_apk
	color 07
	for /f "delims=" %%a in ('TOOLS\bin\find WORK/system -name *.apk ^| !busybox! wc -l') do if "%%a"=="0" (
		echo NO APK FILES FOUND IN [WORK/system]
		pause>nul
		cls
		echo.
		echo.
		goto apktool
	)
	cls
	echo.
	echo.
	echo --------------------------------------------------------------
	set count=0
	for /f "delims=" %%f in ('TOOLS\bin\find WORK/system -name *.apk') do (
		set /a count=!count!+1
		if !count! leq 9 echo    !count! == %%~nf%%~xf
		if !count! geq 10 if !count! leq 99 echo   !count! == %%~nf%%~xf
		if !count! geq 100 echo  !count! == %%~nf%%~xf
	)
	echo --------------------------------------------------------------
	echo.
	SET filenumber=rr
	set file=n
	set /p filenumber=SELECT FILE TO DECOMPILE [DEFAULT=REFRESH 0=BACK]:
	set filenumber=%filenumber: =x%
	set filenumber=%filenumber:,=x%
	set filenumber=%filenumber:"=x%
	if "!filenumber!"=="0" goto apktool
	IF "!filenumber!"=="rr" goto decsecond_apk
	set count=0
	for /f "delims=" %%f in ('TOOLS\bin\find WORK/system -name *.apk ^| !busybox! tr / \\') do (
		set /a count=!count!+1
		if !count! ==%filenumber% (
			SET FILE=%%f
			set basename=%%~nf%%~xf
		)
	)
	if "!file!"=="n" goto decsecond_apk
	IF EXIST WORK\apktool\working2\!basename! (
		ECHO REMOVING OLD [!basename!]
		RMDIR /S /Q WORK\apktool\working2\!basename!
	)
	echo DECOMPILING [!basename!]
	IF NOT EXIST WORK\apktool\working2 MKDIR WORK\apktool\working2
	del TOOLS\tmp\apk_log.txt
	java -Xmx1024M -jar tools\apktool\apktool_old.jar d -f %FILE% WORK\apktool\working2\!basename! 1>>NUL 2>>TOOLS\tmp\apk_log.txt
	IF errorlevel 1 (
		RMDIR /S /Q WORK\apktool\working2\!basename!
		tools\bin\cecho {0C}ERROR IN THE PROCESS WE CAN'T CONTINUE{#}
		echo PRESS ANY KEY TO OPEN THE ERROR LOG
		PAUSE>NUL
		Start TOOLS\notepad_pp\notepad++.exe TOOLS\tmp\apk_log.txt
		goto decsecond_apk
	)
	"TOOLS/bin/7za" x "%FILE%" -o"WORK\apktool\working2\!basename!\TMP_!basename!">nul
	MKDIR WORK\apktool\working2\!basename!\original
	MOVE WORK\apktool\working2\!basename!\TMP_!basename!\META-INF WORK\apktool\working2\!basename!\original\META-INF>NUL
	MOVE WORK\apktool\working2\!basename!\TMP_!basename!\AndroidManifest.xml WORK\apktool\working2\!basename!\original\AndroidManifest.xml>nUL
	RMDIR /S /Q WORK\apktool\working2\!basename!\TMP_!basename!
	TOOLS\bin\cecho {0A}COMPLETED. PRESS ENTER TO CONTINUE{#}
	ECHO.
	PAUSE>NUL
	GOTO decsecond_apk
:comsecond
	color 07
	IF EXIST WORK\apktool\working2 rmdir WORK\apktool\working2
	if not exist WORK\apktool\working2 (
		ECHO THERE IS NO WORKs TO COMPILING
		PAUSE>NUL
		GOTO apktool
	)
	cls
	echo.
	echo.
	echo --------------------------------------------------------------
	set count=0
	for /f %%F in ('dir WORK\apktool\working2 /ad /b' ) DO (
		set /a count=!count!+1
		if !count! LEQ 9 echo   !count! == %%F
		if !count! GEQ 10 echo  !count! == %%F
	)
	echo --------------------------------------------------------------
	echo.
	echo.
	SET filenumber=rr
	set KIND=n/a
	set /p filenumber=SELECT FOLDER TO COMPILE [DEFAULT=REFRESH 0=BACK]:
	set filenumber=%filenumber: =x%
	set filenumber=%filenumber:,=x%
	set filenumber=%filenumber:"=x%
	if "!filenumber!"=="0" goto apktool
	IF "!filenumber!"=="rr" goto comsecond
	set count=0
	for /f %%F in ('dir WORK\apktool\working2 /ad /b' ) DO (
		set /a count=!count!+1
		if !count! ==%filenumber% (
			SET FILE=%%F
			SET KIND=%%~xF
		)
	)
	IF %KIND% ==.apk (
		IF EXIST "WORK\apktool\working2\%FILE%\dist" RMDIR /S /Q WORK\apktool\working2\%FILE%\dist
		ECHO COMPILING [%FILE%]
		del tools\tmp\apk_log.txt
		java -Xmx1024M -jar tools\apktool\apktool_old.jar b -a tools\apktool\aapt.exe WORK\apktool\working2\!FILE! 1>>NUL 2>>TOOLS\tmp\apk_log.txt
		IF NOT EXIST "WORK\apktool\working2\%FILE%\dist\%FILE%" (
			tools\bin\cecho {0C}ERROR IN THE PROCESS CAN'T CONTINUE{#}
			echo PRESS ANY KEY TO OPEN THE ERROR LOG
			PAUSE>NUL
			Start TOOLS\notepad_pp\notepad++.exe TOOLS\tmp\apk_log.txt
			goto comsecond
		)
		IF EXIST "WORK\apktool\working2\%FILE%\dist\%FILE%" (
			MOVE WORK\apktool\working2\%FILE%\original\META-INF WORK\apktool\working2\%FILE%\dist\META-INF>NUL
			MOVE WORK\apktool\working2\%FILE%\original\AndroidManifest.xml WORK\apktool\working2\%FILE%\dist\AndroidManifest.xml>NUL
			CD WORK\apktool\working2\%FILE%\dist
			"../../../../../tools/bin/7za" u -tzip %FILE% "AndroidManifest.xml">nul
			"../../../../../tools/bin/7za" u -tzip %FILE% "META-INF">nul
			CD ..\..\..\..\..
			MOVE WORK\apktool\working2\!FILE!\dist\META-INF WORK\apktool\working2\!FILE!\original\META-INF>NUL
			MOVE WORK\apktool\working2\!FILE!\dist\AndroidManifest.xml WORK\apktool\working2\!FILE!\original\AndroidManifest.xml>NUL
			ECHO ZIPALIGNING [%FILE%]
			"tools/bin/zipalign" -f -p 4 "WORK\apktool\working2\%FILE%\dist\%FILE%" "WORK\apktool\working2\%FILE%\dist\%FILE%.zip" > NUL
			del "WORK\apktool\working2\%FILE%\dist\%FILE%" >nul
			rename "WORK\apktool\working2\%FILE%\dist\%FILE%.zip" "%FILE%"
			echo SEARCHING FOR ORIGINAL FILE LOCATION
			SET location=n
			for /f "delims=" %%a in ('TOOLS\bin\find WORK/system -name !FILE! ^| !busybox! tr / \\') do set location=%%a
			if "!location!"=="n" (
				echo FATAL ERROR: WE CAN'T DETECT THE ORIGINAL LOCATION FOR
				echo THE [!FILE!] THIS HAPPENED IF YOU DELETED THE ORIGINAL FILE
				echo ANY WAY THE NEW COMPILED FILE IN [WORK\apktool\working2\!FILE!\dist\!file!]
			)
			if not "!location!"=="n" (
				del !location!
				echo MOVING [!FILE!] TO [!location!]
				move WORK\apktool\working2\!FILE!\dist\!file! !location! >nul
			)
			TOOLS\bin\cecho {0A}COMPLETED. PRESS ENTER TO CONTINUE{#}
			ECHO.
			PAUSE>NUL
			GOTO comsecond
		)
	)
	IF %KIND% ==.jar (
		MOVE WORK\apktool\working2\%FILE%\TMP_%FILE% WORK\apktool\working2\TMP_%FILE%>NUL
		del WORK\apktool\working2\TMP_%FILE%\*.dex
		ECHO COMPILING [%FILE%]
		del TOOLS\tmp\apk_log.txt
		for /f "delims=" %%z in ('TOOLS\bin\find WORK\apktool\working2\!FILE! -type d -name classes*.dex ^| !busybox! tr / \\') do java -Xmx1024M -jar tools\apktool\smali_new.jar %%z -o WORK\apktool\working2\TMP_%FILE%\%%~nz%%~xz 1>>NUL 2>>TOOLS\tmp\apk_log.txt
		IF NOT EXIST "WORK\apktool\working2\TMP_%FILE%\*.dex" (
			tools\bin\cecho {0C}ERROR IN THE PROCESS CAN'T CONTINUE{#}
			echo PRESS ANY KEY TO OPEN THE ERROR LOG
			PAUSE>NUL
			Start TOOLS\notepad_pp\notepad++.exe TOOLS\tmp\apk_log.txt
			goto comsecond
		)
		ECHO CREATING [%FILE%]
		cd WORK\apktool\working2\TMP_%FILE%
		"../../../../tools/bin/7za" u -tzip %FILE% "*.dex">nul
		cd ..\..\..\..
		MOVE WORK\apktool\working2\TMP_%FILE% WORK\apktool\working2\%FILE%\TMP_%FILE%>NUL
		SET location=n
		for /f "delims=" %%a in ('TOOLS\bin\find WORK/system -name !FILE! ^| !busybox! tr / \\') do set location=%%a
		if "!location!"=="n" (
			echo FATAL ERROR: WE CAN'T DETECT THE ORIGINAL LOCATION FOR
			echo THE [!FILE!] THIS HAPPENED IF YOU DELETED THE ORIGINAL FILE
			echo ANY WAY THE NEW COMPILED FILE IN [WORK\apktool\working2\%FILE%\TMP_%FILE%\%FILE%]
		)
		if not "!location!"=="n" (
			del !location!
			echo COPYING [!FILE!] TO [!location!]
			COPY WORK\apktool\working2\%FILE%\TMP_%FILE%\%FILE% !location!>NUL
		)
		TOOLS\BIN\cecho {0A}COMPLETED. PRESS ENTER TO CONTINUE{#}
		ECHO.
		PAUSE>NUL
		GOTO comsecond
	)
	IF %KIND% ==.dex (
		ECHO COMPILING [%FILE%]
		del TOOLS\tmp\apk_log.txt
		java -Xmx1024M -jar tools\deodex\smali.jar WORK\apktool\working2\%FILE% -o WORK\apktool\working2\%FILE%\%FILE% 1>>NUL 2>>TOOLS\tmp\apk_log.txt
		IF NOT EXIST "WORK\apktool\working2\%FILE%\%FILE%" (
			tools\bin\cecho {0C}ERROR IN THE PROCESS CAN'T CONTINUE{#}
			echo PRESS ANY KEY TO OPEN THE ERROR LOG
			PAUSE>NUL
			Start TOOLS\notepad_pp\notepad++.exe TOOLS\tmp\apk_log.txt
			goto comsecond
		)
		IF exist "WORK\apktool\working2\%FILE%\%FILE%" echo THE COMPILED FILE IN [WORK\apktool\working2\%FILE%\%FILE%]
		TOOLS\bin\cecho {0A}COMPLETED. PRESS ENTER TO CONTINUE{#}
		ECHO.
		PAUSE>NUL
		GOTO comsecond
	)
	IF NOT %KIND% ==.apk if not %KIND% ==.dex if not %KIND% ==.jar if not %KIND% ==n/a (
		ECHO ERROR...UNKNOWN FILE TYPE
		PAUSE>NUL
		GOTO comsecond
	)
	SET filenumber=rr
	goto comsecond
:SIGNING
	color 07
	for /f "delims=" %%a in ('TOOLS\bin\find WORK/system -name *.apk ^| !busybox! wc -l') do if "%%a"=="0" (
		echo NO APK FILES FOUND IN [WORK/system]
		pause>nul
		cls
		echo.
		echo.
		goto apktool
	)
	cls
	echo.
	echo.
	echo --------------------------------------------------------------
	set count=0
	for /f "delims=" %%f in ('TOOLS\bin\find WORK/system -name *.apk') do (
		set /a count=!count!+1
		if !count! leq 9 echo    !count! == %%~nf%%~xf
		if !count! geq 10 if !count! leq 99 echo   !count! == %%~nf%%~xf
		if !count! geq 100 echo  !count! == %%~nf%%~xf
	)
	echo --------------------------------------------------------------
	echo.
	SET filenumber=rr
	set file=n
	set /p filenumber=SELECT FILE TO SIGN [DEFAULT=REFRESH 0=BACK]:
	set filenumber=%filenumber: =x%
	set filenumber=%filenumber:,=x%
	set filenumber=%filenumber:"=x%
	if "!filenumber!"=="0" goto apktool
	IF "!filenumber!"=="rr" goto SIGNING
	set count=0
	for /f "delims=" %%f in ('TOOLS\bin\find WORK/system -name *.apk ^| !busybox! tr / \\') do (
		set /a count=!count!+1
		if !count! ==%filenumber% (
			SET FILE=%%f
			set basename=%%~nf%%~xf
		)
	)
	if "!file!"=="n" goto SIGNING
	echo SIGNING [!basename!]
	del TOOLS\tmp\apk_log.txt
	java -Xmx1024M -jar tools\apktool\signapk_2.jar -w tools\apktool\testkey.x509.pem tools\apktool\testkey.pk8 !FILE! TOOLS\tmp\new_signed.apk 1>>NUL 2>>TOOLS\tmp\apk_log.txt
	IF NOT EXIST "TOOLS\tmp\new_signed.apk" (
		tools\bin\cecho {0C}ERROR IN THE PROCESS CAN'T CONTINUE{#}
		echo PRESS ANY KEY TO OPEN THE ERROR LOG
		PAUSE>NUL
		Start TOOLS\notepad_pp\notepad++.exe TOOLS\tmp\apk_log.txt
		goto SIGNING
	)
	IF EXIST "TOOLS\tmp\new_signed.apk" (
		Del !FILE!
		move TOOLS\tmp\new_signed.apk %FILE% >nul
	)
	TOOLS\bin\cecho {0A}COMPLETED. PRESS ENTER TO CONTINUE{#}
	ECHO.
	PAUSE>NUL
	GOTO SIGNING
	SET filenumber=rr
	goto SIGNING
:PINSTALL
	color 07
	for /f "delims=" %%a in ('TOOLS\bin\find WORK/system/framework -name *.apk ^| !busybox! wc -l') do if "%%a"=="0" (
		echo NO APK FILES FOUND IN [WORK/system/framework]
		pause>nul
		cls
		echo.
		echo.
		goto apktool
	)
	cls
	echo.
	echo.
	echo WE WILL SEARCH FOR SOURCES APKs IN [WORK/system/framework]
	echo SO IF YOU HAVE SOURCES IN OTHER PLACE MOVE THEM TO THE ABOVE
	echo PRESS ANY KEY WHEN YOU FINISH
	pause>nul
:INSTALL
	cls
	echo.
	echo.
	echo --------------------------------------------------------------
	set count=0
	for /f "delims=" %%f in ('TOOLS\bin\find WORK/system/framework -name *.apk') do (
		set /a count=!count!+1
		if !count! leq 9 echo    !count! == %%~nf%%~xf
		if !count! geq 10 if !count! leq 99 echo   !count! == %%~nf%%~xf
		if !count! geq 100 echo  !count! == %%~nf%%~xf
	)
	echo --------------------------------------------------------------
	echo.
	SET filenumber=rr
	set file=n
	set /p filenumber=SELECT FILE TO INSTALL [DEFAULT=REFRESH 0=BACK]:
	set filenumber=%filenumber: =x%
	set filenumber=%filenumber:,=x%
	set filenumber=%filenumber:"=x%
	if "!filenumber!"=="0" goto apktool
	IF "!filenumber!"=="rr" goto INSTALL
	set count=0
	for /f "delims=" %%f in ('TOOLS\bin\find WORK/system/framework -name *.apk ^| !busybox! tr / \\') do (
		set /a count=!count!+1
		if !count! ==%filenumber% (
			SET FILE=%%f
			set basename=%%~nf%%~xf
		)
	)
	if "!file!"=="n" goto INSTALL
	echo INSTALLING [!basename!]
	del TOOLS\tmp\apk_log.txt
	java -Xmx1024M -jar tools\apktool\apktool_new.jar if !FILE! 1>>NUL 2>>TOOLS\tmp\apk_log.txt
	IF ERRORLEVEL 1 (
		tools\bin\cecho {0C}ERROR IN THE PROCESS CAN'T CONTINUE{#}
		echo PRESS ANY KEY TO OPEN THE ERROR LOG
		PAUSE>NUL
		Start TOOLS\notepad_pp\notepad++.exe TOOLS\tmp\apk_log.txt
		goto INSTALL
	)
	TOOLS\bin\cecho {0A}COMPLETED. PRESS ENTER TO CONTINUE{#}
	ECHO.
	PAUSE>NUL
	GOTO install
	SET filenumber=rr
	goto INSTALL
:CLEANWORK1
	IF NOT EXIST "WORK\apktool\working1" (
		ECHO NO [WORK\apktool\working1] FOLDER FOUND
		PAUSE>NUL
		GOTO apktool
	)
	IF EXIST "WORK\apktool\working1" (
		ECHO CLEANING [WORK\apktool\working1] FOLDER
		!busybox! rm -rf  WORK/apktool/working1
	)
	TOOLS\bin\CECHO {0A}COMPLETED. PRESS ENTER TO CONTINUE{#}
	ECHO.
	PAUSE>NUL
	GOTO apktool
:CLEANWORK2
	IF NOT EXIST "WORK\apktool\working2" (
		ECHO NO [WORK\apktool\working2] FOLDER FOUND
		PAUSE>NUL
		GOTO apktool
	)
	IF EXIST "WORK\apktool\working2" (
		ECHO CLEANING [WORK\apktool\working2] FOLDER
		!busybox! rm -rf  WORK/apktool/working2
	)
	TOOLS\bin\CECHO {0A}COMPLETED. PRESS ENTER TO CONTINUE{#}
	ECHO.
	PAUSE>NUL
	GOTO apktool
:CLEANALL
	IF NOT EXIST "WORK\apktool" (
		ECHO NO DATA FOUND TO CLEAN
		PAUSE>NUL
		GOTO apktool
	)
	echo CLEANING ALL APKTOOL DATA
	!busybox! rm -rf WORK/apktool TOOLS/tmp/apk_log.txt
	TOOLS\bin\CECHO {0A}COMPLETED. PRESS ENTER TO CONTINUE{#}
	ECHO.
	PAUSE>NUL
	GOTO apktool
:images_menu
	CLS
	title ASSAYYED FILESYSTEMS_CONVERTER
	color 07
	ECHO.
	ECHO.
	ECHO ___________________________________________________________
	ECHO     1  EXTRACT FILES FROM [cache.img/userdata.img/hidden.img]
	ECHO.
	ECHO     2  EXTRACT FILES FROM [system/data.ext4.win*]
	ECHO.
	ECHO     3  CONVERT BETWEEN [.dat] AND [.img]
	ECHO.
	ECHO     4  CONVERT BETWEEN [.sfs] AND [.img]
	ECHO.
	ECHO     5  CONVERT BETWEEN SPARSE AND RAW EXT4
	ECHO.
	ECHO     0  BACK TO THE KITCHEN
	ECHO ___________________________________________________________
	SET CHOICE=AS
	SET /P CHOICE=TYPE WHAT YOU WANT:
	SET CHOICE=%CHOICE:"=X%
	IF "!CHOICE!"=="1" GOTO extract_img
	IF "!CHOICE!"=="2" GOTO extract_twrp
	IF "!CHOICE!"=="3" GOTO ext4_and_dat
	IF "!CHOICE!"=="4" GOTO sfs_and_img
	IF "!CHOICE!"=="5" GOTO ext4_and_sparse
	IF "!CHOICE!"=="0" GOTO START
	SET CHOICE=AS
	GOTO images_menu
:extract_img
	if not exist "PLACE\extract_img" mkdir PLACE\extract_img
	echo PUT WHAT YOU WANT OF [cache.img/userdata.img/hidden.img]
	set wait=
	set /p wait=IN [PLACE\extract_img] THE PRESS ENTER OR [0=BACK]:
	if "!wait!"=="0" goto images_menu
	if not exist "PLACE\extract_img\cache.img" if not exist "PLACE\extract_img\hidden.img" if not exist "PLACE\extract_img\userdata.img" (
		echo THERE IS NO FILES SUPPORTED FOUND
		pause>nul
		goto images_menu
	)
	mkdir PLACE\extract_img\output
	if exist "PLACE\extract_img\cache.img" (
		echo EXTRACTING [cache.img] TO [PLACE\extract_img\output\cache]
		TOOLS\bin\imgextractor PLACE\extract_img\cache.img PLACE\extract_img\output\cache >nul
	)
	if exist "PLACE\extract_img\hidden.img" (
		echo EXTRACTING [hidden.img] TO [PLACE\extract_img\output\hidden]
		TOOLS\bin\imgextractor PLACE\extract_img\hidden.img PLACE\extract_img\output\hidden >nul
	)
	if exist "PLACE\extract_img\userdata.img" (
		for /f "delims=" %%a in ('tools\bin\imgextractor place\extract_img\userdata.img -s ^| !busybox! grep -cw "SPARSE EXT4"') do if "%%a"=="1" (
			echo CONVERTING SPARSE [userdata.img] TO EXT4 [userdata.img].....
			TOOLS\bin\simg2img PLACE\extract_img\userdata.img PLACE\extract_img\userdata.img.ext4>nul
			for /f "delims=" %%a in ('TOOLS\bin\imgextractor PLACE\extract_img\userdata.img.ext4 -s ^| !busybox! grep -cw "Found MOTO signature"') do if not "%%a"=="0" (
				echo REMOVING MOTOROLA HEADER SIGNATURE FROM [userdata.img]
				!busybox! dd if=PLACE/extract_img/userdata.img.ext4 of=PLACE/extract_img/userdata.ext4 ibs=131072 skip=1
			)
		)
		if not exist "PLACE\extract_img\userdata.img.ext4" if not exist "PLACE\extract_img\userdata.ext4" (
			echo EXTRACTING FILES FROM [userdata.img]
			TOOLS\bin\7za x -y "PLACE\extract_img\userdata.img" -o"PLACE\extract_img\output\userdata" >nul
		)
		if exist "PLACE\extract_img\userdata.img.ext4" if not exist "PLACE\extract_img\userdata.ext4" (
			echo EXTRACTING FILES FROM [userdata.img.ext4]
			TOOLS\bin\7za x -y "PLACE\extract_img\userdata.img.ext4" -o"PLACE\extract_img\output\userdata" >nul
		)
		if exist "PLACE\extract_img\userdata.ext4" (
			echo EXTRACTING FILES FROM [userdata.ext4]
			TOOLS\bin\7za x -y "PLACE\extract_img\userdata.ext4" -o"PLACE\extract_img\output\userdata" >nul
		)
	)
	TOOLS\bin\CECHO {0A}COMPLETED. PRESS ENTER TO CONTINUE{#}
	ECHO.
	PAUSE>NUL
	GOTO images_menu
:extract_twrp
	if not exist "PLACE\twrp_extract" mkdir PLACE\twrp_extract
	echo PUT BACKUPS FROM TWRP RECOVERY IN [PLACE\twrp_extract]
	echo LIKE [system.ext4.win*, data.ext4.win000*.....ETC]
	set /p wait=PRESS ENTER WHEN YOU READY OR [0=BACK]
	if "!wait!"=="0" goto images_menu
	if not exist "PLACE\twrp_extract\*.ext4.win*" (
		echo THERE IS NO FILES SUPPORTED FOUND
		pause>nul
		goto images_menu
	)
	for %%a in (PLACE\twrp_extract\*.ext4.win*) do (
		echo EXTRACTING FILES FROM [%%~na%%~xa]
		mkdir PLACE\twrp_extract\output\%%~na%%~xa
		!busybox! tar -xf %%a -C PLACE/twrp_extract/output/%%~na%%~xa >nul
	)
	TOOLS\bin\CECHO {0A}COMPLETED. PRESS ENTER TO CONTINUE{#}
	ECHO.
	PAUSE>NUL
	GOTO images_menu
:ext4_and_dat
	set ask=
	set /p ask=WHAT DO YOU TO CONVERT [1=DAT_TO_IMG 2=IMG_TO_DAT DEFAULT=BACK]:
	if not "!ask!"=="1" if not "!ask!"=="2" goto images_menu
	if "!ask!"=="1" (
		mkdir PLACE\dat_2_img
		echo PUT [system.new.dat] WITH [system.transfer.list] IN [PLACE\dat_2_img]
		set /p wait=PRESS ENTER WHEN YOU READY
		if not exist "PLACE\dat_2_img\system.transfer.list" if not exist "PLACE\dat_2_img\system.new.dat" (
			echo ERROR: NO FILES NEEDED FOUND
			pause>nul
			goto images_menu
		)
		if not exist "PLACE\dat_2_img\system.transfer.list" (
			echo ERROR: [system.transfer.list] NOT FOUND
			pause>nul
			goto images_menu
		)
		if not exist "PLACE\dat_2_img\system.new.dat" (
			echo ERROR: [system.new.dat] NOT FOUND
			pause>nul
			goto images_menu
		)
		echo CONVERTING [system.new.dat/system.transfer.list] TO EXT4 [system.img]
		mkdir PLACE\dat_2_img\output
		TOOLS\bin\sdat2img PLACE\dat_2_img\system.transfer.list PLACE\dat_2_img\system.new.dat PLACE\dat_2_img\output\system.img>nul
		for %%a in (PLACE\dat_2_img\output\system.img) do if "%%~za"=="0" del PLACE\dat_2_img\output\system.img
		if not exist "PLACE\dat_2_img\output\system.img" (
			TOOLS\bin\cecho {0C}AN ERROR HAPPENED DURING CONVERT PLEASE BE SURE FROM VALID FILES{#}
			echo.
			pause>nul
			goto images_menu
		)
		TOOLS\bin\CECHO {0A}COMPLETED. PRESS ENTER TO CONTINUE{#}
		ECHO.
		PAUSE>NUL
		GOTO images_menu
	)
	if "!ask!"=="2" (
		mkdir PLACE\img_2_dat
		echo PUT [system.img] IN [PLACE\img_2_dat]
		set /p wait=PRESS ENTER WHEN YOU READY
		if not exist "PLACE\img_2_dat\system.img" (
			echo ERROR: [system.img] NOT FOUND
			pause>nul
			goto images_menu
		)
		mkdir PLACE\img_2_dat\output
		for /f "delims=" %%a in ('tools\bin\imgextractor place\img_2_dat\system.img -s ^| !busybox! grep -cw "SPARSE EXT4"') do if not "%%a"=="0" (
			echo CONVERTING SPARSE [system.img] TO EXT4 [system.img]
			TOOLS\bin\simg2img PLACE/img_2_dat/system.img PLACE/img_2_dat/sys_ext4.img >nul
		)
		if exist "PLACE\img_2_dat\sys_ext4.img" (
			del PLACE\img_2_dat\system.img
			ren PLACE\img_2_dat\sys_ext4.img system.img
		)
		echo CONVERTING EXT4 [system.img] TO [system.new.dat/system.transfer.list]
		cd PLACE\img_2_dat
		..\..\TOOLS\bin\rimg2sdat >nul
		cd ..\..
		move PLACE\img_2_dat\system.new.dat PLACE\img_2_dat\output\system.new.dat >nul
		move PLACE\img_2_dat\system.transfer.list PLACE\img_2_dat\output\system.transfer.list >nul
		for %%a in (PLACE\img_2_dat\output\system.new.dat) do if "%%~za"=="0" del PLACE\img_2_dat\output\system*
		if not exist "PLACE\img_2_dat\output\system*" (
			TOOLS\bin\cecho {0C}AN ERROR HAPPENED DURING CONVERT PLEASE BE SURE FROM VALID FILES{#}
			echo.
			pause>nul
			goto images_menu
		)
		TOOLS\bin\CECHO {0A}COMPLETED. PRESS ENTER TO CONTINUE{#}
		ECHO.
		PAUSE>NUL
		GOTO images_menu
	)
:sfs_and_img
	set ask=
	set /p ask=WHAT DO YOU TO CONVERT [1=SFS_TO_IMG 2=IMG_TO_SFS DEFAULT=BACK]:
	if not "!ask!"=="1" if not "!ask!"=="2" goto images_menu
	if "!ask!"=="1" (
		mkdir PLACE\sfs_2_img
		echo PUT [system.sfs] IN [PLACE\sfs_2_img]
		set /p wait=PRESS ENTER WHEN YOU READY
		if not exist "PLACE\sfs_2_img\system.sfs" (
			echo ERROR: [system.sfs] NOT FOUND
			pause>nul
			goto images_menu
		)
		echo CONVERTING [system.sfs] TO EXT4 [system.img]
		tools\bin\7za x -y PLACE\sfs_2_img\system.sfs -oPLACE\sfs_2_img\output >nul
		for %%a in (PLACE\sfs_2_img\output\system.img) do if "%%~za"=="0" del PLACE\sfs_2_img\output\system.img
		if not exist "PLACE\sfs_2_img\output\system.img" (
			TOOLS\bin\cecho {0C}AN ERROR HAPPENED DURING CONVERT PLEASE BE SURE FROM VALID FILES{#}
			echo.
			pause>nul
			goto images_menu
		)
		TOOLS\bin\CECHO {0A}COMPLETED. PRESS ENTER TO CONTINUE{#}
		ECHO.
		PAUSE>NUL
		GOTO images_menu
	)
	if "!ask!"=="2" (
		mkdir PLACE\img_2_sfs
		echo PUT [system.img] IN [PLACE\img_2_sfs]
		set /p wait=PRESS ENTER WHEN YOU READY
		if not exist "PLACE\img_2_sfs\system.img" (
			echo ERROR: [system.img] NOT FOUND
			pause>nul
			goto images_menu
		)
		echo CONVERTING EXT4 [system.img] TO [system.sfs]
		mkdir PLACE\img_2_sfs\output
		mkdir PLACE\tmp_sfs
		move PLACE\img_2_sfs\system.img PLACE\tmp_sfs\system.img >nul
		tools\bin\mksquashfs PLACE/tmp_sfs PLACE/img_2_sfs/output/system.sfs >nul
		move PLACE\tmp_sfs\system.img PLACE\img_2_sfs\system.img >nul
		rmdir /s /q PLACE\tmp_sfs >nul
		for %%a in (PLACE\img_2_sfs\output\system.sfs) do if "%%~za"=="0" del PLACE\img_2_sfs\output\system.sfs
		if not exist "PLACE\img_2_sfs\output\system.sfs" (
			TOOLS\bin\cecho {0C}AN ERROR HAPPENED DURING CONVERT PLEASE BE SURE FROM VALID FILES{#}
			echo.
			pause>nul
			goto images_menu
		)
		TOOLS\bin\CECHO {0A}COMPLETED. PRESS ENTER TO CONTINUE{#}
		ECHO.
		PAUSE>NUL
		GOTO images_menu
	)
:ext4_and_sparse
	set ask=
	set /p ask=WHAT DO YOU TO CONVERT [1=SPARSE_TO_RAW 2=RAW_TO_SPARSE 3=SPARSE_32 DEFAULT=BACK]:
	if not "!ask!"=="1" if not "!ask!"=="2" if not "!ask!"=="3" goto images_menu
	if "!ask!"=="1" (
		mkdir PLACE\sparse_2_raw
		echo PUT SPARSE [system.img] IN [PLACE\sparse_2_raw]
		set /p wait=PRESS ENTER WHEN YOU READY
		if not exist "PLACE\sparse_2_raw\system.img" (
			echo ERROR: [system.img] NOT FOUND
			pause>nul
			goto images_menu
		)
		echo CONVERTING SPARSE [system.img] TO RAW EXT4 [system_raw.img]
		mkdir PLACE\sparse_2_raw\output
		tools\bin\simg2img PLACE/sparse_2_raw/system.img PLACE/sparse_2_raw/output/system_raw.img >nul
		for %%a in (PLACE\sparse_2_raw\output\system_raw.img) do if "%%~za"=="0" del PLACE\sparse_2_raw\output\system_raw.img
		if not exist "PLACE\sparse_2_raw\output\system_raw.img" (
			TOOLS\bin\cecho {0C}AN ERROR HAPPENED DURING CONVERT PLEASE BE SURE FROM VALID FILES{#}
			echo.
			pause>nul
			goto images_menu
		)
		TOOLS\bin\CECHO {0A}COMPLETED. PRESS ENTER TO CONTINUE{#}
		ECHO.
		PAUSE>NUL
		GOTO images_menu
	)
	if "!ask!"=="2" (
		mkdir PLACE\raw_2_sparse
		echo PUT RAW EXT4 [system.img] IN [PLACE\raw_2_sparse]
		set /p wait=PRESS ENTER WHEN YOU READY
		if not exist "PLACE\raw_2_sparse\system.img" (
			echo ERROR: [system.img] NOT FOUND
			pause>nul
			goto images_menu
		)
		echo CONVERTING RAW EXT4 [system.img] TO SPARSE [system_sparse.img]
		mkdir PLACE\raw_2_sparse\output
		tools\bin\ext2simg PLACE/raw_2_sparse/system.img PLACE/raw_2_sparse/output/system_sparse.img >nul
		for %%a in (PLACE\raw_2_sparse\output\system_sparse.img) do if "%%~za"=="0" del PLACE\raw_2_sparse\output\system_sparse.img
		if not exist "PLACE\raw_2_sparse\output\system_sparse.img" (
			TOOLS\bin\cecho {0C}AN ERROR HAPPENED DURING CONVERT PLEASE BE SURE FROM VALID FILES{#}
			echo.
			pause>nul
			goto images_menu
		)
		TOOLS\bin\CECHO {0A}COMPLETED. PRESS ENTER TO CONTINUE{#}
		ECHO.
		PAUSE>NUL
		GOTO images_menu
	)
	if "!ask!"=="3" (
		mkdir PLACE\sparse_32
		echo PUT RAW_EXT4/SPARSE [system.img] IN [PLACE\sparse_32]
		set /p wait=PRESS ENTER WHEN YOU READY
		if not exist "PLACE\sparse_32\system.img" (
			echo ERROR: [system.img] NOT FOUND
			pause>nul
			goto images_menu
		)
		mkdir PLACE\sparse_32\output
		for /f "delims=" %%a in ('tools\bin\imgextractor place\sparse_32\system.img -s ^| !busybox! grep -cw "SPARSE EXT4"') do if "%%a"=="0" (
			echo CONVERTING RAW EXT4 [system.img] TO SPARSE [system_sparse.img]
			tools\bin\ext2simg PLACE/sparse_32/system.img PLACE/sparse_32/system_sparse.img >nul
		) else ( ren PLACE\sprase_32\system.img system_sparse.img )
		echo CONVERTING SPARSE HEADER TO [32]
		mkdir PLACE\sparse_32\output
		tools\bin\sgs4ext4fs --bloat PLACE/sparse_32/system_sparse.img PLACE/sparse_32/output/system_32.img >nul
		if not exist "PLACE\sprase_32\system.img" ren PLACE\sparse_32\system_sparse.img system.img
		for %%a in (PLACE\sparse_32\output\system_32.img) do if "%%~za"=="0" del PLACE\sparse_32\output\system_32.img
		if not exist "PLACE\sparse_32\output\system_32.img" (
			TOOLS\bin\cecho {0C}AN ERROR HAPPENED DURING CONVERT PLEASE BE SURE FROM VALID FILES{#}
			echo.
			pause>nul
			goto images_menu
		)
		TOOLS\bin\CECHO {0A}COMPLETED. PRESS ENTER TO CONTINUE{#}
		ECHO.
		PAUSE>NUL
		GOTO images_menu
	)
:su_d_support
	if not exist "WORK\system\build.prop" (
		echo NO ROM FOUND TO ADD SU.D SUPPORT CREATE PROJECT FIRST
		pause>nul
		goto start
	)
	set line1=set_metadata_recursive("\/system\/xbin", "uid", 0, "gid", 2000, "dmode", 0755, "fmode", 0755, "capabilities", 0x0, "selabel", "u:object_r:system_file:s0
	set line2=set_metadata_recursive("\/system\/xbin", "uid", 0, "gid", 2000, "dmode", 0755, "fmode", 0755, "capabilities", "0x0", "selabel", "u:object_r:system_file:s0
	set line3=set_metadata_recursive("\/system\/su.d", "uid", 0, "gid", 0, "dmode", 0700, "fmode", 0700, "capabilities", 0x0, "selabel", "u:object_r:system_file:s0
	set line4=set_perm_recursive(0, 2000, 0755, 0755, "\/system\/xbin
	set line5=set_perm_recursive(0, 0, 0700, 0700, "\/system\/su.d
	if exist "WORK\system\su.d" (
		echo REMOVING SU.D SUPPORT
		!busybox! rm -rf WORK/system/su.d
		!busybox! sed -i '/^!line3!/d' !updater_script!
		goto completed
	)
	if "!su_installer_detect!"=="0" if not exist "WORK\system\xbin\daemonsu" (
		echo PLEASE ADD ROOT PERMISSIONS FIRST
		pause>nul
		goto start
	)
	echo SU.D SUPPORT LIKE INIT.D SUPPORT TO RUN SCRIPT DURING THE BOOT
	echo YOU CAN ADD YOUR SCRIPTS IN [WORK/system/su.d]
	set ask=
	set /p ask=DO YOU WANT TO CONTINUE [DEFAULT=YES 0=NO]:
	if "!ask!"=="0" goto start
	echo ADDING SU.D SUPPORT
	mkdir WORK\system\su.d
	!busybox! sed -i -e 's/!line1!");/!line1!");\n!line3!");/' !updater_script!
	!busybox! sed -i -e 's/!line2!");/!line2!");\n!line3!");/' !updater_script!
	!busybox! sed -i -e 's/!line4!");/!line4!");\n!line5!");/' !updater_script!
	goto completed
:addon_zip
	if not exist "WORK\system\build.prop" (
		echo NO ROM FOUND TO ADD ADD-ON ZIP CREATE PROJECT FIRST
		pause>nul
		goto start
	)
	if not exist "!updater_script!" (
		echo NO [updater-script] FOUND PLEASE BUILD INSTALLER FIRST
		pause>nul
		goto start
	)
	if not exist "WORK\META-INF\ADD-ONS" (
		echo THIS FEATURE FOR INSTALLER BUILT WITH THIS KITCHEN ONLY
		pause>nul
		goto start
	)
	echo THIS WILL ALLOW TO YOU TO INSTALL ZIP DURING ROM INSTALLATION
	echo IN RECOVERY LIKE: [Xposed, Busybox......ETC]
	set ask=
	set /p ask=DO YOU WANT TO CONTINUE [DEFAULT=YES 0=BACK]:
	if "!ask!"=="0" goto start
	cls
	echo.
	echo.
	mkdir WORK\zip_add_on
	echo PUT THE ZIP YOU WANT TO INSTALL WITH ROM IN [WORK\zip_add_on]
	echo AND DON'T MAKE SPACES IN THE ZIP NAME
	echo AND YOU CAN PUT UNLIMITED ZIPs
	echo IT IS USING THE SUPERSU CODES INSTALLATION IN [updater-script]
	echo SO IT MAYBE DOESN'T WORK WITH YOUR ZIP
	echo YOU SHOULD KNOW THAT BUILDING NEW INSTALLER WILL REMOVE THESE ZIPs
	set /p wait=PRESS ENTER WHEN YOU READY
	if not exist "WORK\zip_add_on\*.zip" (
		echo NO ZIP FILES FOUND IN THAT FOLDER
		pause>nul
		!busybox! rm -rf WORK/zip_add_on
		goto start
	)
	for %%a in (WORK\zip_add_on\*.zip) do (
		set name=%%~na%%~xa
		for /f "delims=" %%b in ('echo "!name!" ^| !busybox! sed "s/&/_/g"') do set name_fix=%%b
		set name_fix=!name_fix:"=!
		ren "%%a" "!name_fix!"
	)
	for %%a in (WORK/zip_add_on/*.zip) do !busybox! sed -i 's/#--CUSTOM SCRIPTS/#--CUSTOM SCRIPTS\nui_print("-- Installing: %%~na");\npackage_extract_dir("META-INF\/ADD-ONS\/%%~na", "\/tmp\/%%~na");\nrun_program("\/sbin\/busybox", "unzip", "\/tmp\/%%~na\/%%a", "META-INF\/com\/google\/android\/*", "-d", "\/tmp\/%%~na");\nrun_program("\/sbin\/busybox", "sh", "\/tmp\/%%~na\/META-INF\/com\/google\/android\/update-binary", "dummy", "1", "\/tmp\/%%~na\/%%a");\ndelete_recursive("\/tmp\/%%~na");/' !updater_script!
	for %%a in (WORK/zip_add_on/*.zip) do (
		echo ADDING [%%a] TO [WORK\META-INF\ADD-ONS\%%~na]
		call :start_move
	)
	!busybox! rm -rf WORK/zip_add_on
	goto completed
:start_move
	for %%a in (WORK/zip_add_on/*.zip) do (
		if exist "WORK\META-INF\ADD-ONS\%%~na" !busybox! rm -rf WORK/META-INF/ADD-ONS/%%~na
		mkdir WORK\META-INF\ADD-ONS\%%~na
		move WORK\zip_add_on\%%a WORK\META-INF\ADD-ONS\%%~na\%%a >nul
		TOOLS\bin\dos2unix -q !updater_script!>nul
		goto:eof
	)
:exiting
	exit

