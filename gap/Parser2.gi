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
        
        if not IsBound( current_item ) then
            
            return;
            
        fi;
        
        node := DocumentationNode( current_item );
        
        Add( tree, node );
        
        current_item := rec( );
        
        current_item.chapter_info := chapter_info;
        
        current_item.level := 0;
        
        current_item.node_type := "TEXT";
        
        current_item.text := [ ];
        
        current_string_list := current_item.text;
        
    end;
    
    command_function_record := rec(
        
        @AutoDoc := function()
            
            ##FIXME
            
        end,
        
        @EndAutoDoc := function()
            
            ##FIXME
            
        end,
        
        @Chapter := function()
            local scope_chapter;
            
            scope_chapter := ReplacedString( current_command[ 2 ], " ", "_" );
            
            ChapterInTree( AUTOMATIC_DOCUMENTATION.tree, scope_chapter );
            
            chapter_info[ 1 ] := scope_chapter;
            
            Unbind( chapter_info[ 2 ] );
            
            flush_and_recover();
            
        end,
        
        @Section := function()
            local scope_section;
            
            scope_section := ReplacedString( current_command[ 2 ], " ", "_" );
            
            SectionInTree( AUTOMATIC_DOCUMENTATION.tree, chapter_info[ 1 ], scope_section );
            
            chapter_info[ 2 ] := scope_section;
            
        end,
        
        @EndSection := function()
            
            if not IsBound( scope_section ) then
                
                Error( "No section set" );
                
            fi;
            
            if IsBound( current_item ) then current_item := AutoDoc_Flush( current_item ); fi;
            
            Unbind( scope_section );
            
            recover_item();
            
            Unbind( chapter_info[ 2 ] );
            
        end,
        
        @BeginGroup := function()
            
            if IsBound( current_item ) then current_item := AutoDoc_Flush( current_item ); fi;
            
            if current_command[ 2 ] = "" then
                
                AUTOMATIC_DOCUMENTATION.groupnumber := AUTOMATIC_DOCUMENTATION.groupnumber + 1;
                
                current_command[ 2 ] := Concatenation( "AutoDoc_generated_group", String( AUTOMATIC_DOCUMENTATION.groupnumber ) );
                
            fi;
            
            scope_group := ReplacedString( current_command[ 2 ], " ", "_" );
            
        end,
        
        @EndGroup := function()
            
            if IsBound( current_item ) then current_item := AutoDoc_Flush( current_item ); fi;
            
            recover_item();
            
            scope_group := false;
            
        end,
        
        @Description := function()
            
            current_item := AutoDoc_Prepare_Item_Record( current_item, chapter_info, scope_group );
            
            current_item[ 2 ].description := [ ];
            
            current_string_list := current_item[ 2 ].description;
            
            if current_command[ 2 ] <> "" then
                
                Add( current_string_list, current_command[ 2 ] );
                
            fi;
            
        end,
        
        @Returns := function()
            
            current_item := AutoDoc_Prepare_Item_Record( current_item, chapter_info, scope_group );
            
            current_item[ 2 ].return_value := current_command[ 2 ];
            
        end,
        
        @Arguments := function()
            
            current_item := AutoDoc_Prepare_Item_Record( current_item, chapter_info, scope_group );
            
            current_item[ 2 ].arguments := current_command[ 2 ];
            
        end,
        
        @Label := function()
            
            current_item := AutoDoc_Prepare_Item_Record( current_item, chapter_info, scope_group );
            
            current_item[ 2 ].function_label := current_command[ 2 ];
            
        end,
        
        @Group := function()
            
            current_item := AutoDoc_Prepare_Item_Record( current_item, chapter_info, scope_group );
            
            current_item[ 2 ].group := current_command[ 2 ];
            
        end,
        
        @ChapterInfo := function()
            
            current_item := AutoDoc_Prepare_Item_Record( current_item, chapter_info, scope_group );
            
            current_item[ 2 ].chapter_info := SplitString( current_command[ 2 ], "," );
            
            current_item[ 2 ].chapter_info := List( current_item[ 2 ].chapter_info, i -> ReplacedString( AutoDoc_RemoveSpacesAndComments( i ), " ", "_" ) );
            
        end,
        
        @BREAK := function()
            
            Error( current_command[ 2 ] );
            
        end,
        
        @Level := function()
            
            AutoDoc_Flush( current_item );
            
            recover_item();
            
            PushOptions( rec( level_value := Int( current_command[ 2 ] ) ) );
            
        end,
        
        @ResetLevel := function()
            
            AutoDoc_Flush( current_item );
            
            recover_item();
            
            PushOptions( rec( level_value := 0 ) );
            
        end,
        
        @InsertSystem := function()
            
            AutoDoc_Flush( current_item );
            
            Add( AUTOMATIC_DOCUMENTATION.tree, DocumentationDummy( current_command[ 2 ], chapter_info ) );
            
            recover_item();
            
        end,
        
        @System := function()
            
            PushOptions( rec( system_name := current_command[ 2 ] ) );
            
        end,
        
        @Example := function()
            local content_string_list;
            
            AutoDoc_Flush( current_item );
            
            content_string_list := read_example();
            
            Add( AUTOMATIC_DOCUMENTATION.tree, DocumentationExample( content_string_list, chapter_info ) );
            
            recover_item();
            
        end,
        
        ##FIXME: This is hacky! You can do this better.
        @Author := function()
            
            PushOptions( rec( AutoDoc_Author := current_command[ 2 ] ) );
            
        end,
        
        @Title := function()
            
            PushOptions( rec( AutoDoc_Title := current_command[ 2 ] ) );
            
        end
        
    );