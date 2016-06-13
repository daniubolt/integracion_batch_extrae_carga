#INFO: ejecutar un script como aplicacion web
set EMRT_BIN=%~dp0
set PORT=%1
shift
set SCRIPT=%1
shift

set NUESTRO_JAVA=\opt\jdk17\bin\java
if EXISTS %NUESTRO_JAVA% (
	set JAVA=%NUESTRO_JAVA%	
) ELSE (
	set JAVA=java
)	

%JAVA% -Dlibrt.webapp=%SCRIPT% -DHttpsKeysDir=%EMRT_BIN%etc -DHttpsPort=%PORT% -Dfile.encoding=UTF-8 -jar %EMRT_BIN%jetty-runner-8.jar  --config %EMRT_BIN%etc\jetty8.xml --lib %EMRT_BIN% %EMRT_BIN%emrt.jar
