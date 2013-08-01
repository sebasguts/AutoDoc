LoadPackage("AutoDoc");
#LoadPackage("AutoDocTestPackage");
#Reset( GlobalMersenneTwister, 0 );;  # HACK HACK HACK only for AutoDocTester, remove later

GenerateDocumentation(
    "AutoDocTestPackage",
    true,
    rec(
        #dir := "doc/",
        autodoc_output := "gap/documentation_file.d",
#         gapdoc_files := [
#             #"../gap/documentation_file.d",  # automatically added to list
#             "../gap/Declarations.gd",
#         ]
        gapdoc_scan_dirs := [ "../gap" ],
        section_intros := 
            [
              [ "Intro", "This is a test docu" ],
              [ "With_chapter_info", "This is a user set chapter" ],
              [ "With_chapter_info", "Category_section", [ "This section", "is for categories" ] ]
            ],
        #entities := [],
    )
);
