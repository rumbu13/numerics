set PATH=C:\Program Files (x86)\Microsoft Visual Studio 14.0\VC\\bin;C:\Program Files (x86)\Microsoft Visual Studio 14.0\\Common7\IDE;C:\Program Files (x86)\Windows Kits\8.1\\bin;C:\D\dmd2\windows\bin;%PATH%

echo numerics\internal\arrays.d >..\lib\numerics.build.rsp
echo numerics\internal\chars.d >>..\lib\numerics.build.rsp
echo numerics\internal\floats.d >>..\lib\numerics.build.rsp
echo numerics\internal\integrals.d >>..\lib\numerics.build.rsp
echo numerics\internal\strings.d >>..\lib\numerics.build.rsp
echo numerics\fixed.d >>..\lib\numerics.build.rsp

"C:\Program Files (x86)\VisualD\pipedmd.exe" dmd -g -debug -w -wi -lib -de -D -Dd..\doc -X -Xf"..\lib\numerics32.json" -deps="..\lib\numerics.dep" -of"..\lib\numerics32.lib" -map "..\lib\numerics.map" -L/NOMAP @..\lib\numerics.build.rsp
if errorlevel 1 goto reportError
if not exist "..\lib\numerics32.lib" (echo "..\lib\numerics32.lib" not created! && goto reportError)

goto noError

:reportError
echo Building ..\lib\numerics32.lib failed!

:noError
