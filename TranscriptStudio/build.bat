@echo off

rem will be set by the installer
if not "%EXIST_HOME%" == "" goto gotExistHome
set EXIST_HOME=C:\Program Files\eXist

:gotExistHome
if not "%JAVA_HOME%" == "" goto gotJavaHome
set JAVA_HOME=C:\Program Files\Java\jdk1.6.0_11

:gotJavaHome
if not "%FLEX_HOME%" == "" goto gotFlexHome
set FLEX_HOME=C:\Program Files\Adobe\Flex Builder 3\sdks\3.3.0

:gotFlexHome
set ANT_HOME=%EXIST_HOME%\tools\ant
set _LIBJARS=%CLASSPATH%;%ANT_HOME%\lib\ant-launcher.jar;%ANT_HOME%\lib\junit-4.4.jar;%JAVA_HOME%\lib\tools.jar

set JAVA_ENDORSED_DIRS=%EXIST_HOME%\lib\endorsed
set JAVA_OPTS=-Xms64M -Xmx512M -Djava.endorsed.dirs="%JAVA_ENDORSED_DIRS%" -DFLEX_HOME="%FLEX_HOME%" -Dant.home="%ANT_HOME%" -Dexist.home="%EXIST_HOME%"

echo Transcript Studio for Isha Foundation Build
echo -------------------------------------------
echo JAVA_HOME=%JAVA_HOME%
echo _LIBJARS=%_LIBJARS%

echo Starting Ant...
echo

"%JAVA_HOME%\bin\java" %JAVA_OPTS% -classpath "%_LIBJARS%" org.apache.tools.ant.launch.Launcher %1 %2 %3 %4 %5 %6 %7 %8 %9

pause