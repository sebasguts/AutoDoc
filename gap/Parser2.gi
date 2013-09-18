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
InstallGlobalFunction( AutoDoc_Parser_ReadFiles,
                       
  function( filename_list, tree )
    local current_item, flush_and_recover, chapter_info, current_string_list;
    
    flush_and_recover := function()
        local node;
        
        node := DocumentationNode( current_item );
        
        Add( tree, node );
        
        current_item := rec( );
        
        current_item!.chapter_info := chapter_info;
        
        current_item!.level := 0;
        
        current_item!.node_type := "TEXT";
        
        current_item!.text := [ ];
        
        current_string_list := current_item.text;
        
    end;