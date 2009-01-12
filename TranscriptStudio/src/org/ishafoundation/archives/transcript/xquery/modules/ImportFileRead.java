package org.ishafoundation.archives.transcript.xquery.modules;

import java.io.IOException;
import java.io.File;
import java.io.InputStreamReader;
import java.io.StringWriter;
import java.net.MalformedURLException;
import java.net.URL;

import org.exist.dom.QName;

import org.exist.xquery.BasicFunction;
import org.exist.xquery.Cardinality;
import org.exist.xquery.FunctionSignature;
import org.exist.xquery.XPathException;
import org.exist.xquery.XQueryContext;
import org.exist.xquery.value.Sequence;
import org.exist.xquery.value.SequenceType;
import org.exist.xquery.value.StringValue;
import org.exist.xquery.value.Type;

public class ImportFileRead extends BasicFunction {
	
	public final static FunctionSignature signatures[] = {
		new FunctionSignature(
			new QName( "import-file-read", TranscriptStudioModule.NAMESPACE_URI, TranscriptStudioModule.PREFIX ),
			"Read content of import file. $a is a string representing the import file (not including extension).",
			new SequenceType[] {				
				new SequenceType( Type.STRING, Cardinality.EXACTLY_ONE )
				},				
			new SequenceType( Type.STRING, Cardinality.ZERO_OR_ONE ) ),
		};
	
	/**
	 * @param context
	 * @param signature
	 */
	public ImportFileRead( XQueryContext context, FunctionSignature signature ) 
	{
		super( context, signature );
	}
	
	/* (non-Javadoc)
	 * @see org.exist.xquery.BasicFunction#eval(org.exist.xquery.value.Sequence[], org.exist.xquery.value.Sequence)
	 */
	public Sequence eval( Sequence[] args, Sequence contextSequence ) throws XPathException 
	{
		String arg = args[0].itemAt(0).getStringValue();
		String filename = arg + ".xml";
		
		File f = new File(TranscriptStudioModule.getImportDir(), filename);
		
		StringWriter sw = null;
		InputStreamReader reader = null;
		
		try {
			URL url = f.toURL();
			
			reader = new InputStreamReader( url.openStream() );
			
			sw = new StringWriter();
			char[] buf = new char[1024];
			int len;
			while( ( len = reader.read( buf ) ) > 0 ) {
				sw.write( buf, 0, len) ;
			}
		} 		
		catch( MalformedURLException e ) {
			throw( new XPathException( getASTNode(), e.getMessage() ) );	
		} 
		catch( IOException e ) {
			throw( new XPathException( getASTNode(), e.getMessage() ) );	
		}		
		finally {
			try {
				if (reader != null) {
					reader.close();
				}
				if (sw != null) {
					sw.close();
				}
			}
			catch (IOException e) {
				e.printStackTrace();
			}
		}
		
		//TODO : return an *Item* built with sw.toString()
		
		return( new StringValue( sw.toString() ) );
	}
}
