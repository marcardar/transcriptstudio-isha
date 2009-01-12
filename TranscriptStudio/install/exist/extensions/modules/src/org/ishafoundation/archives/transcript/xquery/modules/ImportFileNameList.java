package org.ishafoundation.archives.transcript.xquery.modules;

import java.io.File;

import org.exist.dom.QName;
import org.exist.memtree.MemTreeBuilder;
import org.exist.util.DirectoryScanner;
import org.exist.xquery.BasicFunction;
import org.exist.xquery.Cardinality;
import org.exist.xquery.FunctionSignature;
import org.exist.xquery.XPathException;
import org.exist.xquery.XQueryContext;
import org.exist.xquery.value.NodeValue;
import org.exist.xquery.value.Sequence;
import org.exist.xquery.value.SequenceIterator;
import org.exist.xquery.value.SequenceType;
import org.exist.xquery.value.Type;
import org.exist.util.SingleInstanceConfiguration;

/**
 * Enumerate a list of files found in import directory.
 * 
 * @author Mark Carter
 * @serial 2009-01-10
 * @version 1.0
 */
public class ImportFileNameList extends BasicFunction
{	
	public final static FunctionSignature[] signatures =
	{
		new FunctionSignature(
			new QName( "import-file-name-list", TranscriptStudioModule.NAMESPACE_URI, TranscriptStudioModule.PREFIX ),
			"List all import files found in import directory. Files are located in the server's " +
			"file system. " +
			"The function returns a node fragment that shows all matching filenames",
			new SequenceType[]{},
			new SequenceType( Type.NODE, Cardinality.ZERO_OR_ONE )
			)
		};
	
	
	/**
	 * ImportListFunction Constructor
	 * 
	 * @param context	The Context of the calling XQuery
	 */
	
	public ImportFileNameList( XQueryContext context, FunctionSignature signature )
	{
		super( context, signature );
	}
	
	
	/**
	 * evaluate the call to the XQuery execute() function,
	 * it is really the main entry point of this class
	 * 
	 * @param args		arguments from the execute() function call
	 * @param contextSequence	the Context Sequence to operate on (not used here internally!)
	 * @return		A node representing the SQL result set
	 * 
	 * @see org.exist.xquery.BasicFunction#eval(org.exist.xquery.value.Sequence[], org.exist.xquery.value.Sequence)
	 */
	
	public Sequence eval( Sequence[] args, Sequence contextSequence ) throws XPathException
	{
		File 		baseDir 	= TranscriptStudioModule.getImportDir();
		
		LOG.debug( "Listing matching files in directory: " + baseDir );
		
		Sequence    xmlResponse     = null;
		
		MemTreeBuilder builder = context.getDocumentBuilder();
		
		builder.startDocument();
		builder.startElement( new QName( "list", TranscriptStudioModule.NAMESPACE_URI, TranscriptStudioModule.PREFIX ), null );
		builder.addAttribute( new QName( "directory", null, null ), baseDir.toString() );
		
		String pattern 	= "*.xml";
		File[] files 	= DirectoryScanner.scanDir( baseDir, pattern );
		String relDir 	= null;
		
		LOG.debug( "Found: " + files.length );
		
		for( int j = 0; j < files.length; j++ ) {
			LOG.debug( "Found: " + files[j].getAbsolutePath() );
			
			String relPath = files[j].toString().substring( baseDir.toString().length() + 1 );
			
			int p = relPath.lastIndexOf( File.separatorChar );
			
			if( p >= 0 ) {
				relDir = relPath.substring( 0, p );
				relDir = relDir.replace( File.separatorChar, '/' );
			}
			
			builder.startElement( new QName( "file", TranscriptStudioModule.NAMESPACE_URI, TranscriptStudioModule.PREFIX ), null );
			
			String filename = files[j].getName();
			int extensionIndex = filename.lastIndexOf(".");
			String filenameWithoutExtension = filename.substring(0, extensionIndex);
			
			builder.addAttribute( new QName( "name", null, null ), filenameWithoutExtension );
			
			if( relDir != null && relDir.length() > 0 ) {
				builder.addAttribute( new QName( "subdir", null, null ), relDir );
			}
			
			builder.endElement();
			
		}
		
		builder.endElement();
		
		xmlResponse = (NodeValue)builder.getDocument().getDocumentElement();
		
		return( xmlResponse );
	}
	
}
