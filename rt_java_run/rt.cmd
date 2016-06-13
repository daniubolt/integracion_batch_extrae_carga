#INFO: ejecutar un script como aplicacion web
set EMRT_BIN=%~dp0

set NUESTRO_JAVA=\opt\jdk17\bin\java
if EXISTS %NUESTRO_JAVA% (
	set JAVA=%NUESTRO_JAVA%	
) ELSE (
	set JAVA=java
)	

%JAVA% -jar %EMRT_BIN%emrt.jar %1 %2 %3 %4 %5 %6 %7 %8 %9
