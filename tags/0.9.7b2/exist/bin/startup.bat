@echo off

rem $Id: startup.bat 8489 2009-01-07 20:12:43Z dizzzz $
rem
rem In addition to the other parameter options for the Jetty container 
rem pass -j or --jmx to enable JMX agent.  The port for it can be specified 
rem with optional port number e.g. -j1099 or --jmx=1099.
rem

set JMX_ENABLED=0
set JMX_PORT=1099
set JAVA_ARGS=

if not "%JAVA_HOME%" == "" goto gotJavaHome

rem will be set by the installer
set JAVA_HOME=C:\Program Files\Java\jdk1.6.0_11

:gotJavaHome
if not "%EXIST_HOME%" == "" goto gotExistHome

rem will be set by the installer
set EXIST_HOME=C:\Program Files\eXist

:gotExistHome
set JAVA_ENDORSED_DIRS="%EXIST_HOME%"\lib\endorsed
set JAVA_OPTS="-Xms128m -Xmx512m -Dfile.encoding=UTF-8 -Djava.endorsed.dirs=%JAVA_ENDORSED_DIRS%" 

set BATCH.D="%EXIST_HOME%\bin\batch.d"
call %BATCH.D%\get_opts.bat %*
call %BATCH.D%\check_jmx_status.bat

"%JAVA_HOME%\bin\java" "%JAVA_OPTS%"  -Dexist.home="%EXIST_HOME%" -Dorg.mortbay.http.HttpRequest.maxFormContentSize=1048576 -jar "%EXIST_HOME%\start.jar" jetty %JAVA_ARGS%
:eof

