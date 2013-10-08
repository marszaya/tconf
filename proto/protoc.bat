set desdir=..\
set cppdir=..\
set srcdir=.
set tooldir=..\tool\

for %%i in (%srcdir%\*.proto) do @protoc.exe --plugin=protoc-gen-as3="protoc-gen-as3.bat" --proto_path=%srcdir% --as3_out=%desdir% %srcdir%/%%i
for %%i in (%srcdir%\*.proto) do @protoc.exe --proto_path=%srcdir% --cpp_out=%cppdir% %srcdir%/%%i
copy %desdir%\*.as %tooldir%