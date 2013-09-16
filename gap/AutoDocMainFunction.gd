#############################################################################
##
##  AutoDoc package
##
##  Copyright 2007-2013,   Sebastian Gutsche, University of Kaiserslautern
##                         Max Horn, Justus-Liebig-Universität Gießen
##
##  
##
#############################################################################



# Documentation for this global variable can be found in gap/AutoDocDocEntries.g
# respectively in the manual.

DeclareGlobalVariable( "AUTOMATIC_DOCUMENTATION" );

DeclareGlobalVariable( "AUTODOC_XML_HEADER" );


# Documentation for this global function can be found in gap/AutoDocDocEntries.g
# respectively in the manual.
DeclareGlobalFunction( "CreateAutomaticDocumentation" );


# The following functions are currently undocumented and for internal use only.

##
## This function creates a title file. It must be called with the package name and the path to doc files.
DeclareGlobalFunction( "CreateTitlePage" );

##
## This function creates the main page. Do not call it out of context.
DeclareGlobalFunction( "CreateMainPage" );

##
## This function is for internal use only.
## It creates names for the default chapters and sections.
DeclareGlobalFunction( "CreateDefaultChapterData" );

DeclareGlobalFunction( "SetCurrentAutoDocChapter" );
DeclareGlobalFunction( "ResetCurrentAutoDocChapter" );


DeclareGlobalFunction( "SetCurrentAutoDocSection" );
DeclareGlobalFunction( "ResetCurrentAutoDocSection" );

DeclareGlobalFunction( "WriteStringIntoDoc" );

#! @Chapter AutoDoc worksheets
#! @Section Worksheets

#! @Description
#!  This function takes a filename and returns a complete GAPDoc document created
#!  out of the file. All AutoDoc commands can be used to create such a file. Also
#!  there are some special tags, which have only effect in files if the files are parsed with
#!  this command. Those commands are:
#!  <List>
#!  <Mark>Title <A>title</A></Mark>
#!  <Item>
#!    This adds a title to the document
#!  </Item>
#!  <Mark>Author <A>author</A></Mark>
#!  <Item>
#!    This adds an author to the document.
#!  </Item>
#!  </List>
#!  Note that some commands have no effect, i.e. the level command.
DeclareGlobalFunction( "AutoDocWorksheet" );
