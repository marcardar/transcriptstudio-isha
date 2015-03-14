## Steps for installing ts4isha on Linux (Ubuntu) ##
### Prerequisites ###
  * eXist 1.2.6 (jar file) http://exist.sourceforge.net/download.html#N10170
  * java (jdk 6) http://java.sun.com/javase/downloads/index.jsp
  * flex sdk 3.3 http://www.adobe.com/products/flex/flexdownloads/
  * mozilla firefox 3.0 http://www.mozilla.com/en-US/firefox/firefox.html
  * adobe flash player 10 (debian package - firefox plugin) http://get.adobe.com/flashplayer/

### System Setup ###
Install Firefox and the flash player plugin (if not already installed on your system).

_NOTE: We have been having problems using the flash plugin with Firefox on linux (CentOS), where the screen sometimes just goes blank. We have worked around this by using the standalone version of the flash player - which does not have this problem. We are yet to test it on Windows or other browsers._

Install java (the default installation location is /usr/lib/jvm/java-6-sun).

Install eXist by executing the command "sudo java -jar eXist-setup-1.2.6..." from within the directory containing the eXist jar file. (We recommend you install to /opt/exist). Ensure that you provide a non-empty admin password.

Unpack the flex sdk to a suitable location. (We recommend /opt/flex\_sdk).

### Define system environment variables ###
Edit the /etc/environment file to include the following lines:

  * EXIST\_HOME="/opt/exist"
  * JAVA\_HOME="/usr/lib/jvm/java-6-sun"
  * FLEX\_HOME="/opt/flex\_sdk"

(Paths may be different for different installations)

Secondly, run "sudo visudo" to edit your /etc/sudoers file. Add the following lines:

  * Defaults        env\_keep+=JAVA\_HOME
  * Defaults        env\_keep+=EXIST\_HOME
  * Defaults        env\_keep+=FLEX\_HOME

(We have it right under the "Defaults env\_reset" line).

### Check out source code from svn ###
Execute the following command in the terminal to get the latest version of the code:

svn checkout http://transcriptstudio4isha.googlecode.com/svn/trunk/ ts4isha-trunk

(or get the most recent stable tag)

(If you don't have subversion installed, you can get it by typing "sudo apt-get install svn" in the terminal).

### Create database users ###

Using the java web start db client (accessible from http://localhost:8080/exist) log in to the database and create a new user. You must also create 2 new groups:
  * markup
  * text
Any user using the flex app must be a member of the **markup** group in order to be allowed to mark up text, and be a member of the **text** group in order to be able to edit transcript text

### Build the application ###
Open the ts4isha-trunk folder and run the build.sh script as root ("sudo ./build.sh"). (Note that you may have to make it executable by running the following command: "sudo chmod +x build.sh").

After the build completes successfully, restart the database by executing the shutdown.sh script in the $EXIST\_HOME/bin directory, and then the start.sh script.

(Note that you may need to reload the /etc/environment file, if the environment variables are not being recognized. You can do this by typing "sudo source /etc/environment" in the terminal)

### Run the application ###
Open Firefox and enter "http://localhost:8080/exist/ts4isha/TranscriptStudio.swf" to run the Transcript Studio Flex Application, and enter your eXist admin username and password at the prompt.

To access the search html/xquery application go to the Tools menu and select "HTML Search Interface", which will open a new tab in your browser to display the page.