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




## This is the main storage variable in AutoDoc.
## It stores the streams to files, the grouped items, and some global settings.
##
DeclareGlobalVariable( "AUTOMATIC_DOCUMENTATION" );



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

##
## This function is for internal use only.
## It creates streams for new chapters and prepares the xml file.
DeclareGlobalFunction( "CreateNewChapterXMLFile" );

##
## This function is for internal use only.
## It creates streams for new sections and prepares the xml file.
DeclareGlobalFunction( "CreateNewSectionXMLFile" );

DeclareGlobalFunction( "SetCurrentAutoDocChapter" );
DeclareGlobalFunction( "ResetCurrentAutoDocChapter" );


DeclareGlobalFunction( "SetCurrentAutoDocSection" );
DeclareGlobalFunction( "ResetCurrentAutoDocSection" );

DeclareGlobalFunction( "WriteStringIntoDoc" );
