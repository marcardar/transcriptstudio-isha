package org.ishafoundation.archives.transcript.xquery.modules;

import java.io.IOException;
import java.io.*;
import java.util.zip.*;
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
		TranscriptStudioModule.checkSuperUser(context.getUser());

		String arg = args[0].itemAt(0).getStringValue();
		String filename = arg + ".docx";
		
		File f = new File(TranscriptStudioModule.getImportDir(), filename);
		
		String documentString = extractDocumentFromDocxFile(f);
		
		return( new StringValue( documentString ) );
	}
	
	private String extractDocumentFromDocxFile(File docxFile) throws XPathException {
		FileInputStream fis = null;
		ZipInputStream zis = null;
		ByteArrayOutputStream baos = null;
		BufferedOutputStream dest = null;
		try {
			fis = new FileInputStream(docxFile);
			zis = new ZipInputStream(new BufferedInputStream(fis));

			int BUFFER = 2048;
			baos = new ByteArrayOutputStream(BUFFER);
			dest = new BufferedOutputStream(baos, BUFFER);
			
			ZipEntry entry;
			while((entry = zis.getNextEntry()) != null) {
				if (entry.getName().equals("word/document.xml")) {
		            int count;
		            byte data[] = new byte[BUFFER];
					while ((count = zis.read(data, 0, BUFFER)) != -1) {
						dest.write(data, 0, count);
					}
					dest.flush();
					// don't want to extract more than one file
					return new String(baos.toByteArray());
				}
			}
		}
		catch (Exception e) {
			throw( new XPathException( getASTNode(), e.getMessage() ) );
		}
		finally {
			try {
				if (dest != null) {
					dest.close();
				}
				if (zis != null) {
					zis.close();
				}
				if (fis != null) {
					fis.close();
				}
			}
			catch (IOException e) {
				e.printStackTrace();
				throw new RuntimeException("Could not close stream");
			}
		}
		throw new XPathException("Could not find document.xml in specified docx file: " + docxFile);
	}
}
