package org.ishafoundation.ts4isha.xquery.modules;

import java.io.IOException;
import java.io.*;
import java.util.zip.*;
import java.net.MalformedURLException;
import java.net.URISyntaxException;
import java.net.URL;
import java.util.Properties;

import javax.xml.transform.OutputKeys;

import org.exist.storage.serializers.Serializer;
import org.exist.util.serializer.SAXSerializer;
import org.exist.util.serializer.SerializerPool;
import org.exist.xquery.Option;
import org.exist.xquery.value.BooleanValue;
import org.exist.dom.QName;

import org.exist.xquery.BasicFunction;
import org.exist.xquery.Cardinality;
import org.exist.xquery.FunctionSignature;
import org.exist.xquery.XPathException;
import org.exist.xquery.XQueryContext;
import org.exist.xquery.value.Base64Binary;
import org.exist.xquery.value.Sequence;
import org.exist.xquery.value.SequenceType;
import org.exist.xquery.value.NodeValue;
import org.exist.xquery.value.StringValue;
import org.exist.xquery.value.Type;

import org.xml.sax.SAXException;

public class CreateDocxFile extends BasicFunction {

	private final static String DOCUMENT_XML_ENTRY_NAME = "word/document.xml";
	private final static File TEMPLATE_DOCX_FILE = new File(TranscriptStudioModule.getTranscriptDir(), "template.docx");

	
	public final static FunctionSignature signatures[] = {
		new FunctionSignature(
			new QName( "create-docx", TranscriptStudioModule.NAMESPACE_URI, TranscriptStudioModule.PREFIX ),
			"Create docx file. $a is a string representing the import file (not including extension).",
			new SequenceType[] {				
				new SequenceType( Type.NODE, Cardinality.EXACTLY_ONE )
				},				
			new SequenceType( Type.BASE64_BINARY, Cardinality.ZERO_OR_ONE ) )
		};
	
	/**
	 * @param context
	 * @param signature
	 */
	public CreateDocxFile( XQueryContext context, FunctionSignature signature ) 
	{
		super( context, signature );
	}
	
	/* (non-Javadoc)
	 * @see org.exist.xquery.BasicFunction#eval(org.exist.xquery.value.Sequence[], org.exist.xquery.value.Sequence)
	 */
	public Sequence eval( Sequence[] args, Sequence contextSequence ) throws XPathException 
	{
		NodeValue nodeValue = (NodeValue) args[0].itemAt(0);
		
		try {
			ByteArrayOutputStream xmlBaos = new ByteArrayOutputStream();
			//do the serialization
			serialize(nodeValue, xmlBaos) ;
			byte[] xmlByteArray = xmlBaos.toByteArray();
			
			byte[] docxByteArray = createDocx(xmlByteArray);
			return( new Base64Binary( docxByteArray ) );
		} 		
		catch( IOException e ) {
			throw( new XPathException( this, e.getMessage() ) );	
		}

	}

	private void serialize( NodeValue nodeValue, OutputStream os ) throws XPathException
	{
		Properties outputProperties = new Properties();
		// serialize the node set
		SAXSerializer sax = (SAXSerializer)SerializerPool.getInstance().borrowObject( SAXSerializer.class );
		try {
			String encoding = outputProperties.getProperty( OutputKeys.ENCODING, "UTF-8" );
			Writer writer = new OutputStreamWriter( os, encoding );
			
			sax.setOutput( writer, outputProperties );
			Serializer serializer = context.getBroker().getSerializer();
			serializer.reset();
			serializer.setProperties( outputProperties );
			serializer.setReceiver( sax );
			
			sax.startDocument();
			
			serializer.toSAX( nodeValue );	
			
			sax.endDocument();
			writer.close();
		}
		catch( SAXException e ) {
			throw( new XPathException( this, "A problem ocurred while serializing the node set: " + e.getMessage(), e ) );
		}
		catch ( IOException e ) {
			throw( new XPathException( this, "A problem ocurred while serializing the node set: " + e.getMessage(), e ) );
		}
		finally {
			SerializerPool.getInstance().returnObject( sax );
		}
	}

	public static byte[] createDocx(byte[] xmlByteArray) throws IOException {
		ByteArrayInputStream xmlBais = new ByteArrayInputStream(xmlByteArray);;		
		ByteArrayOutputStream docxBaos = new ByteArrayOutputStream();

		ZipInputStream zin = new ZipInputStream(new FileInputStream(TEMPLATE_DOCX_FILE));
		ZipOutputStream out = new ZipOutputStream(docxBaos);
		
		byte[] buf = new byte[1024];
		
		ZipEntry entry = zin.getNextEntry();
		while (entry != null) {
			String name = entry.getName();
			// Add ZIP entry to output stream.
			out.putNextEntry(new ZipEntry(name));
			// Transfer bytes from the ZIP file to the output file
			int len;
			while ((len = zin.read(buf)) > 0) {
				out.write(buf, 0, len);
			}
			entry = zin.getNextEntry();
		}
		// Close the streams		
		zin.close();
		out.putNextEntry(new ZipEntry(DOCUMENT_XML_ENTRY_NAME));
		// Transfer bytes from the file to the ZIP file
		int len;
		while ((len = xmlBais.read(buf)) > 0) {
			out.write(buf, 0, len);
		}
		// Complete the entry
		out.closeEntry();
		// Complete the ZIP file
		out.close();
		return docxBaos.toByteArray();
	}
}
