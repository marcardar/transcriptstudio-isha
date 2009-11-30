package org.ishafoundation.ts4isha.xquery.modules;

import org.exist.xquery.AbstractInternalModule;
import org.exist.xquery.FunctionDef;
import org.exist.xquery.XQueryContext;
import org.exist.util.SingleInstanceConfiguration;
import org.exist.security.User;

import java.io.File;

public class TranscriptStudioModule extends AbstractInternalModule
{
	public final static String NAMESPACE_URI = "http://ishafoundation.org/ts4isha/xquery";
	
	public final static String PREFIX = "ts4isha";
	public final static String INCLUSION_DATE = "2009-11-29";
    	public final static String RELEASED_IN_VERSION = "eXist-1.4";
	
	private final static FunctionDef[] functions = {
		new FunctionDef( ImportFileNameList.signatures[0], 	ImportFileNameList.class ),
		new FunctionDef( ImportFileRead.signatures[0], 	ImportFileRead.class ),
		new FunctionDef( CreateDocxFile.signatures[0], 	CreateDocxFile.class ),
	};
	
	public final static File getImportDir() {
		return new File(getTranscriptDir(), "import");
	}
	
	public final static File getExportDir() {
		return new File(getTranscriptDir(), "export");
	}
	
	public final static File getTranscriptDir() {
		return new File(SingleInstanceConfiguration.getWebappHome(), "ts4isha");
	}
	
	public TranscriptStudioModule() 
	{
		super( functions );
	}
	

	public String getNamespaceURI() 
	{
		return( NAMESPACE_URI );
	}
	

	public String getDefaultPrefix() {
		return( PREFIX );
	}
	

	public String getDescription() 
	{
		return( "A module for performing various Transcript Studio functions." );
	}

	public String getReleaseVersion() 
	{
		return( RELEASED_IN_VERSION );
	}
		
	
	/**
	 * Resets the Module Context 
	 * 
	 * @param xqueryContext The XQueryContext
	 */
	
	public void reset( XQueryContext xqueryContext )
	{
		super.reset( xqueryContext );
	}

	static void checkSuperUser(User user) {
		if (!user.hasDbaRole()) {
			throw new RuntimeException("User '" + user.getName() + "' is not a super user so cannot call this function");
		}
	}
}
