# Project Overview and Requirements #

This application is being developed for Isha Foundation with the primary aim of establishing a system for categorizing by topic a large collection of over 2000 (and growing) transcripts of Sadhguru's discourses.

After an initial period of research into existing automated document categorization applications, it was decided that a new application needed to be developed specifically for this purpose. This was primarily because the reviewed applications did not provide any functionality to deal with a number of different topics appearing in one document (sub-document level categorization), but only dealt with categorizing documents as a whole. For our purposes this was not sufficient, since Sadhguru often answers questions on a wide range of topics within a single discourse. A more granular functionality was required, which would allow us to select portions of a document and categorize them independently of each other.

As well as categorizing topics, it was also decided to allow the user to capture and categorize other items of interest such as anecdotes and quotations, and also to allow the possibility of adding new category types if required later.

## High Level Requirements ##

The following seven additional high level requirements were identified that the application should satisfy:

  1. The topic categorization process must be easy to use, so that a 'non-technical' person can easily do this task. (i.e. somebody who can use MS Office at a basic level - and who should not need to have any programming skills);

> 2. The application must be able to deal with transcripts that are stored as Microsoft Word documents (since all of the Isha Archives' transcribed material is currently stored in this format);

> 3. The categorized material should be easily accessible to non-technical users, preferably made available over a local network via a web-based application;

> 4. Both the topic categorization process and the categorized material access must be available to multiple concurrent users;

> 5. The data should be stored in an 'open format', in such a manner that it should be easily exportable to another database should such a need arise in the future;

> 6. The transcripts and the categorized material should not exist independently, so that synchronization issues are avoided. (i.e. instead of copying the text content of a topic and storing it separately from the original transcript, we would like to reference the original transcript using some kind of positional markers. This means that if an original transcript is amended for any reason, those amendments will automatically be reflected in any categorized material from the transcript);

> 7. The solution should be modular and easily extensible so that subsequent phases of development could add further functionality without the need to redevelop the initial phases.


After an unsatisfactory attempt was made at implementing a solution using traditional relational database methods, and after several months of further research, it was decided to go for an XML-based approach, primarily to satisfy requirements 5, 6, and 7. (The main inspiration behind this approach came from the Women Writers Project, funded by Brown University, an electronic-text encoding project based on SGML).

## The XML Data Model ##

All the text content and user specified metadata will be stored in XML format in an XML database. XML was chosen as the desired data storage format for extensibility, ease of querying and expected longevity and widespread usage of the format. We have chosen the open source database eXist as our database.

In order for us to start working with a text document we require that it is first converted into an XML document, which corresponds to the transcript XSD. The main thing that we are doing here is to convert each paragraph of text into a "segment" xml element. We will use "content" sub-elements to contain contiguous spans of text within a paragraph. We are working with transcripts stored as Microsoft Word documents. With the new Microsoft Open Office XML standard introduced with Microsoft Office 2007, Word 2007 (docx) documents are now stored internally in XML. We can therefore easily access the transcript content programatically, and transform it into the form we require. (Note: Microsoft has made available a freely downloadable "compatibility pack" which, when installed, will allow any previous versions of Word to open and save the new docx documents, so it is not even necessary to have Office 2007 installed)

Topis which span one or more paragraphs will be represented by "superSegment" elements, and topics which span text within a paragraph will be represented by "superContent" elements.

## The User Interface ##

The user interface should allow the user to easily view the transcript text; (the look and feel should be similar to Microsoft Word). The interface should allow the user to select blocks of text and then to define marked content by bringing up some kind of panel. There should also be some way for the user to see what text has been marked up already, and the type of marked content. (This could be done with tool tips, inline headings, or even a separate document metadata view). There also must be a way for the user to edit and remove marked content. The details of the method by which this is accomplished is left to the discretion of the implementer. The main requirement, however, is that non-technical users are comfortable using the application.

## Implementation - Phase One ##

The goal of phase one is to deliver the absolute bare minimum of functionality, which allows users to start creating and storing transcript metadata as defined in the XML Data Model section.
In particular the application should support the following functions:

  * Select and retrieve a Transcript document (and its metadata) from the eXist database
  * Allow (and restrict) the user to select (valid) ranges of text and define marked content for these
  * Allow the user to remove/edit marked content (without affecting the transcript content)
  * Allow the user to add/edit elements in the reference file (keywordSynonyms not required)
  * Save modified TranscriptMetadata back to the eXist database


Note that in order to reduce the development time of Phase One, we do not require any querying functionality, (initially we will just use ad-hoc xqueries issued against the eXist database). We also do not require the ability to edit document root level attributes, segment attributes; nor to add segments, remove segments, merge or split segments, or edit content text. Also the definition of nested and multi-parent keywords in the reference file is not required.