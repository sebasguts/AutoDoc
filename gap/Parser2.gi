#############################################################################
##
##                                                           AutoDoc package
##
##  Copyright 2013, Sebastian Gutsche, TU Kaiserslautern
##
#############################################################################

##
InstallGlobalFunction( Normalized_ReadLine,
                       
  function( stream )
    local string;
    
    string := ReadLine( stream );
    
    if string = fail then
        
        return fail;
        
    fi;
    
    NormalizeWhitespace( string );
    
    return string;
    
end );

##
InstallGlobalFunction( AutoDoc_remove_trailing_and_beginning_whitespaces,
                       
  function( string )
    
    while string[ 1 ] = ' ' do
        
        Remove( string, 1 );
        
    od;
    
    while string[ Length( string ) ] = ' ' do
        
        Remove( string, Length( string ) );
        
    od;
    
    return string;
    
end );

##
InstallGlobalFunction( Scan_for_AutoDoc_Part,
                       
  function( line )
    local position, whitespace_position, command, argument;
    
    position := PositionSublist( line, "#!" );
    
    if position = fail then
        
        return [ false, line ];
        
    fi;
    
    line := AutoDoc_remove_trailing_and_beginning_whitespaces( line{[ position + 2 .. Length( line ) ]} );
    
    ## Scan for a command
    
    position := PositionSublist( line, "@" );
    
    if position = fail then
        
        return [ "STRING", line ];
        
    fi;
    
    whitespace_position := PositionSublist( line, " " );
    
    if whitespace_position = fail then
        
        command := line{[ position .. Length( line ) ]};
        
        argument := "";
        
    else
        
        command := line{[ position .. whitespace_position - 1 ]};
        
        argument := line{[ whitespace_position + 1 .. Length( line ) ]};
        
    fi;
    
    return [ command, argument ];
    
end );

##
InstallGlobalFunction( AutoDoc_Type_Of_Item,
                       
  function( current_item, type )
    local item_rec, entries, has_filters, ret_val;
    
    item_rec := current_item[ 2 ];
    
    
    
    if type = "Category" then
        
        entries := [ "Filt", "categories" ];
        
        ret_val := "<C>true</C> or <C>false</C>";
        
        has_filters := "One";
        
    elif type = "Representation" then
        
        entries := [ "Filt", "categories" ];
        
        ret_val := "<C>true</C> or <C>false</C>";
        
        has_filters := "One";
        
    elif type = "Attribute" then
        
        entries := [ "Attr", "attributes" ];
        
        has_filters := "One";
        
    elif type = "Property" then
        
        entries := [ "Prop", "properties" ];
        
        ret_val := "<C>true</C> or <C>false</C>";
        
        has_filters := "One";
        
    elif type = "Operation" then
        
        entries := [ "Oper", "methods" ];
        
        has_filters := "List";
        
    elif type = "GlobalFunction" then
        
        entries := [ "Func", "global_functions" ];
        
        has_filters := "No";
        
        if not IsBound( item_rec.arguments ) then
            
            item_rec.arguments := "arg";
            
        fi;
        
    elif type = "GlobalVariable" then
        
        entries := [ "Var", "global_variables" ];
        
        ret_val := fail;
        
        has_filters := "No";
        
        item_rec.arguments := fail;
        
    else
        
        return fail;
        
    fi;
    
    item_rec.type := entries[ 1 ];
    
    item_rec.doc_stream_type := entries[ 2 ];
    
    if not IsBound( item_rec.chapter_info ) then
        item_rec.chapter_info := AUTOMATIC_DOCUMENTATION.default_chapter.( entries[ 2 ] );
    fi;
    
    if IsBound( ret_val ) and item_rec.return_value = false then
        
        item_rec.return_value := ret_val;
        
    fi;
    
    return has_filters;
    
end );

##
InstallGlobalFunction( Scan_for_declaration_part,
                       
  function( current_line, filestream )
    
    declare_position := PositionSublist( current_line, "Declare" );
    
    item_record := rec( );
    
    if declare_position <> fail then
        
        current_line := current_line{[ declare_position + 7 .. Length( current_line ) ]};
        
        position_parentesis := PositionSublist( current_line, "(" );
        
        if position_parentesis = fail then
            
            Error( "Something went wrong" );
            
        fi;
        
        current_type := current_line{ [ 1 .. position_parentesis - 1 ] };
        
        has_filters := AutoDoc_Type_Of_Item( current_item, current_type );
        
        if has_filters = fail then
            
            current_item := recover_item();
            
                    continue;
                    
                fi;
                
                current_line := current_line{ [ position_parentesis + 1 .. Length( current_line ) ] };
                
                ## Not the funny part begins:
                ## try fetching the name:
                
                ## Assuming the name is in the same line as its 
                while PositionSublist( current_line, "," ) = fail and PositionSublist( current_line, ");" ) = fail do
                    
                    current_line := ReadLine( filestream );
                    
                od;
                
                NormalizeWhitespace( current_line );
                
                current_line := AutoDoc_RemoveSpacesAndComments( current_line );
                
                current_item[ 2 ].name := current_line{ [ 1 .. Minimum( [ PositionSublist( current_line, "," ), PositionSublist( current_line, ");" ) ] ) - 1 ] };
                
                current_item[ 2 ].name := AutoDoc_RemoveSpacesAndComments( ReplacedString( current_item[ 2 ].name, "\"", "" ) );
                
                current_line := current_line{ [ Minimum( [ PositionSublist( current_line, "," ), PositionSublist( current_line, ");" ) ] ) + 1 .. Length( current_line ) ] };
                
                if has_filters = "One" then
                    
                    filter_string := "for ";
                    
                    while PositionSublist( current_line, "," ) = fail and PositionSublist( current_line, ");" ) = fail do
                        
                        Append( filter_string, AutoDoc_RemoveSpacesAndComments( current_line ) );
                        
                        current_line := ReadLine( filestream );
                        
                        NormalizeWhitespace( current_line );
                        
                    od;
                    
                    Append( filter_string, AutoDoc_RemoveSpacesAndComments( current_line{ [ 1 .. Minimum( [ PositionSublist( current_line, "," ), PositionSublist( current_line, ");" ) ] ) - 1 ] } ) );
                    
                elif has_filters = "List" then
                    
                    filter_string := "for ";
                    
                    while PositionSublist( current_line, "[" ) = fail do
                        
                        current_line := ReadLine( filestream );
                        
                        NormalizeWhitespace( current_line );
                        
                    od;
                    
                    current_line := current_line{ [ PositionSublist( current_line, "[" ) + 1 .. Length( current_line ) ] };
                    
                    while PositionSublist( current_line, "]" ) = fail do
                        
                        Append( filter_string, AutoDoc_RemoveSpacesAndComments( current_line ) );
                        
                        current_line := ReadLine( filestream );
                        
                        NormalizeWhitespace( current_line );
                        
                    od;
                    
                    Append( filter_string, AutoDoc_RemoveSpacesAndComments( current_line{[ 1 .. PositionSublist( current_line, "]" ) - 1 ]} ) );
                    
                else
                    
                    filter_string := false;
                    
                fi;
                
                if filter_string <> false then
                    
                    current_item[ 2 ].tester_names := filter_string;
                    
                fi;
                
                current_item := AutoDoc_Flush( current_item );
                
                recover_item();
                
                continue;
                
            fi;
            
            declare_position := PositionSublist( current_line, "InstallMethod" );
            
            if declare_position <> fail then
                
                current_item := AutoDoc_Prepare_Item_Record( current_item, chapter_info, scope_group );
                
                current_item[ 2 ].type := "Func";
                
                current_item[ 2 ].doc_stream_type := "operations";
                
                ##Find name
                
                position_parentesis := PositionSublist( current_line, "(" );
                
                current_line := current_line{ [ position_parentesis + 1 .. Length( current_line ) ] };
                
                ## find next colon
                current_item[ 2 ].name := "";
                
                while PositionSublist( current_line, "," ) = fail do
                    
                    Append( current_item[ 2 ].name, current_line );
                    
                od;
                
                position_parentesis := PositionSublist( current_line, "," );
                
                Append( current_item[ 2 ].name, current_line{[ 1 .. position_parentesis - 1 ]} );
                
                NormalizeWhitespace( current_item[ 2 ].name );
                
                current_item[ 2 ].name := AutoDoc_RemoveSpacesAndComments( current_item[ 2 ].name );
                
                while PositionSublist( current_line, "[" ) = fail do
                    
                    current_line := ReadLine( filestream );
                    
                od;
                
                position_parentesis := PositionSublist( current_line, "[" );
                
                current_line := current_line{[ position_parentesis + 1 .. Length( current_line ) ]};
                
                filter_string := "for ";
                
                while PositionSublist( current_line, "]" ) = fail do
                    
                    Append( filter_string, current_line );
                    
                od;
                
                position_parentesis := PositionSublist( current_line, "]" );
                
                Append( filter_string, current_line{[ 1 .. position_parentesis - 1 ]} );
                
                current_line := current_line{[ position_parentesis + 1 .. Length( current_line )]};
                
                NormalizeWhitespace( filter_string );
                
                current_item[ 2 ].tester_names := filter_string;
                
                ##Maybe find some argument names
                if not IsBound( current_item[ 2 ].arguments ) then
                
                    while PositionSublist( current_line, "function(" ) = fail and PositionSublist( current_line, ");" ) = fail do
                        
                        current_line := ReadLine( filestream );
                        
                    od;
                    
                    position_parentesis := PositionSublist( current_line, "function(" );
                    
                    if position_parentesis <> fail then
                        
                        current_line := current_line{[ position_parentesis + 9 .. Length( current_line ) ]};
                        
                        filter_string := "";
                        
                        while PositionSublist( current_line, ")" ) = fail do
                            
                            NormalizeWhitespace( current_line );
                            
                            current_line := AutoDoc_RemoveSpacesAndComments( current_line );
                            
                            Append( filter_string, current_line );
                            
                            current_line := ReadLine( current_line );
                            
                        od;
                        
                        position_parentesis := PositionSublist( current_line, ")" );
                        
                        Append( filter_string, current_line{[ 1 .. position_parentesis - 1 ]} );
                        
                        NormalizeWhitespace( filter_string );
                        
                        filter_string := AutoDoc_RemoveSpacesAndComments( filter_string );
                        
                        current_item[ 2 ].arguments := filter_string;
                        
                    fi;
                    
                fi;
                
                current_item := AutoDoc_Flush( current_item );
                
                recover_item();
                
            fi;
            
            autodoc_active := false;
            
            continue;
            
        fi;
  
  

##
InstallGlobalFunction( AutoDoc_Parser_ReadFiles,
                       
  function( filename, tree )
    
    