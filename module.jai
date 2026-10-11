#if OS == .MACOS {
    #import "POSIX";
    libyyjson :: #library,no_dll "macos/libyyjson";
} else #if OS == .LINUX {
    #import "POSIX";
    libyyjson :: #library,no_dll "linux/libyyjson";
} else #if OS == .WINDOWS {
    FILE :: void;
    libyyjson :: #library,no_dll "windows/yyjson";
} else {
    #assert false "yyjson: unsupported OS.";
}

#load "yyjson.jai";
#load "wrapper.jai";
