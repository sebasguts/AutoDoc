#############################################################################
##
##                                                           AutoDoc package
##
##  Copyright 2013, Sebastian Gutsche, TU Kaiserslautern
##
#############################################################################

DeclareCategory( "IsTreeForDocumentation",
                 IsObject );

DeclareCategory( "IsTreeForDocumentationNode",
                 IsObject );

######################################
##
## Attributes
##
######################################

DeclareFilter( "IsEmptyNode" );

DeclareAttribute( "Name",
                  IsTreeForDocumentationNode );

DeclareAttribute( "ChapterInfo",
                  IsTreeForDocumentationNode );

DeclareAttribute( "DummyName",
                  IsTreeForDocumentationNode );

######################################
##
## Constructors
##
######################################

DeclareOperation( "DocumentationTree",
                  [ ] );

DeclareOperation( "DocumentationChapter",
                  [ IsString ] );

DeclareOperation( "DocumentationSection",
                  [ IsString ] );

DeclareOperation( "DocumentationText",
                  [ IsList, IsList ] );

DeclareOperation( "DocumentationItem",
                  [ IsRecord ] );

DeclareOperation( "DocumentationDummy",
                  [ IsString, IsList ] );

DeclareOperation( "DocumentationExample",
                  [ IsList, IsList ] );

######################################
##
## Build methods
##
######################################

DeclareOperation( "ChapterInTree",
                  [ IsTreeForDocumentation, IsString ] );

DeclareOperation( "SectionInTree",
                  [ IsTreeForDocumentation, IsString, IsString ] );

DeclareOperation( "GroupInTree",
                  [ IsTreeForDocumentation, IsString ] );

DeclareOperation( "Add",
                  [ IsTreeForDocumentation, IsTreeForDocumentationNode ] );

DeclareOperation( "MergeGroupEntries",
                  [ IsTreeForDocumentationNode, IsTreeForDocumentationNode ] );

#######################################
##
## Write methods
##
#######################################

DeclareOperation( "WriteDocumentation",
                  [ IsTreeForDocumentation, IsDirectory ] );

DeclareOperation( "WriteDocumentation",
                  [ IsTreeForDocumentationNode, IsStream ] );

DeclareOperation( "WriteDocumentation",
                  [ IsTreeForDocumentationNode, IsStream, IsString ] );

DeclareOperation( "WriteDocumentation",
                  [ IsTreeForDocumentationNode, IsStream, IsDirectory ] );
