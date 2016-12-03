set PATH=C:\Program Files (x86)\Microsoft Visual Studio 14.0\VC\\bin;C:\Program Files (x86)\Microsoft Visual Studio 14.0\\Common7\IDE;C:\Program Files (x86)\Windows Kits\8.1\\bin;C:\D\dmd2\windows\bin;%PATH%

echo numerics\internal\arrays.d >..\bin\test.build.rsp
echo numerics\internal\chars.d >>..\bin\test.build.rsp
echo test\data.d >>..\bin\test.build.rsp
echo numerics\fixed.d >>..\bin\test.build.rsp
echo numerics\internal\floats.d >>..\bin\test.build.rsp
echo numerics\internal\integrals.d >>..\bin\test.build.rsp
echo test\main.d >>..\bin\test.build.rsp
echo numerics\internal\strings.d >>..\bin\test.build.rsp

dmd -g -debug -w -wi -de -X -Xf"..\bin\test.json" -deps="..\bin\test.dep" -c -of"..\bin\test.obj" @..\bin\test.build.rsp -unittest
if errorlevel 1 goto reportError

set LIB="C:\D\dmd2\windows\bin\..\lib"
echo. > D:\git\numerics\src\..\bin\test.build.lnkarg
echo "..\bin\test.obj","..\bin\test.exe","..\bin\test.map",user32.lib+ >> D:\git\numerics\src\..\bin\test.build.lnkarg
echo kernel32.lib/NOMAP/CO/NOI/DELEXE >> D:\git\numerics\src\..\bin\test.build.lnkarg

"C:\Program Files (x86)\VisualD\pipedmd.exe" -deps ..\bin\test.lnkdep C:\D\dmd2\windows\bin\link.exe @D:\git\numerics\src\..\bin\test.build.lnkarg
if errorlevel 1 goto reportError
if not exist "..\bin\test.exe" (echo "..\bin\test.exe" not created! && goto reportError)

goto noError

:reportError
echo Building ..\bin\test.exe failed!

:noError
