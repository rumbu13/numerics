set PATH=C:\Program Files (x86)\Microsoft Visual Studio 14.0\VC\\bin;C:\Program Files (x86)\Microsoft Visual Studio 14.0\\Common7\IDE;C:\Program Files (x86)\Windows Kits\8.1\\bin;C:\D\dmd2\windows\bin;%PATH%
dmd -g -debug -w -wi -de -X -Xf"..\bin\testbench.json" -deps="..\bin\testbench.dep" -c -of"..\bin\testbench.obj" testbench\main.d module1.d
if errorlevel 1 goto reportError

set LIB="C:\D\dmd2\windows\bin\..\lib"
echo. > D:\git\numerics\src\..\bin\testbench.build.lnkarg
echo "..\bin\testbench.obj","..\bin\testbench.exe","..\bin\testbench.map",user32.lib+ >> D:\git\numerics\src\..\bin\testbench.build.lnkarg
echo kernel32.lib/NOMAP/CO/NOI/DELEXE >> D:\git\numerics\src\..\bin\testbench.build.lnkarg

"C:\Program Files (x86)\VisualD\pipedmd.exe" -deps ..\bin\testbench.lnkdep C:\D\dmd2\windows\bin\link.exe @D:\git\numerics\src\..\bin\testbench.build.lnkarg
if errorlevel 1 goto reportError
if not exist "..\bin\testbench.exe" (echo "..\bin\testbench.exe" not created! && goto reportError)

goto noError

:reportError
echo Building ..\bin\testbench.exe failed!

:noError
