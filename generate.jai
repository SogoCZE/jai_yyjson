#import "Basic";
#import "Compiler";
#import "Process";
#import "Bindings_Generator";
#import "File";
#import "File_Utilities";
#import "String";

#run {
    if #exists(JAILS_DIAGNOSTICS_BUILD) {
        return;
    }

    set_build_options_dc(.{do_output=false});

    generate();
}

generate :: () -> bool {
    libpaths: [..]string;

    if OS == {
        case .WINDOWS; array_add(*libpaths, "./windows");
        case .MACOS;   array_add(*libpaths, "./macos");
        case .LINUX;   array_add(*libpaths, "./linux/x64");
    }

    libnames: [..]string;
    array_add(*libnames, "libyyjson");

    source_files: [..]string;
    array_add(*source_files, "./src/yyjson.h");

    ok := generate_bindings(.{
        libnames=libnames,
        libpaths=libpaths,
        source_files=source_files,
        strip_flags=Strip_Flags.FUNCTIONS_WITH_VALIST,
        generate_library_declarations=false,
        auto_detect_enum_prefixes=true,
        log_stripped_declarations=false,
        generate_compile_time_struct_checks=false,
        alias_original_enum_names=false,
    }, "yyjson.jai");

    if !ok {
        log_error("Failed to generate the bindings.");
    }

    return ok;
}
