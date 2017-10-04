#############################################################################
##
##  AutoDoc package
##
##  Copyright 2012-2016
##    Sebastian Gutsche, University of Kaiserslautern
##    Max Horn, Justus-Liebig-Universität Gießen
##
## Licensed under the GPL 2 or later.
##
#############################################################################

InstallGlobalFunction( "AUTODOC_OutputTextFile",
function( arg )
    local filename, filestream;
    if Length( arg ) = 1 then
        filename := arg[1];
    else
        filename := Filename( arg[1], arg[2] );
    fi;
    filestream := OutputTextFile( filename, false );
    SetPrintFormattingStatus( filestream, false );
    return filestream;
end );

##
InstallGlobalFunction( AutoDoc_WriteDocEntry,
  function( filestream, list_of_records )
    local return_value, description, current_description, labels, i;

    # look for a good return value (it should be the same everywhere)
    for i in list_of_records do
        if IsBound( i!.return_value ) then
            if IsList( i!.return_value ) and Length( i!.return_value ) > 0 then
                return_value := i!.return_value;
                break;
            elif IsBool( i!.return_value ) then
                return_value := i!.return_value;
                break;
            fi;
        fi;
    od;

    if not IsBound( return_value ) then
        return_value := false;
    fi;

    if IsList( return_value ) and ( not IsString( return_value ) ) and return_value <> "" then
        return_value := JoinStringsWithSeparator( return_value, " " );
    fi;

    # collect description (for readability not in the loop above)
    description := [ ];
    for i in list_of_records do
        current_description := i!.description;
        if IsString( current_description ) then
            current_description := [ current_description ];
        fi;
        description := Concatenation( description, current_description );
    od;

    labels := [ ];
    for i in list_of_records do
        if HasGroupName( i ) then
            Add( labels, GroupName( i ) );
        fi;
    od;
    if Length( labels ) > 1 then
        labels :=  [ labels[ 1 ] ];
    fi;

    # Write stuff out

    # First labels, this has no effect in the current GAPDoc, btw.
    AppendTo( filestream, "<ManSection" );
    for i in labels do
        AppendTo( filestream, " Label=\"", i, "\"" );
    od;
    AppendTo( filestream, ">\n" );

    # Function heades
    for i in list_of_records do
         AppendTo( filestream, "  <", i!.item_type, " " );
        if i!.arguments <> fail and i!.item_type <> "Var" then
            AppendTo( filestream, "Arg=\"", i!.arguments, "\" " );
        fi;
        AppendTo( filestream, "Name=\"", i!.name, "\" " );
        if i!.tester_names <> fail and i!.tester_names <> "" then
            AppendTo( filestream, "Label=\"", i!.tester_names, "\"" );
        fi;
        AppendTo( filestream, "/>\n" );
    od;

    if return_value <> false then
        if IsString( return_value ) then
            return_value := [ return_value ];
        fi;
        AppendTo( filestream, " <Returns>" );
        WriteDocumentation( return_value, filestream );
        AppendTo( filestream, "</Returns>\n" );
    fi;

    AppendTo( filestream, " <Description>\n" );
    WriteDocumentation( description, filestream );
    AppendTo( filestream, " </Description>\n" );

    AppendTo( filestream, "</ManSection>\n\n" );
end );

InstallGlobalFunction( AutoDoc_MakeGAPDocDoc_WithoutLatex,

  function(arg)
  local htmlspecial, path, main, files, bookname, gaproot, str,
        r, t, l, latex, null, log, pos, h, i, j;
  htmlspecial := Filtered(arg, a-> a in ["MathML", "Tth", "MathJax"]);
  if Length(htmlspecial) > 0 then
    arg := Filtered(arg, a-> not a in ["MathML", "Tth", "MathJax"]);
  fi;
  path := arg[1];
  main := arg[2];
  files := arg[3];
  bookname := arg[4];
  if IsBound(arg[5]) then
    gaproot := arg[5];
  else
    gaproot := false;
  fi;
  # ensure that path is directory object
  if IsString(path) then
    path := Directory(path);
  fi;
  # ensure that .xml is stripped from name of main file
  if Length(main)>3 and main{[Length(main)-3..Length(main)]} = ".xml" then
    main := main{[1..Length(main)-4]};
  fi;
  # compose the XML document
  Info(InfoGAPDoc, 1, "#I Composing XML document . . .\n");
  str := ComposedDocument("GAPDoc", path,
                             Concatenation(main, ".xml"), files, true);
  # parse the XML document
  Info(InfoGAPDoc, 1, "#I Parsing XML document . . .\n");
  r := ParseTreeXMLString(str[1], str[2]);
  # clean the result
  Info(InfoGAPDoc, 1, "#I Checking XML structure . . .\n");
  CheckAndCleanGapDocTree(r);
  # produce text version
  Info(InfoGAPDoc, 1,
                   "#I Text version (also produces labels for hyperlinks):\n");
  t := GAPDoc2Text(r, path);
  GAPDoc2TextPrintTextFiles(t, path);
  # produce LaTeX version
  Info(InfoGAPDoc, 1, "#I Constructing LaTeX version and calling pdflatex:\n");
  r.bibpath := path;
  l := GAPDoc2LaTeX(r);
  Info(InfoGAPDoc, 1, "#I Writing LaTeX file, \c");
  Info(InfoGAPDoc, 2, Concatenation(main, ".tex"), "\n#I     ");
  FileString(Filename(path, Concatenation(main, ".tex")), l);
  # print manual.six file
  PrintSixFile(Filename(path, "manual.six"), r, bookname);
  # produce html version
  Info(InfoGAPDoc, 1, "#I Finally the HTML version . . .\n");
  # if MathJax version is also produced we include links to them
  if "MathJax"  in htmlspecial then
    r.LinkToMathJax := true;
  fi;
  h := GAPDoc2HTML(r, path, gaproot);
  GAPDoc2HTMLPrintHTMLFiles(h, path);
  Unbind(r.LinkToMathJax);
  if "Tth" in htmlspecial then
    Info(InfoGAPDoc, 1,
            "#I - also HTML version with 'tth' translated formulae . . .\n");
    h := GAPDoc2HTML(r, path, gaproot, "Tth");
    GAPDoc2HTMLPrintHTMLFiles(h, path);
  fi;
  if "MathML" in htmlspecial then
    Info(InfoGAPDoc, 1, "#I - also HTML + MathML version with 'ttm' . . .\n");
    h := GAPDoc2HTML(r, path, gaproot, "MathML");
    GAPDoc2HTMLPrintHTMLFiles(h, path);
  fi;
  if "MathJax" in htmlspecial then
    Info(InfoGAPDoc, 1, "#I - also HTML version for MathJax . . .\n");
    h := GAPDoc2HTML(r, path, gaproot, "MathJax");
    GAPDoc2HTMLPrintHTMLFiles(h, path);
  fi;

  return r;
end);

BindGlobal( "AUTODOC_WriteDemoToFile",
  
  function( stream, example )
    local split_string, current_line;
    
    split_string := SplitString( example, "\n" );
    
    for current_line in split_string do
        current_line := NormalizedWhitespace( current_line );
        if current_line = "" then
            continue;
        elif StartsWith( current_line, "gap>" ) then
            PrintTo( stream, "%\n", NormalizedWhitespace( current_line{[ 5 .. Length( current_line ) ]} ), "\n" );
        elif StartsWith( current_line, ">" ) then
            PrintTo( stream, NormalizedWhitespace( current_line{[ 2 .. Length( current_line ) ]} ), "\n" );
        fi;
    od;
    
end );

InstallGlobalFunction( AutoDocDemo,
  
  function( pkg_name, args... )
    local options_rec, demo_dir, pkg_info, pkg_folder, example_list, read_file,
          example_counter, file, current_output_file, description;
    
    if Length( args ) = 1 then
        options_rec := args[ 1 ];
    else
        options_rec := rec( );
    fi;
    
    AUTODOC_SetIfMissing( options_rec, "interactive", true );
    AUTODOC_SetIfMissing( options_rec, "examples_folder", "doc" );
    AUTODOC_SetIfMissing( options_rec, "MainXMLFile", Concatenation( pkg_name, ".xml" ) );
    AUTODOC_SetIfMissing( options_rec, "folder", "demos" );
    
    pkg_info := PackageInfo( pkg_name )[ 1 ];
    pkg_folder := pkg_info.InstallationPath;
    
    if options_rec.interactive = true then
        demo_dir := DirectoryTemporary( );
    else
        demo_dir := AUTODOC_CreateDirIfMissing( Concatenation( pkg_folder, "/", options_rec.folder ) );
        demo_dir := Directory( Concatenation( pkg_folder, "/", options_rec.folder ) );
    fi;
    
    example_list := ExtractExamples( DirectoriesPackageLibrary( pkg_name, options_rec.examples_folder )[ 1 ],
                                     options_rec.MainXMLFile, [ ], "none" );
    
    example_list := example_list[ 1 ];
    
    if not options_rec.interactive = true then
        read_file := Filename( demo_dir, "readdemo.g" );
        read_file := OutputTextFile( read_file, false );
    fi;
    
    for example_counter in [ 1 .. Length( example_list ) ] do
        
        file := Filename( demo_dir, Concatenation( "Example", String( example_counter ) , ".demo" ) );
        current_output_file := OutputTextFile( file, false );
        AUTODOC_WriteDemoToFile( current_output_file, example_list[ example_counter ][ 1 ] );
        CloseStream( current_output_file );
        
        description := Concatenation( "Example ", String( example_counter ), ", lines ", String( example_list[ example_counter ][ 2 ][ 2 ] ),
                                      " - ", String( example_list[ example_counter ][ 2 ][ 3 ] ), " from file ", example_list[ example_counter ][ 2 ][ 1 ] );
        
        if options_rec.interactive = true then
            LoadDemoFile( description, file );
        else
            PrintTo( read_file, "LoadDemoFile( \"", description, "\", \"", file, "\" );\n" );
        fi;
        
    od;
    
    if not options_rec.interactive = true then
        CloseStream( read_file );
    fi;
    
end );
