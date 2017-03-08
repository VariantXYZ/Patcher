copy /Y ..\PatcherLib\Debug\PatcherLib.dll .
if errorlevel 1 goto reportError
set PATH=C:\DLang\ldc2-1.1.0-beta6-win64-msvc\\bin;C:\Program Files (x86)\Microsoft Visual Studio 14.0\VC\\bin;C:\Program Files (x86)\Microsoft Visual Studio 14.0\\Common7\IDE;C:\Program Files (x86)\Windows Kits\8.1\\bin;%PATH%
set LIB=C:\Program Files (x86)\Microsoft Visual Studio 14.0\VC\\lib;C:\Program Files (x86)\Windows Kits\10\Lib\10.0.14393.0\ucrt\x86;C:\Program Files (x86)\Windows Kits\8.1\Lib\winv6.3\um\x86;..\PatcherLib\Debug\
set WindowsSdkDir=C:\Program Files (x86)\Windows Kits\8.1\
set VCINSTALLDIR=C:\Program Files (x86)\Microsoft Visual Studio 14.0\VC\
set VSINSTALLDIR=C:\Program Files (x86)\Microsoft Visual Studio 14.0\
"C:\Program Files (x86)\VisualD\pipedmd.exe" ldc2 -m32 -gc -O -d-debug -X -Xf="Debug LDC Win32\PatcherLibTestD.json" -I=..\PatcherLib -deps="Debug LDC Win32\PatcherLibTestD.dep" -of="Debug LDC Win32\PatcherLibTestD.exe" -L/MAP:"Debug LDC Win32\PatcherLibTestD.map" PatcherLib.lib main.d -betterC -g 
if errorlevel 1 goto reportError
if not exist "Debug LDC Win32\PatcherLibTestD.exe" (echo "Debug LDC Win32\PatcherLibTestD.exe" not created! && goto reportError)

goto noError

:reportError
echo Building Debug LDC Win32\PatcherLibTestD.exe failed!

:noError
