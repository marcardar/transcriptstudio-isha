exist-modules.jar is the same as in the distribution except in addition it has the transcript studio xquery module classes.

This can be built using the build.bat provided by eXist:

1. First copy the Transcript Studio xquery module java source files from:

/src/org/ishafoundation/archives/transcript/xquery/modules/*.java

to:

%EXIST_HOME%/extensions/modules/src/.....

then run:

%EXIST_HOME%/build.bat extension-modules