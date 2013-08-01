LoadPackage("AutoDoc");

GenerateDocumentation(
    "AutoDoc",
    true, # re-create title page
    rec(
        #dir := "doc/",
        #gapdoc_files := [ "../gap/AutoDocEntries.g" ],
        #autodoc_output := "gap/AutoDocEntries.g",
        gapdoc_scan_dirs := [ "../gap" ],
    )
);
