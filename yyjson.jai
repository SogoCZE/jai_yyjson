//
// This file was auto-generated using the following command:
//
// jai generate.jai
//



YYJSON_DISABLE_READER :: 0;

YYJSON_DISABLE_WRITER :: 0;

YYJSON_DISABLE_INCR_READER :: 0;

YYJSON_DISABLE_FILE :: 0;

YYJSON_DISABLE_UTILS :: 0;

YYJSON_DISABLE_FAST_FP_CONV :: 0;

YYJSON_DISABLE_NON_STANDARD :: 0;

YYJSON_DISABLE_UTF8_VALIDATION :: 0;

YYJSON_READER_DEPTH_LIMIT :: 0;

YYJSON_WRITER_DEPTH_LIMIT :: 0;

YYJSON_FREESTANDING :: 0;

YYJSON_MSC_VER :: 0;

YYJSON_IS_REAL_GCC :: 0;

YYJSON_CPP_VER :: 0;

YYJSON_HAS_CONSTANT_P :: 1;

YYJSON_U64_TO_F64_NO_IMPL :: 0;

YYJSON_VERSION_MAJOR :: 0;

YYJSON_VERSION_MINOR :: 13;

YYJSON_VERSION_PATCH :: 0;

YYJSON_VERSION_HEX :: 0x000D00;

YYJSON_VERSION_STRING :: "0.13.0";

YYJSON_TYPE_NONE :: cast(u8) 0;

YYJSON_TYPE_RAW :: cast(u8) 1;

YYJSON_TYPE_NULL :: cast(u8) 2;

YYJSON_TYPE_BOOL :: cast(u8) 3;

YYJSON_TYPE_NUM :: cast(u8) 4;

YYJSON_TYPE_STR :: cast(u8) 5;

YYJSON_TYPE_ARR :: cast(u8) 6;

YYJSON_TYPE_OBJ :: cast(u8) 7;

YYJSON_SUBTYPE_NONE :: cast(u8) (0 << 3);

YYJSON_SUBTYPE_FALSE :: cast(u8) (0 << 3);

YYJSON_SUBTYPE_TRUE :: cast(u8) (1 << 3);

YYJSON_SUBTYPE_UINT :: cast(u8) (0 << 3);

YYJSON_SUBTYPE_SINT :: cast(u8) (1 << 3);

YYJSON_SUBTYPE_REAL :: cast(u8) (2 << 3);

YYJSON_SUBTYPE_NOESC :: cast(u8) (1 << 3);

YYJSON_TYPE_MASK :: cast(u8) 0x07;

YYJSON_TYPE_BIT :: cast(u8) 3;

YYJSON_SUBTYPE_MASK :: cast(u8) 0x18;

YYJSON_SUBTYPE_BIT :: cast(u8) 2;

YYJSON_RESERVED_MASK :: cast(u8) 0xE0;

YYJSON_RESERVED_BIT :: cast(u8) 3;

YYJSON_TAG_MASK :: cast(u8) 0xFF;

YYJSON_TAG_BIT :: cast(u8) 8;

YYJSON_PADDING_SIZE :: 4;

YYJSON_WRITE_FP_FLAG_BITS :: 8;

YYJSON_WRITE_FP_PREC_BITS :: 4;

YYJSON_WRITE_FP_TO_FLOAT :: cast(yyjson_write_flag) (1 << (32 - 5));

/** The version of yyjson in hex, same as `YYJSON_VERSION_HEX`. */
yyjson_version :: () -> u32 #foreign libyyjson;

/** Type of a JSON value (3 bit). */
yyjson_type :: u8;

/** Subtype of a JSON value (2 bit). */
yyjson_subtype :: u8;

/**
A memory allocator.

Typically you don't need to use it, unless you want to customize your own
memory allocator.
*/
yyjson_alc :: struct {
    /** Same as libc's malloc(size), should not be NULL. */
    malloc:  #type (ctx: *void, size: u64) -> *void #c_call;

    /** Same as libc's realloc(ptr, size), should not be NULL. */
    realloc: #type (ctx: *void, ptr: *void, old_size: u64, size: u64) -> *void #c_call;

    /** Same as libc's free(ptr), should not be NULL. */
    free:    #type (ctx: *void, ptr: *void) -> void #c_call;

    /** A context for malloc/realloc/free, can be NULL. */
    ctx:     *void;
}

/**
A pool allocator uses fixed length pre-allocated memory.

This allocator may be used to avoid malloc/realloc calls. The pre-allocated
memory should be held by the caller. The maximum amount of memory required to
read a JSON can be calculated using the `yyjson_read_max_memory_usage()`
function, but the amount of memory required to write a JSON cannot be directly
calculated.

This is not a general-purpose allocator. It is designed to handle a single JSON
document at a time. If it is used for overly complex memory tasks, such as
parsing multiple JSON documents using the same allocator but releasing only a
few of them, it may cause memory fragmentation, resulting in performance
degradation and memory waste.

@param alc The allocator to be initialized.
If `alc` is NULL, returns false.
If `buf` or `size` is invalid, this will be set to an empty allocator.
@param buf The buffer memory for this allocator.
If `buf` is NULL, returns false.
@param size The size of `buf`, in bytes.
If `size` is less than 8 words (32/64 bytes on 32/64-bit OS),
returns false.
@return true if the `alc` has been successfully initialized.

@b Example
@code
// parse JSON with stack memory
char buf[1024];
yyjson_alc alc;
yyjson_alc_pool_init(&alc, buf, 1024);

const char *json = "{\"name\":\"Helvetica\",\"size\":16}";
yyjson_doc *doc = yyjson_read_opts(json, strlen(json), 0, &alc, NULL);
// the memory of `doc` is on the stack
@endcode

@warning This Allocator is not thread-safe.
*/
yyjson_alc_pool_init :: (alc: *yyjson_alc, buf: *void, size: u64) -> bool #foreign libyyjson;

/**
A dynamic allocator.

This allocator has a similar usage to the pool allocator above. However, when
there is not enough memory, this allocator will dynamically request more memory
using libc's `malloc` function, and frees it all at once when it is destroyed.

@return A new dynamic allocator, or NULL if memory allocation failed.
@note The returned value should be freed with `yyjson_alc_dyn_free()`.

@warning This Allocator is not thread-safe.
*/
yyjson_alc_dyn_new :: () -> *yyjson_alc #foreign libyyjson;

/**
Free a dynamic allocator which is created by `yyjson_alc_dyn_new()`.
@param alc The dynamic allocator to be destroyed.
*/
yyjson_alc_dyn_free :: (alc: *yyjson_alc) -> void #foreign libyyjson;

/**
Locate the line and column number for a byte position in a string.
This can be used to get better description for error position.

@param str The input string.
@param len The byte length of the input string.
@param pos The byte position within the input string.
@param line A pointer to receive the line number, starting from 1.
@param col  A pointer to receive the column number, starting from 1.
@param chr  A pointer to receive the character index, starting from 0.
@return true on success, false if `str` is NULL or `pos` is out of bounds.
@note Line/column/character are calculated based on Unicode characters for
compatibility with text editors. For multi-byte UTF-8 characters,
the returned value may not directly correspond to the byte position.
*/
yyjson_locate_pos :: (str: *u8, len: u64, pos: u64, line: *u64, col: *u64, chr: *u64) -> bool #foreign libyyjson;

/** Run-time options for JSON reader. */
yyjson_read_flag :: u32;

/** Default option (RFC 8259 compliant):
- Read positive integer as uint64_t.
- Read negative integer as int64_t.
- Read floating-point number as double with round-to-nearest mode.
- Read integer which cannot fit in uint64_t or int64_t as double.
- Report error if double number is infinity.
- Report error if string contains invalid UTF-8 character or BOM.
- Report error on trailing commas, comments, inf and nan literals. */
YYJSON_READ_NOFLAG: yyjson_read_flag : 0;

/** Read the input data in-situ.
This option allows the reader to modify and use input data to store string
values, which can increase reading speed slightly.
The caller should hold the input data before freeing the document.
The input data must be padded by at least `YYJSON_PADDING_SIZE` bytes.
For example: `[1,2]` should be `[1,2]\0\0\0\0`, input length should be 5. */
YYJSON_READ_INSITU: yyjson_read_flag : 1 << 0;

/** Stop when done instead of issuing an error if there's additional content
after a JSON document. This option may be used to parse small pieces of JSON
in larger data, such as `NDJSON`. */
YYJSON_READ_STOP_WHEN_DONE: yyjson_read_flag : 1 << 1;

/** Allow single trailing comma at the end of an object or array,
such as `[1,2,3,]`, `{"a":1,"b":2,}` (non-standard). */
YYJSON_READ_ALLOW_TRAILING_COMMAS: yyjson_read_flag : 1 << 2;

/** Allow C-style single-line and multi-line comments (non-standard). */
YYJSON_READ_ALLOW_COMMENTS: yyjson_read_flag : 1 << 3;

/** Allow inf/nan number and literal, case-insensitive,
such as 1e999, NaN, inf, -Infinity (non-standard). */
YYJSON_READ_ALLOW_INF_AND_NAN: yyjson_read_flag : 1 << 4;

/** Read all numbers as raw strings (value with `YYJSON_TYPE_RAW` type),
inf/nan literal is also read as raw with `ALLOW_INF_AND_NAN` flag. */
YYJSON_READ_NUMBER_AS_RAW: yyjson_read_flag : 1 << 5;

/** Allow reading invalid unicode when parsing string values (non-standard).
Invalid characters will be allowed to appear in the string values, but
invalid escape sequences will still be reported as errors.
This flag does not affect the performance of correctly encoded strings.

@warning Strings in JSON values may contain incorrect encoding when this
option is used, you need to handle these strings carefully to avoid security
risks. */
YYJSON_READ_ALLOW_INVALID_UNICODE: yyjson_read_flag : 1 << 6;

/** Read big numbers as raw strings. These big numbers include integers that
cannot be represented by `int64_t` and `uint64_t`, and floating-point
numbers that cannot be represented by finite `double`.
The flag will be overridden by `YYJSON_READ_NUMBER_AS_RAW` flag. */
YYJSON_READ_BIGNUM_AS_RAW: yyjson_read_flag : 1 << 7;

/** Allow UTF-8 BOM and skip it before parsing if any (non-standard). */
YYJSON_READ_ALLOW_BOM: yyjson_read_flag : 1 << 8;

/** Allow extended number formats (non-standard):
- Hexadecimal numbers, such as `0x7B`.
- Numbers with leading or trailing decimal point, such as `.123`, `123.`.
- Numbers with a leading plus sign, such as `+123`. */
YYJSON_READ_ALLOW_EXT_NUMBER: yyjson_read_flag : 1 << 9;

/** Allow extended escape sequences in strings (non-standard):
- Additional escapes: `\a`, `\e`, `\v`, ``\'``, `\?`, `\0`.
- Hex escapes: `\xNN`, such as `\x7B`.
- Line continuation: backslash followed by line terminator sequences.
- Unknown escape: if backslash is followed by an unsupported character,
the backslash will be removed and the character will be kept as-is.
However, `\1`-`\9` will still trigger an error. */
YYJSON_READ_ALLOW_EXT_ESCAPE: yyjson_read_flag : 1 << 10;

/** Allow extended whitespace characters (non-standard):
- Vertical tab `\v` and form feed `\f`.
- Line separator `\u2028` and paragraph separator `\u2029`.
- Non-breaking space `\xA0`.
- Byte order mark: `\uFEFF`.
- Other Unicode characters in the Zs (Separator, space) category. */
YYJSON_READ_ALLOW_EXT_WHITESPACE: yyjson_read_flag : 1 << 11;

/** Allow strings enclosed in single quotes (non-standard), such as ``'ab'``. */
YYJSON_READ_ALLOW_SINGLE_QUOTED_STR: yyjson_read_flag : 1 << 12;

/** Allow object keys without quotes (non-standard), such as `{a:1,b:2}`.
This extends the ECMAScript IdentifierName rule by allowing any
non-whitespace character with code point above `U+007F`. */
YYJSON_READ_ALLOW_UNQUOTED_KEY: yyjson_read_flag : 1 << 13;

/** Allow JSON5 format, see: [https://json5.org].
This flag supports all JSON5 features with some additional extensions:
- Accepts more escape sequences than JSON5 (e.g. `\a`, `\e`).
- Unquoted keys are not limited to ECMAScript IdentifierName.
- Allow case-insensitive `NaN`, `Inf` and `Infinity` literals. */
YYJSON_READ_JSON5: yyjson_read_flag : (1 << 2) |/* YYJSON_READ_ALLOW_TRAILING_COMMAS */ (1 << 3) |/* YYJSON_READ_ALLOW_COMMENTS */ (1 << 4) |/* YYJSON_READ_ALLOW_INF_AND_NAN */ (1 << 9) |/* YYJSON_READ_ALLOW_EXT_NUMBER */ (1 << 10) |/* YYJSON_READ_ALLOW_EXT_ESCAPE */ (1 << 11) |/* YYJSON_READ_ALLOW_EXT_WHITESPACE */ (1 << 12) |/* YYJSON_READ_ALLOW_SINGLE_QUOTED_STR */ (1 << 13);

/** Result code for JSON reader. */
yyjson_read_code :: u32;

/** Success, no error. */
YYJSON_READ_SUCCESS: yyjson_read_code : 0;

/** Invalid parameter, such as NULL input string or 0 input length. */
YYJSON_READ_ERROR_INVALID_PARAMETER: yyjson_read_code : 1;

/** Memory allocation failed. */
YYJSON_READ_ERROR_MEMORY_ALLOCATION: yyjson_read_code : 2;

/** Input JSON string is empty. */
YYJSON_READ_ERROR_EMPTY_CONTENT: yyjson_read_code : 3;

/** Unexpected content after document, such as `[123]abc`. */
YYJSON_READ_ERROR_UNEXPECTED_CONTENT: yyjson_read_code : 4;

/** Unexpected end of input, the parsed part is valid, such as `[123`. */
YYJSON_READ_ERROR_UNEXPECTED_END: yyjson_read_code : 5;

/** Unexpected character inside the document, such as `[abc]`. */
YYJSON_READ_ERROR_UNEXPECTED_CHARACTER: yyjson_read_code : 6;

/** Invalid JSON structure, such as `[1,]`. */
YYJSON_READ_ERROR_JSON_STRUCTURE: yyjson_read_code : 7;

/** Invalid comment, deprecated, use `UNEXPECTED_END` for unclosed comment. */
YYJSON_READ_ERROR_INVALID_COMMENT: yyjson_read_code : 8;

/** Invalid number, such as `123.e12`, `000`. */
YYJSON_READ_ERROR_INVALID_NUMBER: yyjson_read_code : 9;

/** Invalid string, such as invalid escaped character inside a string. */
YYJSON_READ_ERROR_INVALID_STRING: yyjson_read_code : 10;

/** Invalid JSON literal, such as `truu`. */
YYJSON_READ_ERROR_LITERAL: yyjson_read_code : 11;

/** Failed to open a file. */
YYJSON_READ_ERROR_FILE_OPEN: yyjson_read_code : 12;

/** Failed to read a file. */
YYJSON_READ_ERROR_FILE_READ: yyjson_read_code : 13;

/** Incomplete input during incremental parsing; parsing state is preserved. */
YYJSON_READ_ERROR_MORE: yyjson_read_code : 14;

/** Read depth limit exceeded. */
YYJSON_READ_ERROR_DEPTH: yyjson_read_code : 15;

/** Error information for JSON reader. */
yyjson_read_err :: struct {
    /** Error code, see `yyjson_read_code` for all possible values. */
    code: yyjson_read_code;

    /** Error message, constant, no need to free (NULL if success). */
    msg:  *u8;

    /** Error byte position for input data (0 if success). */
    pos:  u64;
}

/**
Read JSON with options.

This function is thread-safe when:
1. The `dat` is not modified by other threads.
2. The `alc` is thread-safe or NULL.

@param dat The JSON data (UTF-8 without BOM), null-terminator is not required.
If `dat` is NULL, returns NULL.
The `dat` will not be modified without the flag `YYJSON_READ_INSITU`, so you
can pass a `const char *` string and cast it to `char *` if you don't use
the `YYJSON_READ_INSITU` flag.
@param len The length of JSON data in bytes.
If `len` is 0, returns NULL.
@param flg The JSON read options.
Multiple options can be combined with `|` operator. 0 means no options.
@param alc The memory allocator used by JSON reader.
Pass NULL to use the libc's default allocator.
@param err A pointer to receive error information.
Pass NULL if you don't need error information.
@return A new JSON document, or NULL if an error occurs.
When it's no longer needed, it should be freed with `yyjson_doc_free()`.
*/
yyjson_read_opts :: (dat: *u8, len: u64, flg: yyjson_read_flag, alc: *yyjson_alc, err: *yyjson_read_err) -> *yyjson_doc #foreign libyyjson;

/**
Read a JSON file.

This function is thread-safe when:
1. The file is not modified by other threads.
2. The `alc` is thread-safe or NULL.

@param path The JSON file's path.
This should be a null-terminated string using the system's native encoding.
If `path` is NULL or invalid, returns NULL.
@param flg The JSON read options.
Multiple options can be combined with `|` operator. 0 means no options.
@param alc The memory allocator used by JSON reader.
Pass NULL to use the libc's default allocator.
@param err A pointer to receive error information.
Pass NULL if you don't need error information.
@return A new JSON document, or NULL if an error occurs.
When it's no longer needed, it should be freed with `yyjson_doc_free()`.

@warning On 32-bit operating system, files larger than 2GB may fail to read.
*/
yyjson_read_file :: (path: *u8, flg: yyjson_read_flag, alc: *yyjson_alc, err: *yyjson_read_err) -> *yyjson_doc #foreign libyyjson;

/**
Read JSON from a file pointer.

@param fp The file pointer.
The data will be read from the current position of the FILE to the end.
If `fp` is NULL or invalid, returns NULL.
@param flg The JSON read options.
Multiple options can be combined with `|` operator. 0 means no options.
@param alc The memory allocator used by JSON reader.
Pass NULL to use the libc's default allocator.
@param err A pointer to receive error information.
Pass NULL if you don't need error information.
@return A new JSON document, or NULL if an error occurs.
When it's no longer needed, it should be freed with `yyjson_doc_free()`.

@warning On 32-bit operating system, files larger than 2GB may fail to read.
*/
yyjson_read_fp :: (fp: *FILE, flg: yyjson_read_flag, alc: *yyjson_alc, err: *yyjson_read_err) -> *yyjson_doc #foreign libyyjson;

/**
Read a JSON string.

This function is thread-safe.

@param dat The JSON data (UTF-8 without BOM), null-terminator is not required.
If `dat` is NULL, returns NULL.
@param len The length of JSON data in bytes.
If `len` is 0, returns NULL.
@param flg The JSON read options.
Multiple options can be combined with `|` operator. 0 means no options.
@return A new JSON document, or NULL if an error occurs.
When it's no longer needed, it should be freed with `yyjson_doc_free()`.
*/
yyjson_read :: (dat: *u8, len: u64, flg: yyjson_read_flag) -> *yyjson_doc #foreign libyyjson;

yyjson_incr_state :: struct {}

/**
Initialize state for incremental read.

To read a large JSON document incrementally:
1. Call `yyjson_incr_new()` to create the state for incremental reading.
2. Call `yyjson_incr_read()` repeatedly.
3. Call `yyjson_incr_free()` to free the state.

Note: The incremental JSON reader only supports standard JSON.
Flags for non-standard features (e.g. comments, trailing commas) are ignored.

@param buf The JSON data, null-terminator is not required.
If `buf` is NULL, returns NULL.
@param buf_len The length of the JSON data in `buf`.
If using `YYJSON_READ_INSITU`, buf_len should not include the padding size.
@param flg The JSON read options.
Multiple options can be combined with `|` operator.
@param alc The memory allocator used by JSON reader.
Pass NULL to use the libc's default allocator.
@return A state for incremental reading.
It should be freed with `yyjson_incr_free()`.
NULL is returned if memory allocation fails.
*/
yyjson_incr_new :: (buf: *u8, buf_len: u64, flg: yyjson_read_flag, alc: *yyjson_alc) -> *yyjson_incr_state #foreign libyyjson;

/**
Performs incremental read of up to `len` bytes.

If NULL is returned and `err->code` is set to `YYJSON_READ_ERROR_MORE`, it
indicates that more data is required to continue parsing. Then, call this
function again with incremented `len`. Continue until a document is returned or
an error other than `YYJSON_READ_ERROR_MORE` is returned.

Note: Parsing in very small increments is not efficient. An increment of
several kilobytes or megabytes is recommended.

@param state The state for incremental reading, created using
`yyjson_incr_new()`.
@param len The number of bytes of JSON data available to parse.
If `len` is 0, returns NULL.
@param err A pointer to receive error information.
@return A new JSON document, or NULL if an error occurs.
When the document is no longer needed, it should be freed with
`yyjson_doc_free()`.
*/
yyjson_incr_read :: (state: *yyjson_incr_state, len: u64, err: *yyjson_read_err) -> *yyjson_doc #foreign libyyjson;

/** Release the incremental read state and free the memory. */
yyjson_incr_free :: (state: *yyjson_incr_state) -> void #foreign libyyjson;

/**
Returns the maximum memory usage to read a JSON document.

You may use this value to avoid malloc() or calloc() call inside the reader
to get better performance, or read multiple JSON with one piece of memory.

@param len The length of JSON data in bytes.
@param flg The JSON read options.
@return The maximum memory size to read this JSON, or 0 if overflow.

@b Example
@code
// read multiple JSON with same pre-allocated memory

char *dat1, *dat2, *dat3; // JSON data
size_t len1, len2, len3; // JSON length
size_t max_len = MAX(len1, MAX(len2, len3));
yyjson_doc *doc;

// use one allocator for multiple JSON
size_t size = yyjson_read_max_memory_usage(max_len, 0);
void *buf = malloc(size);
yyjson_alc alc;
yyjson_alc_pool_init(&alc, buf, size);

// no more malloc() or realloc() call during reading
doc = yyjson_read_opts(dat1, len1, 0, &alc, NULL);
yyjson_doc_free(doc);
doc = yyjson_read_opts(dat2, len2, 0, &alc, NULL);
yyjson_doc_free(doc);
doc = yyjson_read_opts(dat3, len3, 0, &alc, NULL);
yyjson_doc_free(doc);

free(buf);
@endcode
@see yyjson_alc_pool_init()
*/
yyjson_read_max_memory_usage :: (len: u64, flg: yyjson_read_flag) -> u64 #foreign libyyjson;

/**
Read a JSON number.

This function is thread-safe when data is not modified by other threads.

@param dat The JSON data (UTF-8 without BOM), null-terminator is required.
If `dat` is NULL, returns NULL.
@param val The output value where result is stored.
If `val` is NULL, returns NULL.
The value will hold either UINT or SINT or REAL number;
@param flg The JSON read options.
Multiple options can be combined with `|` operator. 0 means no options.
Supports `YYJSON_READ_NUMBER_AS_RAW` and `YYJSON_READ_ALLOW_INF_AND_NAN`.
@param alc The memory allocator used for long number.
It is only used when the built-in floating point reader is disabled.
Pass NULL to use the libc's default allocator.
@param err A pointer to receive error information.
Pass NULL if you don't need error information.
@return If successful, a pointer to the character after the last character
used in the conversion, NULL if an error occurs.
*/
yyjson_read_number :: (dat: *u8, val: *yyjson_val, flg: yyjson_read_flag, alc: *yyjson_alc, err: *yyjson_read_err) -> *u8 #foreign libyyjson;

/** Same as `yyjson_read_number()`. */
yyjson_mut_read_number :: (dat: *u8, val: *yyjson_mut_val, flg: yyjson_read_flag, alc: *yyjson_alc, err: *yyjson_read_err) -> *u8 #foreign libyyjson;

/** Run-time options for JSON writer. */
yyjson_write_flag :: u32;

/** Default option:
- Write JSON minify.
- Report error on inf or nan number.
- Report error on invalid UTF-8 string.
- Do not escape unicode or slash. */
YYJSON_WRITE_NOFLAG: yyjson_write_flag : 0;

/** Write JSON pretty with 4 space indent. */
YYJSON_WRITE_PRETTY: yyjson_write_flag : 1 << 0;

/** Escape unicode as `uXXXX`, make the output ASCII only. */
YYJSON_WRITE_ESCAPE_UNICODE: yyjson_write_flag : 1 << 1;

/** Escape '/' as '\/'. */
YYJSON_WRITE_ESCAPE_SLASHES: yyjson_write_flag : 1 << 2;

/** Write inf and nan number as 'Infinity' and 'NaN' literal (non-standard). */
YYJSON_WRITE_ALLOW_INF_AND_NAN: yyjson_write_flag : 1 << 3;

/** Write inf and nan number as null literal.
This flag will override `YYJSON_WRITE_ALLOW_INF_AND_NAN` flag. */
YYJSON_WRITE_INF_AND_NAN_AS_NULL: yyjson_write_flag : 1 << 4;

/** Allow invalid unicode when encoding string values (non-standard).
Invalid characters in string value will be copied byte by byte.
If `YYJSON_WRITE_ESCAPE_UNICODE` flag is also set, invalid character will be
escaped as `U+FFFD` (replacement character).
This flag does not affect the performance of correctly encoded strings. */
YYJSON_WRITE_ALLOW_INVALID_UNICODE: yyjson_write_flag : 1 << 5;

/** Write JSON pretty with 2 space indent.
This flag will override `YYJSON_WRITE_PRETTY` flag. */
YYJSON_WRITE_PRETTY_TWO_SPACES: yyjson_write_flag : 1 << 6;

/** Adds a newline character `\n` at the end of the JSON.
This can be helpful for text editors or NDJSON. */
YYJSON_WRITE_NEWLINE_AT_END: yyjson_write_flag : 1 << 7;

/** Use lowercase hex digits in `\uXXXX` escape sequences instead of the default
uppercase. Only effective when `YYJSON_WRITE_ESCAPE_UNICODE` is also set. */
YYJSON_WRITE_LOWERCASE_HEX: yyjson_write_flag : 1 << 8;

/** Result code for JSON writer */
yyjson_write_code :: u32;

/** Success, no error. */
YYJSON_WRITE_SUCCESS: yyjson_write_code : 0;

/** Invalid parameter, such as NULL document. */
YYJSON_WRITE_ERROR_INVALID_PARAMETER: yyjson_write_code : 1;

/** Memory allocation failed. */
YYJSON_WRITE_ERROR_MEMORY_ALLOCATION: yyjson_write_code : 2;

/** Invalid value type in JSON document. */
YYJSON_WRITE_ERROR_INVALID_VALUE_TYPE: yyjson_write_code : 3;

/** NaN or Infinity number occurs. */
YYJSON_WRITE_ERROR_NAN_OR_INF: yyjson_write_code : 4;

/** Failed to open a file. */
YYJSON_WRITE_ERROR_FILE_OPEN: yyjson_write_code : 5;

/** Failed to write a file. */
YYJSON_WRITE_ERROR_FILE_WRITE: yyjson_write_code : 6;

/** Invalid unicode in string. */
YYJSON_WRITE_ERROR_INVALID_STRING: yyjson_write_code : 7;

/** Nesting depth limit exceeded. */
YYJSON_WRITE_ERROR_DEPTH: yyjson_write_code : 8;

/** Error information for JSON writer. */
yyjson_write_err :: struct {
    /** Error code, see `yyjson_write_code` for all possible values. */
    code: yyjson_write_code;

    /** Error message, constant, no need to free (NULL if success). */
    msg:  *u8;
}

/**
Write a document to JSON string with options.

This function is thread-safe when:
The `alc` is thread-safe or NULL.

@param doc The JSON document.
If `doc` is NULL or has no root, returns NULL.
@param flg The JSON write options.
Multiple options can be combined with `|` operator. 0 means no options.
@param alc The memory allocator used by JSON writer.
Pass NULL to use the libc's default allocator.
@param len A pointer to receive output length in bytes (not including the
null-terminator). Pass NULL if you don't need length information.
@param err A pointer to receive error information.
Pass NULL if you don't need error information.
@return A new JSON string, or NULL if an error occurs.
This string is encoded as UTF-8 with a null-terminator.
When it's no longer needed, it should be freed with free() or alc->free().
*/
yyjson_write_opts :: (doc: *yyjson_doc, flg: yyjson_write_flag, alc: *yyjson_alc, len: *u64, err: *yyjson_write_err) -> *u8 #foreign libyyjson;

/**
Write a document to JSON file with options.

This function is thread-safe when:
1. The file is not accessed by other threads.
2. The `alc` is thread-safe or NULL.

@param path The JSON file's path.
This should be a null-terminated string using the system's native encoding.
If `path` is NULL or invalid, returns false.
If the file is not empty, its content is discarded.
@param doc The JSON document.
If `doc` is NULL or has no root, returns false.
@param flg The JSON write options.
Multiple options can be combined with `|` operator. 0 means no options.
@param alc The memory allocator used by JSON writer.
Pass NULL to use the libc's default allocator.
@param err A pointer to receive error information.
Pass NULL if you don't need error information.
@return true if successful, false if an error occurs.

@warning On 32-bit operating system, files larger than 2GB may fail to write.
*/
yyjson_write_file :: (path: *u8, doc: *yyjson_doc, flg: yyjson_write_flag, alc: *yyjson_alc, err: *yyjson_write_err) -> bool #foreign libyyjson;

/**
Write a document to file pointer with options.

@param fp The file pointer.
The data will be written to the current position of the file.
If `fp` is NULL or invalid, returns false.
@param doc The JSON document.
If `doc` is NULL or has no root, returns false.
@param flg The JSON write options.
Multiple options can be combined with `|` operator. 0 means no options.
@param alc The memory allocator used by JSON writer.
Pass NULL to use the libc's default allocator.
@param err A pointer to receive error information.
Pass NULL if you don't need error information.
@return true if successful, false if an error occurs.

@warning On 32-bit operating system, files larger than 2GB may fail to write.
*/
yyjson_write_fp :: (fp: *FILE, doc: *yyjson_doc, flg: yyjson_write_flag, alc: *yyjson_alc, err: *yyjson_write_err) -> bool #foreign libyyjson;

/**
Write a document into a buffer.

This function does not allocate memory, but the buffer must be larger than the
final JSON size to allow temporary space. See `API.md` for details.

@param buf The output buffer.
If `buf` is NULL, returns 0.
@param buf_len The buffer length.
If `buf_len` is too small, returns 0.
@param doc The JSON document.
If `doc` is NULL or has no root, returns 0.
@param flg The JSON write options.
Multiple options can be combined with `|` operator. 0 means no options.
@param err A pointer to receive error information.
Pass NULL if you don't need error information.
@return The number of bytes written (excluding the null terminator),
or 0 on failure.
*/
yyjson_write_buf :: (buf: *u8, buf_len: u64, doc: *yyjson_doc, flg: yyjson_write_flag, err: *yyjson_write_err) -> u64 #foreign libyyjson;

/**
Write a document to JSON string.

This function is thread-safe.

@param doc The JSON document.
If `doc` is NULL or has no root, returns NULL.
@param flg The JSON write options.
Multiple options can be combined with `|` operator. 0 means no options.
@param len A pointer to receive output length in bytes (not including the
null-terminator). Pass NULL if you don't need length information.
@return A new JSON string, or NULL if an error occurs.
This string is encoded as UTF-8 with a null-terminator.
When it's no longer needed, it should be freed with free().
*/
yyjson_write :: (doc: *yyjson_doc, flg: yyjson_write_flag, len: *u64) -> *u8 #foreign libyyjson;

/**
Write a document to JSON string with options.

This function is thread-safe when:
1. The `doc` is not modified by other threads.
2. The `alc` is thread-safe or NULL.

@param doc The mutable JSON document.
If `doc` is NULL or has no root, returns NULL.
@param flg The JSON write options.
Multiple options can be combined with `|` operator. 0 means no options.
@param alc The memory allocator used by JSON writer.
Pass NULL to use the libc's default allocator.
@param len A pointer to receive output length in bytes (not including the
null-terminator). Pass NULL if you don't need length information.
@param err A pointer to receive error information.
Pass NULL if you don't need error information.
@return A new JSON string, or NULL if an error occurs.
This string is encoded as UTF-8 with a null-terminator.
When it's no longer needed, it should be freed with free() or alc->free().
*/
yyjson_mut_write_opts :: (doc: *yyjson_mut_doc, flg: yyjson_write_flag, alc: *yyjson_alc, len: *u64, err: *yyjson_write_err) -> *u8 #foreign libyyjson;

/**
Write a document to JSON file with options.

This function is thread-safe when:
1. The file is not accessed by other threads.
2. The `doc` is not modified by other threads.
3. The `alc` is thread-safe or NULL.

@param path The JSON file's path.
This should be a null-terminated string using the system's native encoding.
If `path` is NULL or invalid, returns false.
If the file is not empty, its content is discarded.
@param doc The mutable JSON document.
If `doc` is NULL or has no root, returns false.
@param flg The JSON write options.
Multiple options can be combined with `|` operator. 0 means no options.
@param alc The memory allocator used by JSON writer.
Pass NULL to use the libc's default allocator.
@param err A pointer to receive error information.
Pass NULL if you don't need error information.
@return true if successful, false if an error occurs.

@warning On 32-bit operating system, files larger than 2GB may fail to write.
*/
yyjson_mut_write_file :: (path: *u8, doc: *yyjson_mut_doc, flg: yyjson_write_flag, alc: *yyjson_alc, err: *yyjson_write_err) -> bool #foreign libyyjson;

/**
Write a document to file pointer with options.

@param fp The file pointer.
The data will be written to the current position of the file.
If `fp` is NULL or invalid, returns false.
@param doc The mutable JSON document.
If `doc` is NULL or has no root, returns false.
@param flg The JSON write options.
Multiple options can be combined with `|` operator. 0 means no options.
@param alc The memory allocator used by JSON writer.
Pass NULL to use the libc's default allocator.
@param err A pointer to receive error information.
Pass NULL if you don't need error information.
@return true if successful, false if an error occurs.

@warning On 32-bit operating system, files larger than 2GB may fail to write.
*/
yyjson_mut_write_fp :: (fp: *FILE, doc: *yyjson_mut_doc, flg: yyjson_write_flag, alc: *yyjson_alc, err: *yyjson_write_err) -> bool #foreign libyyjson;

/**
Write a document into a buffer.

This function does not allocate memory, but the buffer must be larger than the
final JSON size to allow temporary space. See `API.md` for details.

@param buf The output buffer.
If `buf` is NULL, returns 0.
@param buf_len The buffer length.
If `buf_len` is too small, returns 0.
@param doc The JSON document.
If `doc` is NULL or has no root, returns 0.
@param flg The JSON write options.
Multiple options can be combined with `|` operator. 0 means no options.
@param err A pointer to receive error information.
Pass NULL if you don't need error information.
@return The number of bytes written (excluding the null terminator),
or 0 on failure.
*/
yyjson_mut_write_buf :: (buf: *u8, buf_len: u64, doc: *yyjson_mut_doc, flg: yyjson_write_flag, err: *yyjson_write_err) -> u64 #foreign libyyjson;

/**
Write a document to JSON string.

This function is thread-safe when:
The `doc` is not modified by other threads.

@param doc The JSON document.
If `doc` is NULL or has no root, returns NULL.
@param flg The JSON write options.
Multiple options can be combined with `|` operator. 0 means no options.
@param len A pointer to receive output length in bytes (not including the
null-terminator). Pass NULL if you don't need length information.
@return A new JSON string, or NULL if an error occurs.
This string is encoded as UTF-8 with a null-terminator.
When it's no longer needed, it should be freed with free().
*/
yyjson_mut_write :: (doc: *yyjson_mut_doc, flg: yyjson_write_flag, len: *u64) -> *u8 #foreign libyyjson;

/**
Write a value to JSON string with options.

This function is thread-safe when:
The `alc` is thread-safe or NULL.

@param val The JSON root value.
If `val` is NULL, returns NULL.
@param flg The JSON write options.
Multiple options can be combined with `|` operator. 0 means no options.
@param alc The memory allocator used by JSON writer.
Pass NULL to use the libc's default allocator.
@param len A pointer to receive output length in bytes (not including the
null-terminator). Pass NULL if you don't need length information.
@param err A pointer to receive error information.
Pass NULL if you don't need error information.
@return A new JSON string, or NULL if an error occurs.
This string is encoded as UTF-8 with a null-terminator.
When it's no longer needed, it should be freed with free() or alc->free().
*/
yyjson_val_write_opts :: (val: *yyjson_val, flg: yyjson_write_flag, alc: *yyjson_alc, len: *u64, err: *yyjson_write_err) -> *u8 #foreign libyyjson;

/**
Write a value to JSON file with options.

This function is thread-safe when:
1. The file is not accessed by other threads.
2. The `alc` is thread-safe or NULL.

@param path The JSON file's path.
This should be a null-terminated string using the system's native encoding.
If `path` is NULL or invalid, returns false.
If the file is not empty, its content is discarded.
@param val The JSON root value.
If `val` is NULL, returns false.
@param flg The JSON write options.
Multiple options can be combined with `|` operator. 0 means no options.
@param alc The memory allocator used by JSON writer.
Pass NULL to use the libc's default allocator.
@param err A pointer to receive error information.
Pass NULL if you don't need error information.
@return true if successful, false if an error occurs.

@warning On 32-bit operating system, files larger than 2GB may fail to write.
*/
yyjson_val_write_file :: (path: *u8, val: *yyjson_val, flg: yyjson_write_flag, alc: *yyjson_alc, err: *yyjson_write_err) -> bool #foreign libyyjson;

/**
Write a value to file pointer with options.

@param fp The file pointer.
The data will be written to the current position of the file.
If `fp` is NULL or invalid, returns false.
@param val The JSON root value.
If `val` is NULL, returns false.
@param flg The JSON write options.
Multiple options can be combined with `|` operator. 0 means no options.
@param alc The memory allocator used by JSON writer.
Pass NULL to use the libc's default allocator.
@param err A pointer to receive error information.
Pass NULL if you don't need error information.
@return true if successful, false if an error occurs.

@warning On 32-bit operating system, files larger than 2GB may fail to write.
*/
yyjson_val_write_fp :: (fp: *FILE, val: *yyjson_val, flg: yyjson_write_flag, alc: *yyjson_alc, err: *yyjson_write_err) -> bool #foreign libyyjson;

/**
Write a value into a buffer.

This function does not allocate memory, but the buffer must be larger than the
final JSON size to allow temporary space. See `API.md` for details.

@param buf The output buffer.
If `buf` is NULL, returns 0.
@param buf_len The buffer length.
If `buf_len` is too small, returns 0.
@param val The JSON root value.
If `val` is NULL, returns 0.
@param flg The JSON write options.
Multiple options can be combined with `|` operator. 0 means no options.
@param err A pointer to receive error information.
Pass NULL if you don't need error information.
@return The number of bytes written (excluding the null terminator),
or 0 on failure.
*/
yyjson_val_write_buf :: (buf: *u8, buf_len: u64, val: *yyjson_val, flg: yyjson_write_flag, err: *yyjson_write_err) -> u64 #foreign libyyjson;

/**
Write a value to JSON string.

This function is thread-safe.

@param val The JSON root value.
If `val` is NULL, returns NULL.
@param flg The JSON write options.
Multiple options can be combined with `|` operator. 0 means no options.
@param len A pointer to receive output length in bytes (not including the
null-terminator). Pass NULL if you don't need length information.
@return A new JSON string, or NULL if an error occurs.
This string is encoded as UTF-8 with a null-terminator.
When it's no longer needed, it should be freed with free().
*/
yyjson_val_write :: (val: *yyjson_val, flg: yyjson_write_flag, len: *u64) -> *u8 #foreign libyyjson;

/**
Write a value to JSON string with options.

This function is thread-safe when:
1. The `val` is not modified by other threads.
2. The `alc` is thread-safe or NULL.

@param val The mutable JSON root value.
If `val` is NULL, returns NULL.
@param flg The JSON write options.
Multiple options can be combined with `|` operator. 0 means no options.
@param alc The memory allocator used by JSON writer.
Pass NULL to use the libc's default allocator.
@param len A pointer to receive output length in bytes (not including the
null-terminator). Pass NULL if you don't need length information.
@param err A pointer to receive error information.
Pass NULL if you don't need error information.
@return A new JSON string, or NULL if an error occurs.
This string is encoded as UTF-8 with a null-terminator.
When it's no longer needed, it should be freed with free() or alc->free().
*/
yyjson_mut_val_write_opts :: (val: *yyjson_mut_val, flg: yyjson_write_flag, alc: *yyjson_alc, len: *u64, err: *yyjson_write_err) -> *u8 #foreign libyyjson;

/**
Write a value to JSON file with options.

This function is thread-safe when:
1. The file is not accessed by other threads.
2. The `val` is not modified by other threads.
3. The `alc` is thread-safe or NULL.

@param path The JSON file's path.
This should be a null-terminated string using the system's native encoding.
If `path` is NULL or invalid, returns false.
If the file is not empty, its content is discarded.
@param val The mutable JSON root value.
If `val` is NULL, returns false.
@param flg The JSON write options.
Multiple options can be combined with `|` operator. 0 means no options.
@param alc The memory allocator used by JSON writer.
Pass NULL to use the libc's default allocator.
@param err A pointer to receive error information.
Pass NULL if you don't need error information.
@return true if successful, false if an error occurs.

@warning On 32-bit operating system, files larger than 2GB may fail to write.
*/
yyjson_mut_val_write_file :: (path: *u8, val: *yyjson_mut_val, flg: yyjson_write_flag, alc: *yyjson_alc, err: *yyjson_write_err) -> bool #foreign libyyjson;

/**
Write a value to file pointer with options.

@param fp The file pointer.
The data will be written to the current position of the file.
If `fp` is NULL or invalid, returns false.
@param val The mutable JSON root value.
If `val` is NULL, returns false.
@param flg The JSON write options.
Multiple options can be combined with `|` operator. 0 means no options.
@param alc The memory allocator used by JSON writer.
Pass NULL to use the libc's default allocator.
@param err A pointer to receive error information.
Pass NULL if you don't need error information.
@return true if successful, false if an error occurs.

@warning On 32-bit operating system, files larger than 2GB may fail to write.
*/
yyjson_mut_val_write_fp :: (fp: *FILE, val: *yyjson_mut_val, flg: yyjson_write_flag, alc: *yyjson_alc, err: *yyjson_write_err) -> bool #foreign libyyjson;

/**
Write a value into a buffer.

This function does not allocate memory, but the buffer must be larger than the
final JSON size to allow temporary space. See `API.md` for details.

@param buf The output buffer.
If `buf` is NULL, returns 0.
@param buf_len The buffer length.
If `buf_len` is too small, returns 0.
@param val The JSON root value.
If `val` is NULL, returns 0.
@param flg The JSON write options.
Multiple options can be combined with `|` operator. 0 means no options.
@param err A pointer to receive error information.
Pass NULL if you don't need error information.
@return The number of bytes written (excluding the null terminator),
or 0 on failure.
*/
yyjson_mut_val_write_buf :: (buf: *u8, buf_len: u64, val: *yyjson_mut_val, flg: yyjson_write_flag, err: *yyjson_write_err) -> u64 #foreign libyyjson;

/**
Write a value to JSON string.

This function is thread-safe when:
The `val` is not modified by other threads.

@param val The JSON root value.
If `val` is NULL, returns NULL.
@param flg The JSON write options.
Multiple options can be combined with `|` operator. 0 means no options.
@param len A pointer to receive output length in bytes (not including the
null-terminator). Pass NULL if you don't need length information.
@return A new JSON string, or NULL if an error occurs.
This string is encoded as UTF-8 with a null-terminator.
When it's no longer needed, it should be freed with free().
*/
yyjson_mut_val_write :: (val: *yyjson_mut_val, flg: yyjson_write_flag, len: *u64) -> *u8 #foreign libyyjson;

/**
Write a JSON number.

@param val A JSON number value to be converted to a string.
If `val` is invalid, returns NULL.
@param buf A buffer to store the resulting null-terminated string.
If `buf` is NULL, returns NULL.
For integer values, the buffer must be at least 21 bytes.
For floating-point values, the buffer must be at least 40 bytes.
@return On success, returns a pointer to the character after the last
written character. On failure, returns NULL.
@note
- This function is thread-safe and does not allocate memory
(when `YYJSON_DISABLE_FAST_FP_CONV` is not defined).
- This function will fail and return NULL only in the following cases:
1) `val` or `buf` is NULL;
2) `val` is not a number type;
3) `val` is `inf` or `nan`, and non-standard JSON is explicitly disabled
via the `YYJSON_DISABLE_NON_STANDARD` flag.
*/
yyjson_write_number :: (val: *yyjson_val, buf: *u8) -> *u8 #foreign libyyjson;

/** Same as `yyjson_write_number()`. */
yyjson_mut_write_number :: (val: *yyjson_mut_val, buf: *u8) -> *u8 #foreign libyyjson;

/** Returns the root value of this JSON document.
Returns NULL if `doc` is NULL. */
yyjson_doc_get_root :: (doc: *yyjson_doc) -> *yyjson_val #foreign libyyjson;

/** Returns read size of input JSON data.
Returns 0 if `doc` is NULL.
For example: the read size of `[1,2,3]` is 7 bytes.  */
yyjson_doc_get_read_size :: (doc: *yyjson_doc) -> u64 #foreign libyyjson;

/** Returns total value count in this JSON document.
Returns 0 if `doc` is NULL.
For example: the value count of `[1,2,3]` is 4. */
yyjson_doc_get_val_count :: (doc: *yyjson_doc) -> u64 #foreign libyyjson;

/** Release the JSON document and free the memory.
After calling this function, the `doc` and all values from the `doc` are no
longer available. This function will do nothing if the `doc` is NULL. */
yyjson_doc_free :: (doc: *yyjson_doc) -> void #foreign libyyjson;

/** Returns whether the JSON value is raw.
Returns false if `val` is NULL. */
yyjson_is_raw :: (val: *yyjson_val) -> bool #foreign libyyjson;

/** Returns whether the JSON value is `null`.
Returns false if `val` is NULL. */
yyjson_is_null :: (val: *yyjson_val) -> bool #foreign libyyjson;

/** Returns whether the JSON value is `true`.
Returns false if `val` is NULL. */
yyjson_is_true :: (val: *yyjson_val) -> bool #foreign libyyjson;

/** Returns whether the JSON value is `false`.
Returns false if `val` is NULL. */
yyjson_is_false :: (val: *yyjson_val) -> bool #foreign libyyjson;

/** Returns whether the JSON value is bool (true/false).
Returns false if `val` is NULL. */
yyjson_is_bool :: (val: *yyjson_val) -> bool #foreign libyyjson;

/** Returns whether the JSON value is unsigned integer (uint64_t).
Returns false if `val` is NULL. */
yyjson_is_uint :: (val: *yyjson_val) -> bool #foreign libyyjson;

/** Returns whether the JSON value is signed integer (int64_t).
Returns false if `val` is NULL. */
yyjson_is_sint :: (val: *yyjson_val) -> bool #foreign libyyjson;

/** Returns whether the JSON value is integer (uint64_t/int64_t).
Returns false if `val` is NULL. */
yyjson_is_int :: (val: *yyjson_val) -> bool #foreign libyyjson;

/** Returns whether the JSON value is real number (double).
Returns false if `val` is NULL. */
yyjson_is_real :: (val: *yyjson_val) -> bool #foreign libyyjson;

/** Returns whether the JSON value is number (uint64_t/int64_t/double).
Returns false if `val` is NULL. */
yyjson_is_num :: (val: *yyjson_val) -> bool #foreign libyyjson;

/** Returns whether the JSON value is string.
Returns false if `val` is NULL. */
yyjson_is_str :: (val: *yyjson_val) -> bool #foreign libyyjson;

/** Returns whether the JSON value is array.
Returns false if `val` is NULL. */
yyjson_is_arr :: (val: *yyjson_val) -> bool #foreign libyyjson;

/** Returns whether the JSON value is object.
Returns false if `val` is NULL. */
yyjson_is_obj :: (val: *yyjson_val) -> bool #foreign libyyjson;

/** Returns whether the JSON value is container (array/object).
Returns false if `val` is NULL. */
yyjson_is_ctn :: (val: *yyjson_val) -> bool #foreign libyyjson;

/** Returns the JSON value's type.
Returns YYJSON_TYPE_NONE if `val` is NULL. */
yyjson_get_type :: (val: *yyjson_val) -> yyjson_type #foreign libyyjson;

/** Returns the JSON value's subtype.
Returns YYJSON_SUBTYPE_NONE if `val` is NULL. */
yyjson_get_subtype :: (val: *yyjson_val) -> yyjson_subtype #foreign libyyjson;

/** Returns the JSON value's tag.
Returns 0 if `val` is NULL. */
yyjson_get_tag :: (val: *yyjson_val) -> u8 #foreign libyyjson;

/** Returns the JSON value's type description.
The return value should be one of these strings: "raw", "null", "string",
"array", "object", "true", "false", "uint", "sint", "real", "unknown". */
yyjson_get_type_desc :: (val: *yyjson_val) -> *u8 #foreign libyyjson;

/** Returns the content if the value is raw.
Returns NULL if `val` is NULL or type is not raw. */
yyjson_get_raw :: (val: *yyjson_val) -> *u8 #foreign libyyjson;

/** Returns the content if the value is bool.
Returns false if `val` is NULL or type is not bool. */
yyjson_get_bool :: (val: *yyjson_val) -> bool #foreign libyyjson;

/** Returns the content cast to uint64_t.
Returns 0 if `val` is NULL or type is not integer(sint/uint). */
yyjson_get_uint :: (val: *yyjson_val) -> u64 #foreign libyyjson;

/** Returns the content cast to int64_t.
Returns 0 if `val` is NULL or type is not integer(sint/uint). */
yyjson_get_sint :: (val: *yyjson_val) -> s64 #foreign libyyjson;

/** Returns the content cast to int (may overflow).
Returns 0 if `val` is NULL or type is not integer(sint/uint). */
yyjson_get_int :: (val: *yyjson_val) -> s32 #foreign libyyjson;

/** Returns the content if the value is real number, or 0.0 on error.
Returns 0.0 if `val` is NULL or type is not real(double). */
yyjson_get_real :: (val: *yyjson_val) -> float64 #foreign libyyjson;

/** Returns the content cast to `double` if the value is a number.
Returns 0.0 if `val` is NULL or type is not number(uint/sint/real). */
yyjson_get_num :: (val: *yyjson_val) -> float64 #foreign libyyjson;

/** Returns the content if the value is string.
Returns NULL if `val` is NULL or type is not string. */
yyjson_get_str :: (val: *yyjson_val) -> *u8 #foreign libyyjson;

/** Returns the content length for raw/string/array/object values.
Returns 0 if `val` is NULL.
The return value is unspecified for other types. */
yyjson_get_len :: (val: *yyjson_val) -> u64 #foreign libyyjson;

/** Returns whether the JSON value is equal to a string.
Returns false if `val` is NULL or type is not string. */
yyjson_equals_str :: (val: *yyjson_val, str: *u8) -> bool #foreign libyyjson;

/** Returns whether the JSON value is equal to a string.
The `str` should be a UTF-8 string, null-terminator is not required.
Returns false if `val` is NULL or type is not string. */
yyjson_equals_strn :: (val: *yyjson_val, str: *u8, len: u64) -> bool #foreign libyyjson;

/** Returns whether two JSON values are equal (deep compare).
Returns false if `lhs` or `rhs` is NULL.
@note the result may be inaccurate if object has duplicate keys.
@warning This function is recursive and may cause a stack overflow
if the object level is too deep. */
yyjson_equals :: (lhs: *yyjson_val, rhs: *yyjson_val) -> bool #foreign libyyjson;

/** Set the value to raw.
Returns false if `val` is NULL or is object or array.
@warning This will modify the `immutable` value, use with caution. */
yyjson_set_raw :: (val: *yyjson_val, raw: *u8, len: u64) -> bool #foreign libyyjson;

/** Set the value to null.
Returns false if `val` is NULL or is object or array.
@warning This will modify the `immutable` value, use with caution. */
yyjson_set_null :: (val: *yyjson_val) -> bool #foreign libyyjson;

/** Set the value to bool.
Returns false if `val` is NULL or is object or array.
@warning This will modify the `immutable` value, use with caution. */
yyjson_set_bool :: (val: *yyjson_val, num: bool) -> bool #foreign libyyjson;

/** Set the value to uint.
Returns false if `val` is NULL or is object or array.
@warning This will modify the `immutable` value, use with caution. */
yyjson_set_uint :: (val: *yyjson_val, num: u64) -> bool #foreign libyyjson;

/** Set the value to sint.
Returns false if `val` is NULL or is object or array.
@warning This will modify the `immutable` value, use with caution. */
yyjson_set_sint :: (val: *yyjson_val, num: s64) -> bool #foreign libyyjson;

/** Set the value to int.
Returns false if `val` is NULL or is object or array.
@warning This will modify the `immutable` value, use with caution. */
yyjson_set_int :: (val: *yyjson_val, num: s64) -> bool #foreign libyyjson;

/** Set the value to float.
Returns false if `val` is NULL or is object or array.
@warning This will modify the `immutable` value, use with caution. */
yyjson_set_float :: (val: *yyjson_val, num: float) -> bool #foreign libyyjson;

/** Set the value to double.
Returns false if `val` is NULL or is object or array.
@warning This will modify the `immutable` value, use with caution. */
yyjson_set_double :: (val: *yyjson_val, num: float64) -> bool #foreign libyyjson;

/** Set the value to real.
Returns false if `val` is NULL or is object or array.
@warning This will modify the `immutable` value, use with caution. */
yyjson_set_real :: (val: *yyjson_val, num: float64) -> bool #foreign libyyjson;

/** Set the floating-point number's output format to fixed-point notation.
Returns false if `val` is NULL or is not real type.
@see YYJSON_WRITE_FP_TO_FIXED flag.
@warning This will modify the `immutable` value, use with caution. */
yyjson_set_fp_to_fixed :: (val: *yyjson_val, prec: s32) -> bool #foreign libyyjson;

/** Set the floating-point number's output format to single-precision.
Returns false if `val` is NULL or is not real type.
@see YYJSON_WRITE_FP_TO_FLOAT flag.
@warning This will modify the `immutable` value, use with caution. */
yyjson_set_fp_to_float :: (val: *yyjson_val, flt: bool) -> bool #foreign libyyjson;

/** Set the value to string (null-terminated).
Returns false if `val` is NULL or is object or array.
@warning This will modify the `immutable` value, use with caution. */
yyjson_set_str :: (val: *yyjson_val, str: *u8) -> bool #foreign libyyjson;

/** Set the value to string (with length).
Returns false if `val` is NULL or is object or array.
@warning This will modify the `immutable` value, use with caution. */
yyjson_set_strn :: (val: *yyjson_val, str: *u8, len: u64) -> bool #foreign libyyjson;

/** Marks this string as not needing to be escaped during JSON writing.
This can be used to avoid the overhead of escaping if the string contains
only characters that do not require escaping.
Returns false if `val` is NULL or is not string.
@see YYJSON_SUBTYPE_NOESC subtype.
@warning This will modify the `immutable` value, use with caution. */
yyjson_set_str_noesc :: (val: *yyjson_val, noesc: bool) -> bool #foreign libyyjson;

/** Returns the number of elements in this array.
Returns 0 if `arr` is NULL or type is not array. */
yyjson_arr_size :: (arr: *yyjson_val) -> u64 #foreign libyyjson;

/** Returns the element at the specified position in this array.
Returns NULL if array is NULL/empty or the index is out of bounds.
@warning This function takes a linear search time if array is not flat.
For example: `[1,{},3]` is flat, `[1,[2],3]` is not flat. */
yyjson_arr_get :: (arr: *yyjson_val, idx: u64) -> *yyjson_val #foreign libyyjson;

/** Returns the first element of this array.
Returns NULL if `arr` is NULL/empty or type is not array. */
yyjson_arr_get_first :: (arr: *yyjson_val) -> *yyjson_val #foreign libyyjson;

/** Returns the last element of this array.
Returns NULL if `arr` is NULL/empty or type is not array.
@warning This function takes a linear search time if array is not flat.
For example: `[1,{},3]` is flat, `[1,[2],3]` is not flat.*/
yyjson_arr_get_last :: (arr: *yyjson_val) -> *yyjson_val #foreign libyyjson;

/**
A JSON array iterator.

@b Example
@code
yyjson_val *val;
yyjson_arr_iter iter = yyjson_arr_iter_with(arr);
while ((val = yyjson_arr_iter_next(&iter))) {
your_func(val);
}
@endcode
*/
yyjson_arr_iter :: struct {
    idx: u64; /**< next value's index */
    max: u64; /**< maximum index (arr.size) */
    cur: *yyjson_val; /**< next value */
}

/**
Initialize an iterator for this array.

@param arr The array to be iterated over.
If `arr` is NULL or not an array, `iter` is cleared.
@param iter The iterator to be initialized.
If `iter` is NULL, returns false.
@return true if the `iter` has been successfully initialized.

@note The iterator does not need to be destroyed.
*/
yyjson_arr_iter_init :: (arr: *yyjson_val, iter: *yyjson_arr_iter) -> bool #foreign libyyjson;

/**
Create an iterator with an array, same as `yyjson_arr_iter_init()`.

@param arr The array to be iterated over.
If `arr` is NULL or not an array, returns an empty iterator.
@return A new iterator for the array.

@note The iterator does not need to be destroyed.
*/
yyjson_arr_iter_with :: (arr: *yyjson_val) -> yyjson_arr_iter #foreign libyyjson;

/**
Returns whether the iteration has more elements.
If `iter` is NULL, returns false.
*/
yyjson_arr_iter_has_next :: (iter: *yyjson_arr_iter) -> bool #foreign libyyjson;

/**
Returns the next element in the iteration, or NULL on end.
If `iter` is NULL, returns NULL.
*/
yyjson_arr_iter_next :: (iter: *yyjson_arr_iter) -> *yyjson_val #foreign libyyjson;

/** Returns the number of key-value pairs in this object.
Returns 0 if `obj` is NULL or type is not object. */
yyjson_obj_size :: (obj: *yyjson_val) -> u64 #foreign libyyjson;

/** Returns the value to which the specified key is mapped.
Returns NULL if this object contains no mapping for the key.
Returns NULL if `obj/key` is NULL, or type is not object.

The `key` should be a null-terminated UTF-8 string.

@warning This function takes a linear search time. */
yyjson_obj_get :: (obj: *yyjson_val, key: *u8) -> *yyjson_val #foreign libyyjson;

/** Returns the value to which the specified key is mapped.
Returns NULL if this object contains no mapping for the key.
Returns NULL if `obj/key` is NULL, or type is not object.

The `key` should be a UTF-8 string, null-terminator is not required.
The `key_len` should be the length of the key, in bytes.

@warning This function takes a linear search time. */
yyjson_obj_getn :: (obj: *yyjson_val, key: *u8, key_len: u64) -> *yyjson_val #foreign libyyjson;

/**
A JSON object iterator.

@b Example
@code
yyjson_val *key, *val;
yyjson_obj_iter iter = yyjson_obj_iter_with(obj);
while ((key = yyjson_obj_iter_next(&iter))) {
val = yyjson_obj_iter_get_val(key);
your_func(key, val);
}
@endcode

If the ordering of the keys is known at compile-time, you can use this method
to speed up value lookups:
@code
// {"k1":1, "k2": 3, "k3": 3}
yyjson_val *key, *val;
yyjson_obj_iter iter = yyjson_obj_iter_with(obj);
yyjson_val *v1 = yyjson_obj_iter_get(&iter, "k1");
yyjson_val *v3 = yyjson_obj_iter_get(&iter, "k3");
@endcode
@see yyjson_obj_iter_get() and yyjson_obj_iter_getn()
*/
yyjson_obj_iter :: struct {
    idx: u64; /**< next key's index */
    max: u64; /**< maximum key index (obj.size) */
    cur: *yyjson_val; /**< next key */
    obj: *yyjson_val; /**< the object being iterated */
}

/**
Initialize an iterator for this object.

@param obj The object to be iterated over.
If `obj` is NULL or not an object, `iter` is cleared.
@param iter The iterator to be initialized.
If `iter` is NULL, returns false.
@return true if the `iter` has been successfully initialized.

@note The iterator does not need to be destroyed.
*/
yyjson_obj_iter_init :: (obj: *yyjson_val, iter: *yyjson_obj_iter) -> bool #foreign libyyjson;

/**
Create an iterator with an object, same as `yyjson_obj_iter_init()`.

@param obj The object to be iterated over.
If `obj` is NULL or not an object, returns an empty iterator.
@return A new iterator for the object.

@note The iterator does not need to be destroyed.
*/
yyjson_obj_iter_with :: (obj: *yyjson_val) -> yyjson_obj_iter #foreign libyyjson;

/**
Returns whether the iteration has more elements.
If `iter` is NULL, returns false.
*/
yyjson_obj_iter_has_next :: (iter: *yyjson_obj_iter) -> bool #foreign libyyjson;

/**
Returns the next key in the iteration, or NULL on end.
If `iter` is NULL, returns NULL.
*/
yyjson_obj_iter_next :: (iter: *yyjson_obj_iter) -> *yyjson_val #foreign libyyjson;

/**
Returns the value for key inside the iteration.
If `iter` is NULL, returns NULL.
*/
yyjson_obj_iter_get_val :: (key: *yyjson_val) -> *yyjson_val #foreign libyyjson;

/**
Iterates to a specified key and returns the value.

This function does the same thing as `yyjson_obj_get()`, but is much faster
if the ordering of the keys is known at compile-time and you are using the same
order to look up the values. If the key exists in this object, then the
iterator will stop at the next key, otherwise the iterator will not change and
NULL is returned.

@param iter The object iterator, should not be NULL.
@param key The key, should be a UTF-8 string with null-terminator.
@return The value to which the specified key is mapped.
NULL if the key is not found or arguments are invalid.

@warning This function takes a linear search time if the key is not nearby.
*/
yyjson_obj_iter_get :: (iter: *yyjson_obj_iter, key: *u8) -> *yyjson_val #foreign libyyjson;

/**
Iterates to a specified key and returns the value.

This function does the same thing as `yyjson_obj_getn()`, but is much faster
if the ordering of the keys is known at compile-time and you are using the same
order to look up the values. If the key exists in this object, then the
iterator will stop at the next key, otherwise the iterator will not change and
NULL is returned.

@param iter The object iterator, should not be NULL.
@param key The key, should be a UTF-8 string, null-terminator is not required.
@param key_len The length of `key`, in bytes.
@return The value to which the specified key is mapped.
NULL if the key is not found or arguments are invalid.

@warning This function takes a linear search time if the key is not nearby.
*/
yyjson_obj_iter_getn :: (iter: *yyjson_obj_iter, key: *u8, key_len: u64) -> *yyjson_val #foreign libyyjson;

/** Returns the root value of this JSON document.
Returns NULL if `doc` is NULL. */
yyjson_mut_doc_get_root :: (doc: *yyjson_mut_doc) -> *yyjson_mut_val #foreign libyyjson;

/** Sets the root value of this JSON document.
Pass NULL to clear root value of the document. */
yyjson_mut_doc_set_root :: (doc: *yyjson_mut_doc, root: *yyjson_mut_val) -> void #foreign libyyjson;

/**
Set the string pool size for a mutable document.
This function does not allocate memory immediately, but uses the size when
the next memory allocation is needed.

If the caller knows the approximate bytes of strings that the document needs to
store (e.g. copy string with `yyjson_mut_strcpy` function), setting a larger
size can avoid multiple memory allocations and improve performance.

@param doc The mutable document.
@param len The desired string pool size in bytes (total string length).
@return true if successful, false if size is 0 or overflow.
*/
yyjson_mut_doc_set_str_pool_size :: (doc: *yyjson_mut_doc, len: u64) -> bool #foreign libyyjson;

/**
Set the value pool size for a mutable document.
This function does not allocate memory immediately, but uses the size when
the next memory allocation is needed.

If the caller knows the approximate number of values that the document needs to
store (e.g. create new value with `yyjson_mut_xxx` functions), setting a larger
size can avoid multiple memory allocations and improve performance.

@param doc The mutable document.
@param count The desired value pool size (number of `yyjson_mut_val`).
@return true if successful, false if size is 0 or overflow.
*/
yyjson_mut_doc_set_val_pool_size :: (doc: *yyjson_mut_doc, count: u64) -> bool #foreign libyyjson;

/** Release the JSON document and free the memory.
After calling this function, the `doc` and all values from the `doc` are no
longer available. This function will do nothing if the `doc` is NULL.  */
yyjson_mut_doc_free :: (doc: *yyjson_mut_doc) -> void #foreign libyyjson;

/** Creates and returns a new mutable JSON document, returns NULL on error.
If allocator is NULL, the default allocator will be used. */
yyjson_mut_doc_new :: (alc: *yyjson_alc) -> *yyjson_mut_doc #foreign libyyjson;

/** Copies and returns a new mutable document from input, returns NULL on error.
This makes a `deep-copy` on the immutable document.
If allocator is NULL, the default allocator will be used.
@note `imut_doc` -> `mut_doc`. */
yyjson_doc_mut_copy :: (doc: *yyjson_doc, alc: *yyjson_alc) -> *yyjson_mut_doc #foreign libyyjson;

/** Copies and returns a new mutable document from input, returns NULL on error.
This makes a `deep-copy` on the mutable document.
If allocator is NULL, the default allocator will be used.
@note `mut_doc` -> `mut_doc`. */
yyjson_mut_doc_mut_copy :: (doc: *yyjson_mut_doc, alc: *yyjson_alc) -> *yyjson_mut_doc #foreign libyyjson;

/** Copies and returns a new mutable value from input, returns NULL on error.
This makes a `deep-copy` on the immutable value.
The memory is managed by the mutable document.
@note `imut_val` -> `mut_val`. */
yyjson_val_mut_copy :: (doc: *yyjson_mut_doc, val: *yyjson_val) -> *yyjson_mut_val #foreign libyyjson;

/** Copies and returns a new mutable value from input, returns NULL on error.
This makes a `deep-copy` on the mutable value.
The memory is managed by the mutable document.
@note `mut_val` -> `mut_val`.
@warning This function is recursive and may cause a stack overflow
if the object level is too deep. */
yyjson_mut_val_mut_copy :: (doc: *yyjson_mut_doc, val: *yyjson_mut_val) -> *yyjson_mut_val #foreign libyyjson;

/** Copies and returns a new immutable document from input,
returns NULL on error. This makes a `deep-copy` on the mutable document.
The returned document should be freed with `yyjson_doc_free()`.
@note `mut_doc` -> `imut_doc`.
@warning This function is recursive and may cause a stack overflow
if the object level is too deep. */
yyjson_mut_doc_imut_copy :: (doc: *yyjson_mut_doc, alc: *yyjson_alc) -> *yyjson_doc #foreign libyyjson;

/** Copies and returns a new immutable document from input,
returns NULL on error. This makes a `deep-copy` on the mutable value.
The returned document should be freed with `yyjson_doc_free()`.
@note `mut_val` -> `imut_doc`.
@warning This function is recursive and may cause a stack overflow
if the object level is too deep. */
yyjson_mut_val_imut_copy :: (val: *yyjson_mut_val, alc: *yyjson_alc) -> *yyjson_doc #foreign libyyjson;

/** Returns whether the JSON value is raw.
Returns false if `val` is NULL. */
yyjson_mut_is_raw :: (val: *yyjson_mut_val) -> bool #foreign libyyjson;

/** Returns whether the JSON value is `null`.
Returns false if `val` is NULL. */
yyjson_mut_is_null :: (val: *yyjson_mut_val) -> bool #foreign libyyjson;

/** Returns whether the JSON value is `true`.
Returns false if `val` is NULL. */
yyjson_mut_is_true :: (val: *yyjson_mut_val) -> bool #foreign libyyjson;

/** Returns whether the JSON value is `false`.
Returns false if `val` is NULL. */
yyjson_mut_is_false :: (val: *yyjson_mut_val) -> bool #foreign libyyjson;

/** Returns whether the JSON value is bool (true/false).
Returns false if `val` is NULL. */
yyjson_mut_is_bool :: (val: *yyjson_mut_val) -> bool #foreign libyyjson;

/** Returns whether the JSON value is unsigned integer (uint64_t).
Returns false if `val` is NULL. */
yyjson_mut_is_uint :: (val: *yyjson_mut_val) -> bool #foreign libyyjson;

/** Returns whether the JSON value is signed integer (int64_t).
Returns false if `val` is NULL. */
yyjson_mut_is_sint :: (val: *yyjson_mut_val) -> bool #foreign libyyjson;

/** Returns whether the JSON value is integer (uint64_t/int64_t).
Returns false if `val` is NULL. */
yyjson_mut_is_int :: (val: *yyjson_mut_val) -> bool #foreign libyyjson;

/** Returns whether the JSON value is real number (double).
Returns false if `val` is NULL. */
yyjson_mut_is_real :: (val: *yyjson_mut_val) -> bool #foreign libyyjson;

/** Returns whether the JSON value is number (uint/sint/real).
Returns false if `val` is NULL. */
yyjson_mut_is_num :: (val: *yyjson_mut_val) -> bool #foreign libyyjson;

/** Returns whether the JSON value is string.
Returns false if `val` is NULL. */
yyjson_mut_is_str :: (val: *yyjson_mut_val) -> bool #foreign libyyjson;

/** Returns whether the JSON value is array.
Returns false if `val` is NULL. */
yyjson_mut_is_arr :: (val: *yyjson_mut_val) -> bool #foreign libyyjson;

/** Returns whether the JSON value is object.
Returns false if `val` is NULL. */
yyjson_mut_is_obj :: (val: *yyjson_mut_val) -> bool #foreign libyyjson;

/** Returns whether the JSON value is container (array/object).
Returns false if `val` is NULL. */
yyjson_mut_is_ctn :: (val: *yyjson_mut_val) -> bool #foreign libyyjson;

/** Returns the JSON value's type.
Returns `YYJSON_TYPE_NONE` if `val` is NULL. */
yyjson_mut_get_type :: (val: *yyjson_mut_val) -> yyjson_type #foreign libyyjson;

/** Returns the JSON value's subtype.
Returns `YYJSON_SUBTYPE_NONE` if `val` is NULL. */
yyjson_mut_get_subtype :: (val: *yyjson_mut_val) -> yyjson_subtype #foreign libyyjson;

/** Returns the JSON value's tag.
Returns 0 if `val` is NULL. */
yyjson_mut_get_tag :: (val: *yyjson_mut_val) -> u8 #foreign libyyjson;

/** Returns the JSON value's type description.
The return value should be one of these strings: "raw", "null", "string",
"array", "object", "true", "false", "uint", "sint", "real", "unknown". */
yyjson_mut_get_type_desc :: (val: *yyjson_mut_val) -> *u8 #foreign libyyjson;

/** Returns the content if the value is raw.
Returns NULL if `val` is NULL or type is not raw. */
yyjson_mut_get_raw :: (val: *yyjson_mut_val) -> *u8 #foreign libyyjson;

/** Returns the content if the value is bool.
Returns NULL if `val` is NULL or type is not bool. */
yyjson_mut_get_bool :: (val: *yyjson_mut_val) -> bool #foreign libyyjson;

/** Returns the content and cast to uint64_t.
Returns 0 if `val` is NULL or type is not integer(sint/uint). */
yyjson_mut_get_uint :: (val: *yyjson_mut_val) -> u64 #foreign libyyjson;

/** Returns the content and cast to int64_t.
Returns 0 if `val` is NULL or type is not integer(sint/uint). */
yyjson_mut_get_sint :: (val: *yyjson_mut_val) -> s64 #foreign libyyjson;

/** Returns the content and cast to int.
Returns 0 if `val` is NULL or type is not integer(sint/uint). */
yyjson_mut_get_int :: (val: *yyjson_mut_val) -> s32 #foreign libyyjson;

/** Returns the content if the value is real number.
Returns 0.0 if `val` is NULL or type is not real(double). */
yyjson_mut_get_real :: (val: *yyjson_mut_val) -> float64 #foreign libyyjson;

/** Returns the content cast to `double` if the value is a number.
Returns 0.0 if `val` is NULL or type is not number(uint/sint/real). */
yyjson_mut_get_num :: (val: *yyjson_mut_val) -> float64 #foreign libyyjson;

/** Returns the content if the value is string.
Returns NULL if `val` is NULL or type is not string. */
yyjson_mut_get_str :: (val: *yyjson_mut_val) -> *u8 #foreign libyyjson;

/** Returns the content length for raw/string/array/object values.
Returns 0 if `val` is NULL.
The return value is unspecified for other types. */
yyjson_mut_get_len :: (val: *yyjson_mut_val) -> u64 #foreign libyyjson;

/** Returns whether the JSON value is equal to a string.
The `str` should be a null-terminated UTF-8 string.
Returns false if `val` is NULL or type is not string. */
yyjson_mut_equals_str :: (val: *yyjson_mut_val, str: *u8) -> bool #foreign libyyjson;

/** Returns whether the JSON value is equal to a string.
The `str` should be a UTF-8 string, null-terminator is not required.
Returns false if `val` is NULL or type is not string. */
yyjson_mut_equals_strn :: (val: *yyjson_mut_val, str: *u8, len: u64) -> bool #foreign libyyjson;

/** Returns whether two JSON values are equal (deep compare).
Returns false if `lhs` or `rhs` is NULL.
@note the result may be inaccurate if object has duplicate keys.
@warning This function is recursive and may cause a stack overflow
if the object level is too deep. */
yyjson_mut_equals :: (lhs: *yyjson_mut_val, rhs: *yyjson_mut_val) -> bool #foreign libyyjson;

/** Set the value to raw.
Returns false if `val` is NULL.
@warning This function should not be used on an existing object or array. */
yyjson_mut_set_raw :: (val: *yyjson_mut_val, raw: *u8, len: u64) -> bool #foreign libyyjson;

/** Set the value to null.
Returns false if `val` is NULL.
@warning This function should not be used on an existing object or array. */
yyjson_mut_set_null :: (val: *yyjson_mut_val) -> bool #foreign libyyjson;

/** Set the value to bool.
Returns false if `val` is NULL.
@warning This function should not be used on an existing object or array. */
yyjson_mut_set_bool :: (val: *yyjson_mut_val, num: bool) -> bool #foreign libyyjson;

/** Set the value to uint.
Returns false if `val` is NULL.
@warning This function should not be used on an existing object or array. */
yyjson_mut_set_uint :: (val: *yyjson_mut_val, num: u64) -> bool #foreign libyyjson;

/** Set the value to sint.
Returns false if `val` is NULL.
@warning This function should not be used on an existing object or array. */
yyjson_mut_set_sint :: (val: *yyjson_mut_val, num: s64) -> bool #foreign libyyjson;

/** Set the value to int.
Returns false if `val` is NULL.
@warning This function should not be used on an existing object or array. */
yyjson_mut_set_int :: (val: *yyjson_mut_val, num: s64) -> bool #foreign libyyjson;

/** Set the value to float.
Returns false if `val` is NULL.
@warning This function should not be used on an existing object or array. */
yyjson_mut_set_float :: (val: *yyjson_mut_val, num: float) -> bool #foreign libyyjson;

/** Set the value to double.
Returns false if `val` is NULL.
@warning This function should not be used on an existing object or array. */
yyjson_mut_set_double :: (val: *yyjson_mut_val, num: float64) -> bool #foreign libyyjson;

/** Set the value to real.
Returns false if `val` is NULL.
@warning This function should not be used on an existing object or array. */
yyjson_mut_set_real :: (val: *yyjson_mut_val, num: float64) -> bool #foreign libyyjson;

/** Set the floating-point number's output format to fixed-point notation.
Returns false if `val` is NULL or is not real type.
@see YYJSON_WRITE_FP_TO_FIXED flag.
@warning This will modify the `mutable` value, use with caution. */
yyjson_mut_set_fp_to_fixed :: (val: *yyjson_mut_val, prec: s32) -> bool #foreign libyyjson;

/** Set the floating-point number's output format to single-precision.
Returns false if `val` is NULL or is not real type.
@see YYJSON_WRITE_FP_TO_FLOAT flag.
@warning This will modify the `mutable` value, use with caution. */
yyjson_mut_set_fp_to_float :: (val: *yyjson_mut_val, flt: bool) -> bool #foreign libyyjson;

/** Set the value to string (null-terminated).
Returns false if `val` is NULL.
@warning This function should not be used on an existing object or array. */
yyjson_mut_set_str :: (val: *yyjson_mut_val, str: *u8) -> bool #foreign libyyjson;

/** Set the value to string (with length).
Returns false if `val` is NULL.
@warning This function should not be used on an existing object or array. */
yyjson_mut_set_strn :: (val: *yyjson_mut_val, str: *u8, len: u64) -> bool #foreign libyyjson;

/** Marks this string as not needing to be escaped during JSON writing.
This can be used to avoid the overhead of escaping if the string contains
only characters that do not require escaping.
Returns false if `val` is NULL or is not string.
@see YYJSON_SUBTYPE_NOESC subtype.
@warning This will modify the `mutable` value, use with caution. */
yyjson_mut_set_str_noesc :: (val: *yyjson_mut_val, noesc: bool) -> bool #foreign libyyjson;

/** Set the value to array.
Returns false if `val` is NULL.
@warning This function should not be used on an existing object or array. */
yyjson_mut_set_arr :: (val: *yyjson_mut_val) -> bool #foreign libyyjson;

/** Set the value to object.
Returns false if `val` is NULL.
@warning This function should not be used on an existing object or array. */
yyjson_mut_set_obj :: (val: *yyjson_mut_val) -> bool #foreign libyyjson;

/** Creates and returns a raw value, returns NULL on error.
The `str` should be a null-terminated UTF-8 string.

@warning The input string is not copied, you should keep this string
unmodified for the lifetime of this JSON document. */
yyjson_mut_raw :: (doc: *yyjson_mut_doc, str: *u8) -> *yyjson_mut_val #foreign libyyjson;

/** Creates and returns a raw value, returns NULL on error.
The `str` should be a UTF-8 string, null-terminator is not required.

@warning The input string is not copied, you should keep this string
unmodified for the lifetime of this JSON document. */
yyjson_mut_rawn :: (doc: *yyjson_mut_doc, str: *u8, len: u64) -> *yyjson_mut_val #foreign libyyjson;

/** Creates and returns a raw value, returns NULL on error.
The `str` should be a null-terminated UTF-8 string.
The input string is copied and held by the document. */
yyjson_mut_rawcpy :: (doc: *yyjson_mut_doc, str: *u8) -> *yyjson_mut_val #foreign libyyjson;

/** Creates and returns a raw value, returns NULL on error.
The `str` should be a UTF-8 string, null-terminator is not required.
The input string is copied and held by the document. */
yyjson_mut_rawncpy :: (doc: *yyjson_mut_doc, str: *u8, len: u64) -> *yyjson_mut_val #foreign libyyjson;

/** Creates and returns a null value, returns NULL on error. */
yyjson_mut_null :: (doc: *yyjson_mut_doc) -> *yyjson_mut_val #foreign libyyjson;

/** Creates and returns a true value, returns NULL on error. */
yyjson_mut_true :: (doc: *yyjson_mut_doc) -> *yyjson_mut_val #foreign libyyjson;

/** Creates and returns a false value, returns NULL on error. */
yyjson_mut_false :: (doc: *yyjson_mut_doc) -> *yyjson_mut_val #foreign libyyjson;

/** Creates and returns a bool value, returns NULL on error. */
yyjson_mut_bool :: (doc: *yyjson_mut_doc, val: bool) -> *yyjson_mut_val #foreign libyyjson;

/** Creates and returns an unsigned integer value, returns NULL on error. */
yyjson_mut_uint :: (doc: *yyjson_mut_doc, num: u64) -> *yyjson_mut_val #foreign libyyjson;

/** Creates and returns a signed integer value, returns NULL on error. */
yyjson_mut_sint :: (doc: *yyjson_mut_doc, num: s64) -> *yyjson_mut_val #foreign libyyjson;

/** Creates and returns a signed integer value, returns NULL on error. */
yyjson_mut_int :: (doc: *yyjson_mut_doc, num: s64) -> *yyjson_mut_val #foreign libyyjson;

/** Creates and returns a float number value, returns NULL on error. */
yyjson_mut_float :: (doc: *yyjson_mut_doc, num: float) -> *yyjson_mut_val #foreign libyyjson;

/** Creates and returns a double number value, returns NULL on error. */
yyjson_mut_double :: (doc: *yyjson_mut_doc, num: float64) -> *yyjson_mut_val #foreign libyyjson;

/** Creates and returns a real number value, returns NULL on error. */
yyjson_mut_real :: (doc: *yyjson_mut_doc, num: float64) -> *yyjson_mut_val #foreign libyyjson;

/** Creates and returns a string value, returns NULL on error.
The `str` should be a null-terminated UTF-8 string.
@warning The input string is not copied, you should keep this string
unmodified for the lifetime of this JSON document. */
yyjson_mut_str :: (doc: *yyjson_mut_doc, str: *u8) -> *yyjson_mut_val #foreign libyyjson;

/** Creates and returns a string value, returns NULL on error.
The `str` should be a UTF-8 string, null-terminator is not required.
@warning The input string is not copied, you should keep this string
unmodified for the lifetime of this JSON document. */
yyjson_mut_strn :: (doc: *yyjson_mut_doc, str: *u8, len: u64) -> *yyjson_mut_val #foreign libyyjson;

/** Creates and returns a string value, returns NULL on error.
The `str` should be a null-terminated UTF-8 string.
The input string is copied and held by the document. */
yyjson_mut_strcpy :: (doc: *yyjson_mut_doc, str: *u8) -> *yyjson_mut_val #foreign libyyjson;

/** Creates and returns a string value, returns NULL on error.
The `str` should be a UTF-8 string, null-terminator is not required.
The input string is copied and held by the document. */
yyjson_mut_strncpy :: (doc: *yyjson_mut_doc, str: *u8, len: u64) -> *yyjson_mut_val #foreign libyyjson;

/** Returns the number of elements in this array.
Returns 0 if `arr` is NULL or type is not array. */
yyjson_mut_arr_size :: (arr: *yyjson_mut_val) -> u64 #foreign libyyjson;

/** Returns the element at the specified position in this array.
Returns NULL if array is NULL/empty or the index is out of bounds.
@warning This function takes a linear search time. */
yyjson_mut_arr_get :: (arr: *yyjson_mut_val, idx: u64) -> *yyjson_mut_val #foreign libyyjson;

/** Returns the first element of this array.
Returns NULL if `arr` is NULL/empty or type is not array. */
yyjson_mut_arr_get_first :: (arr: *yyjson_mut_val) -> *yyjson_mut_val #foreign libyyjson;

/** Returns the last element of this array.
Returns NULL if `arr` is NULL/empty or type is not array. */
yyjson_mut_arr_get_last :: (arr: *yyjson_mut_val) -> *yyjson_mut_val #foreign libyyjson;

/**
A mutable JSON array iterator.

@warning You should not modify the array while iterating over it, but you can
use `yyjson_mut_arr_iter_remove()` to remove current value.

@b Example
@code
yyjson_mut_val *val;
yyjson_mut_arr_iter iter = yyjson_mut_arr_iter_with(arr);
while ((val = yyjson_mut_arr_iter_next(&iter))) {
your_func(val);
if (your_val_is_unused(val)) {
yyjson_mut_arr_iter_remove(&iter);
}
}
@endcode
*/
yyjson_mut_arr_iter :: struct {
    idx: u64; /**< next value's index */
    max: u64; /**< maximum index (arr.size) */
    cur: *yyjson_mut_val; /**< current value */
    pre: *yyjson_mut_val; /**< previous value */
    arr: *yyjson_mut_val; /**< the array being iterated */
}

/**
Initialize an iterator for this array.

@param arr The array to be iterated over.
If `arr` is NULL or not an array, `iter` is cleared.
@param iter The iterator to be initialized.
If `iter` is NULL, returns false.
@return true if the `iter` has been successfully initialized.

@note The iterator does not need to be destroyed.
*/
yyjson_mut_arr_iter_init :: (arr: *yyjson_mut_val, iter: *yyjson_mut_arr_iter) -> bool #foreign libyyjson;

/**
Create an iterator with an array, same as `yyjson_mut_arr_iter_init()`.

@param arr The array to be iterated over.
If `arr` is NULL or not an array, returns an empty iterator.
@return A new iterator for the array.

@note The iterator does not need to be destroyed.
*/
yyjson_mut_arr_iter_with :: (arr: *yyjson_mut_val) -> yyjson_mut_arr_iter #foreign libyyjson;

/**
Returns whether the iteration has more elements.
If `iter` is NULL, returns false.
*/
yyjson_mut_arr_iter_has_next :: (iter: *yyjson_mut_arr_iter) -> bool #foreign libyyjson;

/**
Returns the next element in the iteration, or NULL on end.
If `iter` is NULL, returns NULL.
*/
yyjson_mut_arr_iter_next :: (iter: *yyjson_mut_arr_iter) -> *yyjson_mut_val #foreign libyyjson;

/**
Removes and returns current element in the iteration.
If `iter` is NULL, returns NULL.
*/
yyjson_mut_arr_iter_remove :: (iter: *yyjson_mut_arr_iter) -> *yyjson_mut_val #foreign libyyjson;

/**
Creates and returns an empty mutable array.
@param doc A mutable document, used for memory allocation only.
@return The new array. NULL if `doc` is NULL or allocation fails.
*/
yyjson_mut_arr :: (doc: *yyjson_mut_doc) -> *yyjson_mut_val #foreign libyyjson;

/**
Creates and returns a new mutable array with the given boolean values.

@param doc A mutable document, used for memory allocation only.
If `doc` is NULL, returns NULL.
@param vals A C array of boolean values.
@param count The value count. If this value is 0, an empty array is returned.
@return The new array. NULL if arguments are invalid or allocation fails.

@b Example
@code
const bool vals[3] = { true, false, true };
yyjson_mut_val *arr = yyjson_mut_arr_with_bool(doc, vals, 3);
@endcode
*/
yyjson_mut_arr_with_bool :: (doc: *yyjson_mut_doc, vals: *bool, count: u64) -> *yyjson_mut_val #foreign libyyjson;

/**
Creates and returns a new mutable array with the given sint numbers.

@param doc A mutable document, used for memory allocation only.
If `doc` is NULL, returns NULL.
@param vals A C array of sint numbers.
@param count The number count. If this value is 0, an empty array is returned.
@return The new array. NULL if arguments are invalid or allocation fails.

@b Example
@code
const int64_t vals[3] = { -1, 0, 1 };
yyjson_mut_val *arr = yyjson_mut_arr_with_sint64(doc, vals, 3);
@endcode
*/
yyjson_mut_arr_with_sint :: (doc: *yyjson_mut_doc, vals: *s64, count: u64) -> *yyjson_mut_val #foreign libyyjson;

/**
Creates and returns a new mutable array with the given uint numbers.

@param doc A mutable document, used for memory allocation only.
If `doc` is NULL, returns NULL.
@param vals A C array of uint numbers.
@param count The number count. If this value is 0, an empty array is returned.
@return The new array. NULL if arguments are invalid or allocation fails.

@b Example
@code
const uint64_t vals[3] = { 0, 1, 0 };
yyjson_mut_val *arr = yyjson_mut_arr_with_uint(doc, vals, 3);
@endcode
*/
yyjson_mut_arr_with_uint :: (doc: *yyjson_mut_doc, vals: *u64, count: u64) -> *yyjson_mut_val #foreign libyyjson;

/**
Creates and returns a new mutable array with the given real numbers.

@param doc A mutable document, used for memory allocation only.
If `doc` is NULL, returns NULL.
@param vals A C array of real numbers.
@param count The number count. If this value is 0, an empty array is returned.
@return The new array. NULL if arguments are invalid or allocation fails.

@b Example
@code
const double vals[3] = { 0.1, 0.2, 0.3 };
yyjson_mut_val *arr = yyjson_mut_arr_with_real(doc, vals, 3);
@endcode
*/
yyjson_mut_arr_with_real :: (doc: *yyjson_mut_doc, vals: *float64, count: u64) -> *yyjson_mut_val #foreign libyyjson;

/**
Creates and returns a new mutable array with the given int8 numbers.

@param doc A mutable document, used for memory allocation only.
If `doc` is NULL, returns NULL.
@param vals A C array of int8 numbers.
@param count The number count. If this value is 0, an empty array is returned.
@return The new array. NULL if arguments are invalid or allocation fails.

@b Example
@code
const int8_t vals[3] = { -1, 0, 1 };
yyjson_mut_val *arr = yyjson_mut_arr_with_sint8(doc, vals, 3);
@endcode
*/
yyjson_mut_arr_with_sint8 :: (doc: *yyjson_mut_doc, vals: *s8, count: u64) -> *yyjson_mut_val #foreign libyyjson;

/**
Creates and returns a new mutable array with the given int16 numbers.

@param doc A mutable document, used for memory allocation only.
If `doc` is NULL, returns NULL.
@param vals A C array of int16 numbers.
@param count The number count. If this value is 0, an empty array is returned.
@return The new array. NULL if arguments are invalid or allocation fails.

@b Example
@code
const int16_t vals[3] = { -1, 0, 1 };
yyjson_mut_val *arr = yyjson_mut_arr_with_sint16(doc, vals, 3);
@endcode
*/
yyjson_mut_arr_with_sint16 :: (doc: *yyjson_mut_doc, vals: *s16, count: u64) -> *yyjson_mut_val #foreign libyyjson;

/**
Creates and returns a new mutable array with the given int32 numbers.

@param doc A mutable document, used for memory allocation only.
If `doc` is NULL, returns NULL.
@param vals A C array of int32 numbers.
@param count The number count. If this value is 0, an empty array is returned.
@return The new array. NULL if arguments are invalid or allocation fails.

@b Example
@code
const int32_t vals[3] = { -1, 0, 1 };
yyjson_mut_val *arr = yyjson_mut_arr_with_sint32(doc, vals, 3);
@endcode
*/
yyjson_mut_arr_with_sint32 :: (doc: *yyjson_mut_doc, vals: *s32, count: u64) -> *yyjson_mut_val #foreign libyyjson;

/**
Creates and returns a new mutable array with the given int64 numbers.

@param doc A mutable document, used for memory allocation only.
If `doc` is NULL, returns NULL.
@param vals A C array of int64 numbers.
@param count The number count. If this value is 0, an empty array is returned.
@return The new array. NULL if arguments are invalid or allocation fails.

@b Example
@code
const int64_t vals[3] = { -1, 0, 1 };
yyjson_mut_val *arr = yyjson_mut_arr_with_sint64(doc, vals, 3);
@endcode
*/
yyjson_mut_arr_with_sint64 :: (doc: *yyjson_mut_doc, vals: *s64, count: u64) -> *yyjson_mut_val #foreign libyyjson;

/**
Creates and returns a new mutable array with the given uint8 numbers.

@param doc A mutable document, used for memory allocation only.
If `doc` is NULL, returns NULL.
@param vals A C array of uint8 numbers.
@param count The number count. If this value is 0, an empty array is returned.
@return The new array. NULL if arguments are invalid or allocation fails.

@b Example
@code
const uint8_t vals[3] = { 0, 1, 0 };
yyjson_mut_val *arr = yyjson_mut_arr_with_uint8(doc, vals, 3);
@endcode
*/
yyjson_mut_arr_with_uint8 :: (doc: *yyjson_mut_doc, vals: *u8, count: u64) -> *yyjson_mut_val #foreign libyyjson;

/**
Creates and returns a new mutable array with the given uint16 numbers.

@param doc A mutable document, used for memory allocation only.
If `doc` is NULL, returns NULL.
@param vals A C array of uint16 numbers.
@param count The number count. If this value is 0, an empty array is returned.
@return The new array. NULL if arguments are invalid or allocation fails.

@b Example
@code
const uint16_t vals[3] = { 0, 1, 0 };
yyjson_mut_val *arr = yyjson_mut_arr_with_uint16(doc, vals, 3);
@endcode
*/
yyjson_mut_arr_with_uint16 :: (doc: *yyjson_mut_doc, vals: *u16, count: u64) -> *yyjson_mut_val #foreign libyyjson;

/**
Creates and returns a new mutable array with the given uint32 numbers.

@param doc A mutable document, used for memory allocation only.
If `doc` is NULL, returns NULL.
@param vals A C array of uint32 numbers.
@param count The number count. If this value is 0, an empty array is returned.
@return The new array. NULL if arguments are invalid or allocation fails.

@b Example
@code
const uint32_t vals[3] = { 0, 1, 0 };
yyjson_mut_val *arr = yyjson_mut_arr_with_uint32(doc, vals, 3);
@endcode
*/
yyjson_mut_arr_with_uint32 :: (doc: *yyjson_mut_doc, vals: *u32, count: u64) -> *yyjson_mut_val #foreign libyyjson;

/**
Creates and returns a new mutable array with the given uint64 numbers.

@param doc A mutable document, used for memory allocation only.
If `doc` is NULL, returns NULL.
@param vals A C array of uint64 numbers.
@param count The number count. If this value is 0, an empty array is returned.
@return The new array. NULL if arguments are invalid or allocation fails.

@b Example
@code
const uint64_t vals[3] = { 0, 1, 0 };
yyjson_mut_val *arr = yyjson_mut_arr_with_uint64(doc, vals, 3);
@endcode
*/
yyjson_mut_arr_with_uint64 :: (doc: *yyjson_mut_doc, vals: *u64, count: u64) -> *yyjson_mut_val #foreign libyyjson;

/**
Creates and returns a new mutable array with the given float numbers.

@param doc A mutable document, used for memory allocation only.
If `doc` is NULL, returns NULL.
@param vals A C array of float numbers.
@param count The number count. If this value is 0, an empty array is returned.
@return The new array. NULL if arguments are invalid or allocation fails.

@b Example
@code
const float vals[3] = { -1.0f, 0.0f, 1.0f };
yyjson_mut_val *arr = yyjson_mut_arr_with_float(doc, vals, 3);
@endcode
*/
yyjson_mut_arr_with_float :: (doc: *yyjson_mut_doc, vals: *float, count: u64) -> *yyjson_mut_val #foreign libyyjson;

/**
Creates and returns a new mutable array with the given double numbers.

@param doc A mutable document, used for memory allocation only.
If `doc` is NULL, returns NULL.
@param vals A C array of double numbers.
@param count The number count. If this value is 0, an empty array is returned.
@return The new array. NULL if arguments are invalid or allocation fails.

@b Example
@code
const double vals[3] = { -1.0, 0.0, 1.0 };
yyjson_mut_val *arr = yyjson_mut_arr_with_double(doc, vals, 3);
@endcode
*/
yyjson_mut_arr_with_double :: (doc: *yyjson_mut_doc, vals: *float64, count: u64) -> *yyjson_mut_val #foreign libyyjson;

/**
Creates and returns a new mutable array with the given strings, these strings
will not be copied.

@param doc A mutable document, used for memory allocation only.
If `doc` is NULL, returns NULL.
@param vals A C array of UTF-8 null-terminator strings.
If `vals` contains NULL, returns NULL.
@param count The number of values in `vals`.
If this value is 0, an empty array is returned.
@return The new array. NULL if arguments are invalid or allocation fails.

@warning The input strings are not copied, you should keep these strings
unmodified for the lifetime of this JSON document. If these strings will be
modified, you should use `yyjson_mut_arr_with_strcpy()` instead.

@b Example
@code
const char *vals[3] = { "a", "b", "c" };
yyjson_mut_val *arr = yyjson_mut_arr_with_str(doc, vals, 3);
@endcode
*/
yyjson_mut_arr_with_str :: (doc: *yyjson_mut_doc, vals: **u8, count: u64) -> *yyjson_mut_val #foreign libyyjson;

/**
Creates and returns a new mutable array with the given strings and string
lengths, these strings will not be copied.

@param doc A mutable document, used for memory allocation only.
If `doc` is NULL, returns NULL.
@param vals A C array of UTF-8 strings, null-terminator is not required.
If `vals` contains NULL, returns NULL.
@param lens A C array of string lengths, in bytes.
@param count The number of strings in `vals`.
If this value is 0, an empty array is returned.
@return The new array. NULL if arguments are invalid or allocation fails.

@warning The input strings are not copied, you should keep these strings
unmodified for the lifetime of this JSON document. If these strings will be
modified, you should use `yyjson_mut_arr_with_strncpy()` instead.

@b Example
@code
const char *vals[3] = { "a", "bb", "c" };
const size_t lens[3] = { 1, 2, 1 };
yyjson_mut_val *arr = yyjson_mut_arr_with_strn(doc, vals, lens, 3);
@endcode
*/
yyjson_mut_arr_with_strn :: (doc: *yyjson_mut_doc, vals: **u8, lens: *u64, count: u64) -> *yyjson_mut_val #foreign libyyjson;

/**
Creates and returns a new mutable array with the given strings, these strings
will be copied.

@param doc A mutable document, used for memory allocation only.
If `doc` is NULL, returns NULL.
@param vals A C array of UTF-8 null-terminator strings.
If `vals` contains NULL, returns NULL.
@param count The number of values in `vals`.
If this value is 0, an empty array is returned.
@return The new array. NULL if arguments are invalid or allocation fails.

@b Example
@code
const char *vals[3] = { "a", "b", "c" };
yyjson_mut_val *arr = yyjson_mut_arr_with_strcpy(doc, vals, 3);
@endcode
*/
yyjson_mut_arr_with_strcpy :: (doc: *yyjson_mut_doc, vals: **u8, count: u64) -> *yyjson_mut_val #foreign libyyjson;

/**
Creates and returns a new mutable array with the given strings and string
lengths, these strings will be copied.

@param doc A mutable document, used for memory allocation only.
If `doc` is NULL, returns NULL.
@param vals A C array of UTF-8 strings, null-terminator is not required.
If `vals` contains NULL, returns NULL.
@param lens A C array of string lengths, in bytes.
@param count The number of strings in `vals`.
If this value is 0, an empty array is returned.
@return The new array. NULL if arguments are invalid or allocation fails.

@b Example
@code
const char *vals[3] = { "a", "bb", "c" };
const size_t lens[3] = { 1, 2, 1 };
yyjson_mut_val *arr = yyjson_mut_arr_with_strn(doc, vals, lens, 3);
@endcode
*/
yyjson_mut_arr_with_strncpy :: (doc: *yyjson_mut_doc, vals: **u8, lens: *u64, count: u64) -> *yyjson_mut_val #foreign libyyjson;

/**
Inserts a value into an array at a given index.
@param arr The array to which the value is to be inserted.
Returns false if it is NULL or not an array.
@param val The value to be inserted. Returns false if it is NULL.
@param idx The index to which to insert the new value.
Returns false if the index is out of range.
@return Whether the operation was successful.
@warning This function takes a linear search time.
*/
yyjson_mut_arr_insert :: (arr: *yyjson_mut_val, val: *yyjson_mut_val, idx: u64) -> bool #foreign libyyjson;

/**
Inserts a value at the end of the array.
@param arr The array to which the value is to be inserted.
Returns false if it is NULL or not an array.
@param val The value to be inserted. Returns false if it is NULL.
@return Whether the operation was successful.
*/
yyjson_mut_arr_append :: (arr: *yyjson_mut_val, val: *yyjson_mut_val) -> bool #foreign libyyjson;

/**
Inserts a value at the head of the array.
@param arr The array to which the value is to be inserted.
Returns false if it is NULL or not an array.
@param val The value to be inserted. Returns false if it is NULL.
@return    Whether successful.
*/
yyjson_mut_arr_prepend :: (arr: *yyjson_mut_val, val: *yyjson_mut_val) -> bool #foreign libyyjson;

/**
Replaces a value at index and returns old value.
@param arr The array to which the value is to be replaced.
Returns false if it is NULL or not an array.
@param idx The index to which to replace the value.
Returns false if the index is out of range.
@param val The new value to replace. Returns false if it is NULL.
@return Old value, or NULL on error.
@warning This function takes a linear search time.
*/
yyjson_mut_arr_replace :: (arr: *yyjson_mut_val, idx: u64, val: *yyjson_mut_val) -> *yyjson_mut_val #foreign libyyjson;

/**
Removes and returns a value at index.
@param arr The array from which the value is to be removed.
Returns false if it is NULL or not an array.
@param idx The index from which to remove the value.
Returns false if the index is out of range.
@return Old value, or NULL on error.
@warning This function takes a linear search time.
*/
yyjson_mut_arr_remove :: (arr: *yyjson_mut_val, idx: u64) -> *yyjson_mut_val #foreign libyyjson;

/**
Removes and returns the first value in this array.
@param arr The array from which the value is to be removed.
Returns false if it is NULL or not an array.
@return The first value, or NULL on error.
*/
yyjson_mut_arr_remove_first :: (arr: *yyjson_mut_val) -> *yyjson_mut_val #foreign libyyjson;

/**
Removes and returns the last value in this array.
@param arr The array from which the value is to be removed.
Returns false if it is NULL or not an array.
@return The last value, or NULL on error.
*/
yyjson_mut_arr_remove_last :: (arr: *yyjson_mut_val) -> *yyjson_mut_val #foreign libyyjson;

/**
Removes all values within a specified range in the array.
@param arr The array from which the value is to be removed.
Returns false if it is NULL or not an array.
@param idx The start index of the range (0 is the first).
@param len The number of items in the range (can be 0).
@return Whether the operation was successful.
@warning This function takes a linear search time.
*/
yyjson_mut_arr_remove_range :: (arr: *yyjson_mut_val, idx: u64, len: u64) -> bool #foreign libyyjson;

/**
Removes all values in this array.
@param arr The array from which all of the values are to be removed.
Returns false if it is NULL or not an array.
@return Whether the operation was successful.
*/
yyjson_mut_arr_clear :: (arr: *yyjson_mut_val) -> bool #foreign libyyjson;

/**
Rotates values in this array for the given number of times.
For example: `[1,2,3,4,5]` rotate 2 is `[3,4,5,1,2]`.
@param arr The array to be rotated.
@param idx Index (or times) to rotate.
@warning This function takes a linear search time.
*/
yyjson_mut_arr_rotate :: (arr: *yyjson_mut_val, idx: u64) -> bool #foreign libyyjson;

/**
Adds a value at the end of the array.
@param arr The array to which the value is to be inserted.
Returns false if it is NULL or not an array.
@param val The value to be inserted. Returns false if it is NULL.
@return Whether the operation was successful.
*/
yyjson_mut_arr_add_val :: (arr: *yyjson_mut_val, val: *yyjson_mut_val) -> bool #foreign libyyjson;

/**
Adds a `null` value at the end of the array.
@param doc The `doc` is only used for memory allocation.
@param arr The array to which the value is to be inserted.
Returns false if it is NULL or not an array.
@return Whether the operation was successful.
*/
yyjson_mut_arr_add_null :: (doc: *yyjson_mut_doc, arr: *yyjson_mut_val) -> bool #foreign libyyjson;

/**
Adds a `true` value at the end of the array.
@param doc The `doc` is only used for memory allocation.
@param arr The array to which the value is to be inserted.
Returns false if it is NULL or not an array.
@return Whether the operation was successful.
*/
yyjson_mut_arr_add_true :: (doc: *yyjson_mut_doc, arr: *yyjson_mut_val) -> bool #foreign libyyjson;

/**
Adds a `false` value at the end of the array.
@param doc The `doc` is only used for memory allocation.
@param arr The array to which the value is to be inserted.
Returns false if it is NULL or not an array.
@return Whether the operation was successful.
*/
yyjson_mut_arr_add_false :: (doc: *yyjson_mut_doc, arr: *yyjson_mut_val) -> bool #foreign libyyjson;

/**
Adds a bool value at the end of the array.
@param doc The `doc` is only used for memory allocation.
@param arr The array to which the value is to be inserted.
Returns false if it is NULL or not an array.
@param val The bool value to be added.
@return Whether the operation was successful.
*/
yyjson_mut_arr_add_bool :: (doc: *yyjson_mut_doc, arr: *yyjson_mut_val, val: bool) -> bool #foreign libyyjson;

/**
Adds an unsigned integer value at the end of the array.
@param doc The `doc` is only used for memory allocation.
@param arr The array to which the value is to be inserted.
Returns false if it is NULL or not an array.
@param num The number to be added.
@return Whether the operation was successful.
*/
yyjson_mut_arr_add_uint :: (doc: *yyjson_mut_doc, arr: *yyjson_mut_val, num: u64) -> bool #foreign libyyjson;

/**
Adds a signed integer value at the end of the array.
@param doc The `doc` is only used for memory allocation.
@param arr The array to which the value is to be inserted.
Returns false if it is NULL or not an array.
@param num The number to be added.
@return Whether the operation was successful.
*/
yyjson_mut_arr_add_sint :: (doc: *yyjson_mut_doc, arr: *yyjson_mut_val, num: s64) -> bool #foreign libyyjson;

/**
Adds an integer value at the end of the array.
@param doc The `doc` is only used for memory allocation.
@param arr The array to which the value is to be inserted.
Returns false if it is NULL or not an array.
@param num The number to be added.
@return Whether the operation was successful.
*/
yyjson_mut_arr_add_int :: (doc: *yyjson_mut_doc, arr: *yyjson_mut_val, num: s64) -> bool #foreign libyyjson;

/**
Adds a float value at the end of the array.
@param doc The `doc` is only used for memory allocation.
@param arr The array to which the value is to be inserted.
Returns false if it is NULL or not an array.
@param num The number to be added.
@return Whether the operation was successful.
*/
yyjson_mut_arr_add_float :: (doc: *yyjson_mut_doc, arr: *yyjson_mut_val, num: float) -> bool #foreign libyyjson;

/**
Adds a double value at the end of the array.
@param doc The `doc` is only used for memory allocation.
@param arr The array to which the value is to be inserted.
Returns false if it is NULL or not an array.
@param num The number to be added.
@return Whether the operation was successful.
*/
yyjson_mut_arr_add_double :: (doc: *yyjson_mut_doc, arr: *yyjson_mut_val, num: float64) -> bool #foreign libyyjson;

/**
Adds a double value at the end of the array.
@param doc The `doc` is only used for memory allocation.
@param arr The array to which the value is to be inserted.
Returns false if it is NULL or not an array.
@param num The number to be added.
@return Whether the operation was successful.
*/
yyjson_mut_arr_add_real :: (doc: *yyjson_mut_doc, arr: *yyjson_mut_val, num: float64) -> bool #foreign libyyjson;

/**
Adds a string value at the end of the array (no copy).
@param doc The `doc` is only used for memory allocation.
@param arr The array to which the value is to be inserted.
Returns false if it is NULL or not an array.
@param str A null-terminated UTF-8 string.
@return Whether the operation was successful.
@warning The input string is not copied, you should keep this string unmodified
for the lifetime of this JSON document.
*/
yyjson_mut_arr_add_str :: (doc: *yyjson_mut_doc, arr: *yyjson_mut_val, str: *u8) -> bool #foreign libyyjson;

/**
Adds a string value at the end of the array (no copy).
@param doc The `doc` is only used for memory allocation.
@param arr The array to which the value is to be inserted.
Returns false if it is NULL or not an array.
@param str A UTF-8 string, null-terminator is not required.
@param len The length of the string, in bytes.
@return Whether the operation was successful.
@warning The input string is not copied, you should keep this string unmodified
for the lifetime of this JSON document.
*/
yyjson_mut_arr_add_strn :: (doc: *yyjson_mut_doc, arr: *yyjson_mut_val, str: *u8, len: u64) -> bool #foreign libyyjson;

/**
Adds a string value at the end of the array (copied).
@param doc The `doc` is only used for memory allocation.
@param arr The array to which the value is to be inserted.
Returns false if it is NULL or not an array.
@param str A null-terminated UTF-8 string.
@return Whether the operation was successful.
*/
yyjson_mut_arr_add_strcpy :: (doc: *yyjson_mut_doc, arr: *yyjson_mut_val, str: *u8) -> bool #foreign libyyjson;

/**
Adds a string value at the end of the array (copied).
@param doc The `doc` is only used for memory allocation.
@param arr The array to which the value is to be inserted.
Returns false if it is NULL or not an array.
@param str A UTF-8 string, null-terminator is not required.
@param len The length of the string, in bytes.
@return Whether the operation was successful.
*/
yyjson_mut_arr_add_strncpy :: (doc: *yyjson_mut_doc, arr: *yyjson_mut_val, str: *u8, len: u64) -> bool #foreign libyyjson;

/**
Creates and adds a new array at the end of the array.
@param doc The `doc` is only used for memory allocation.
@param arr The array to which the value is to be inserted.
Returns false if it is NULL or not an array.
@return The new array, or NULL on error.
*/
yyjson_mut_arr_add_arr :: (doc: *yyjson_mut_doc, arr: *yyjson_mut_val) -> *yyjson_mut_val #foreign libyyjson;

/**
Creates and adds a new object at the end of the array.
@param doc The `doc` is only used for memory allocation.
@param arr The array to which the value is to be inserted.
Returns false if it is NULL or not an array.
@return The new object, or NULL on error.
*/
yyjson_mut_arr_add_obj :: (doc: *yyjson_mut_doc, arr: *yyjson_mut_val) -> *yyjson_mut_val #foreign libyyjson;

/** Returns the number of key-value pairs in this object.
Returns 0 if `obj` is NULL or type is not object. */
yyjson_mut_obj_size :: (obj: *yyjson_mut_val) -> u64 #foreign libyyjson;

/** Returns the value to which the specified key is mapped.
Returns NULL if this object contains no mapping for the key.
Returns NULL if `obj/key` is NULL, or type is not object.

The `key` should be a null-terminated UTF-8 string.

@warning This function takes a linear search time. */
yyjson_mut_obj_get :: (obj: *yyjson_mut_val, key: *u8) -> *yyjson_mut_val #foreign libyyjson;

/** Returns the value to which the specified key is mapped.
Returns NULL if this object contains no mapping for the key.
Returns NULL if `obj/key` is NULL, or type is not object.

The `key` should be a UTF-8 string, null-terminator is not required.
The `key_len` should be the length of the key, in bytes.

@warning This function takes a linear search time. */
yyjson_mut_obj_getn :: (obj: *yyjson_mut_val, key: *u8, key_len: u64) -> *yyjson_mut_val #foreign libyyjson;

/**
A mutable JSON object iterator.

@warning You should not modify the object while iterating over it, but you can
use `yyjson_mut_obj_iter_remove()` to remove current value.

@b Example
@code
yyjson_mut_val *key, *val;
yyjson_mut_obj_iter iter = yyjson_mut_obj_iter_with(obj);
while ((key = yyjson_mut_obj_iter_next(&iter))) {
val = yyjson_mut_obj_iter_get_val(key);
your_func(key, val);
if (your_val_is_unused(key, val)) {
yyjson_mut_obj_iter_remove(&iter);
}
}
@endcode

If the ordering of the keys is known at compile-time, you can use this method
to speed up value lookups:
@code
// {"k1":1, "k2": 3, "k3": 3}
yyjson_mut_val *key, *val;
yyjson_mut_obj_iter iter = yyjson_mut_obj_iter_with(obj);
yyjson_mut_val *v1 = yyjson_mut_obj_iter_get(&iter, "k1");
yyjson_mut_val *v3 = yyjson_mut_obj_iter_get(&iter, "k3");
@endcode
@see `yyjson_mut_obj_iter_get()` and `yyjson_mut_obj_iter_getn()`
*/
yyjson_mut_obj_iter :: struct {
    idx: u64; /**< next key's index */
    max: u64; /**< maximum key index (obj.size) */
    cur: *yyjson_mut_val; /**< current key */
    pre: *yyjson_mut_val; /**< previous key */
    obj: *yyjson_mut_val; /**< the object being iterated */
}

/**
Initialize an iterator for this object.

@param obj The object to be iterated over.
If `obj` is NULL or not an object, `iter` is cleared.
@param iter The iterator to be initialized.
If `iter` is NULL, returns false.
@return true if the `iter` has been successfully initialized.

@note The iterator does not need to be destroyed.
*/
yyjson_mut_obj_iter_init :: (obj: *yyjson_mut_val, iter: *yyjson_mut_obj_iter) -> bool #foreign libyyjson;

/**
Create an iterator with an object, same as `yyjson_mut_obj_iter_init()`.

@param obj The object to be iterated over.
If `obj` is NULL or not an object, returns an empty iterator.
@return A new iterator for the object.

@note The iterator does not need to be destroyed.
*/
yyjson_mut_obj_iter_with :: (obj: *yyjson_mut_val) -> yyjson_mut_obj_iter #foreign libyyjson;

/**
Returns whether the iteration has more elements.
If `iter` is NULL, returns false.
*/
yyjson_mut_obj_iter_has_next :: (iter: *yyjson_mut_obj_iter) -> bool #foreign libyyjson;

/**
Returns the next key in the iteration, or NULL on end.
If `iter` is NULL, returns NULL.
*/
yyjson_mut_obj_iter_next :: (iter: *yyjson_mut_obj_iter) -> *yyjson_mut_val #foreign libyyjson;

/**
Returns the value for key inside the iteration.
If `iter` is NULL, returns NULL.
*/
yyjson_mut_obj_iter_get_val :: (key: *yyjson_mut_val) -> *yyjson_mut_val #foreign libyyjson;

/**
Removes current key-value pair in the iteration, returns the removed value.
If `iter` is NULL, returns NULL.
*/
yyjson_mut_obj_iter_remove :: (iter: *yyjson_mut_obj_iter) -> *yyjson_mut_val #foreign libyyjson;

/**
Iterates to a specified key and returns the value.

This function does the same thing as `yyjson_mut_obj_get()`, but is much faster
if the ordering of the keys is known at compile-time and you are using the same
order to look up the values. If the key exists in this object, then the
iterator will stop at the next key, otherwise the iterator will not change and
NULL is returned.

@param iter The object iterator, should not be NULL.
@param key The key, should be a UTF-8 string with null-terminator.
@return The value to which the specified key is mapped.
NULL if the key is not found or arguments are invalid.

@warning This function takes a linear search time if the key is not nearby.
*/
yyjson_mut_obj_iter_get :: (iter: *yyjson_mut_obj_iter, key: *u8) -> *yyjson_mut_val #foreign libyyjson;

/**
Iterates to a specified key and returns the value.

This function does the same thing as `yyjson_mut_obj_getn()` but is much faster
if the ordering of the keys is known at compile-time and you are using the same
order to look up the values. If the key exists in this object, then the
iterator will stop at the next key, otherwise the iterator will not change and
NULL is returned.

@param iter The object iterator, should not be NULL.
@param key The key, should be a UTF-8 string, null-terminator is not required.
@param key_len The length of `key`, in bytes.
@return The value to which the specified key is mapped.
NULL if the key is not found or arguments are invalid.

@warning This function takes a linear search time if the key is not nearby.
*/
yyjson_mut_obj_iter_getn :: (iter: *yyjson_mut_obj_iter, key: *u8, key_len: u64) -> *yyjson_mut_val #foreign libyyjson;

/** Creates and returns a mutable object, returns NULL on error. */
yyjson_mut_obj :: (doc: *yyjson_mut_doc) -> *yyjson_mut_val #foreign libyyjson;

/**
Creates and returns a mutable object with keys and values, returns NULL on
error. The keys and values are not copied. They should be null-terminated
UTF-8 strings.

@warning The input strings are not copied; you should keep them
unmodified for the lifetime of this JSON document.

@b Example
@code
const char *keys[2] = { "id", "name" };
const char *vals[2] = { "01", "Harry" };
yyjson_mut_val *obj = yyjson_mut_obj_with_str(doc, keys, vals, 2);
@endcode
*/
yyjson_mut_obj_with_str :: (doc: *yyjson_mut_doc, keys: **u8, vals: **u8, count: u64) -> *yyjson_mut_val #foreign libyyjson;

/**
Creates and returns a mutable object with key-value pairs and pair count,
returns NULL on error. The keys and values are not copied. They should be
null-terminated UTF-8 strings.

@warning The input strings are not copied; you should keep them
unmodified for the lifetime of this JSON document.

@b Example
@code
const char *kv_pairs[4] = { "id", "01", "name", "Harry" };
yyjson_mut_val *obj = yyjson_mut_obj_with_kv(doc, kv_pairs, 2);
@endcode
*/
yyjson_mut_obj_with_kv :: (doc: *yyjson_mut_doc, kv_pairs: **u8, pair_count: u64) -> *yyjson_mut_val #foreign libyyjson;

/**
Adds a key-value pair at the end of the object.
This function allows duplicate keys in one object.
@param obj The object to which the new key-value pair is to be added.
@param key The key, should be a string which is created by `yyjson_mut_str()`,
`yyjson_mut_strn()`, `yyjson_mut_strcpy()` or `yyjson_mut_strncpy()`.
@param val The value to add to the object.
@return Whether the operation was successful.
*/
yyjson_mut_obj_add :: (obj: *yyjson_mut_val, key: *yyjson_mut_val, val: *yyjson_mut_val) -> bool #foreign libyyjson;

/**
Sets a key-value pair at the end of the object.
This function may remove all key-value pairs for the given key before adding.
@param obj The object to which the new key-value pair is to be added.
@param key The key, should be a string which is created by `yyjson_mut_str()`,
`yyjson_mut_strn()`, `yyjson_mut_strcpy()` or `yyjson_mut_strncpy()`.
@param val The value to add to the object. If this value is null, the behavior
is the same as `yyjson_mut_obj_remove()`.
@return Whether the operation was successful.
*/
yyjson_mut_obj_put :: (obj: *yyjson_mut_val, key: *yyjson_mut_val, val: *yyjson_mut_val) -> bool #foreign libyyjson;

/**
Inserts a key-value pair to the object at the given position.
This function allows duplicate keys in one object.
@param obj The object to which the new key-value pair is to be added.
@param key The key, should be a string which is created by `yyjson_mut_str()`,
`yyjson_mut_strn()`, `yyjson_mut_strcpy()` or `yyjson_mut_strncpy()`.
@param val The value to add to the object.
@param idx The index to which to insert the new pair.
@return Whether the operation was successful.
*/
yyjson_mut_obj_insert :: (obj: *yyjson_mut_val, key: *yyjson_mut_val, val: *yyjson_mut_val, idx: u64) -> bool #foreign libyyjson;

/**
Removes all key-value pairs from the object with the given key.
@param obj The object from which the key-value pair is to be removed.
@param key The key, should be a string value.
@return The first matched value, or NULL if no matched value.
@warning This function takes a linear search time.
*/
yyjson_mut_obj_remove :: (obj: *yyjson_mut_val, key: *yyjson_mut_val) -> *yyjson_mut_val #foreign libyyjson;

/**
Removes all key-value pairs from the object with the given key.
@param obj The object from which the key-value pair is to be removed.
@param key The key, should be a UTF-8 string with null-terminator.
@return The first matched value, or NULL if no matched value.
@warning This function takes a linear search time.
*/
yyjson_mut_obj_remove_key :: (obj: *yyjson_mut_val, key: *u8) -> *yyjson_mut_val #foreign libyyjson;

/**
Removes all key-value pairs from the object with the given key.
@param obj The object from which the key-value pair is to be removed.
@param key The key, should be a UTF-8 string, null-terminator is not required.
@param key_len The length of the key.
@return The first matched value, or NULL if no matched value.
@warning This function takes a linear search time.
*/
yyjson_mut_obj_remove_keyn :: (obj: *yyjson_mut_val, key: *u8, key_len: u64) -> *yyjson_mut_val #foreign libyyjson;

/**
Removes all key-value pairs in this object.
@param obj The object from which all of the values are to be removed.
@return Whether the operation was successful.
*/
yyjson_mut_obj_clear :: (obj: *yyjson_mut_val) -> bool #foreign libyyjson;

/**
Replaces value from the object with given key.
If the key does not exist, or the value is NULL, it will fail.
@param obj The object to which the value is to be replaced.
@param key The key, should be a string value.
@param val The value to replace into the object.
@return Whether the operation was successful.
@warning This function takes a linear search time.
*/
yyjson_mut_obj_replace :: (obj: *yyjson_mut_val, key: *yyjson_mut_val, val: *yyjson_mut_val) -> bool #foreign libyyjson;

/**
Rotates key-value pairs in the object for the given number of times.
For example: `{"a":1,"b":2,"c":3,"d":4}` rotate 1 is
`{"b":2,"c":3,"d":4,"a":1}`.
@param obj The object to be rotated.
@param idx Index (or times) to rotate.
@return Whether the operation was successful.
@warning This function takes a linear search time.
*/
yyjson_mut_obj_rotate :: (obj: *yyjson_mut_val, idx: u64) -> bool #foreign libyyjson;

/** Adds a `null` value at the end of the object.
The `key` should be a null-terminated UTF-8 string.
This function allows duplicate keys in one object.

@warning The key string is not copied, you should keep the string
unmodified for the lifetime of this JSON document. */
yyjson_mut_obj_add_null :: (doc: *yyjson_mut_doc, obj: *yyjson_mut_val, key: *u8) -> bool #foreign libyyjson;

/** Adds a `true` value at the end of the object.
The `key` should be a null-terminated UTF-8 string.
This function allows duplicate keys in one object.

@warning The key string is not copied, you should keep the string
unmodified for the lifetime of this JSON document. */
yyjson_mut_obj_add_true :: (doc: *yyjson_mut_doc, obj: *yyjson_mut_val, key: *u8) -> bool #foreign libyyjson;

/** Adds a `false` value at the end of the object.
The `key` should be a null-terminated UTF-8 string.
This function allows duplicate keys in one object.

@warning The key string is not copied, you should keep the string
unmodified for the lifetime of this JSON document. */
yyjson_mut_obj_add_false :: (doc: *yyjson_mut_doc, obj: *yyjson_mut_val, key: *u8) -> bool #foreign libyyjson;

/** Adds a bool value at the end of the object.
The `key` should be a null-terminated UTF-8 string.
This function allows duplicate keys in one object.

@warning The key string is not copied, you should keep the string
unmodified for the lifetime of this JSON document. */
yyjson_mut_obj_add_bool :: (doc: *yyjson_mut_doc, obj: *yyjson_mut_val, key: *u8, val: bool) -> bool #foreign libyyjson;

/** Adds an unsigned integer value at the end of the object.
The `key` should be a null-terminated UTF-8 string.
This function allows duplicate keys in one object.

@warning The key string is not copied, you should keep the string
unmodified for the lifetime of this JSON document. */
yyjson_mut_obj_add_uint :: (doc: *yyjson_mut_doc, obj: *yyjson_mut_val, key: *u8, val: u64) -> bool #foreign libyyjson;

/** Adds a signed integer value at the end of the object.
The `key` should be a null-terminated UTF-8 string.
This function allows duplicate keys in one object.

@warning The key string is not copied, you should keep the string
unmodified for the lifetime of this JSON document. */
yyjson_mut_obj_add_sint :: (doc: *yyjson_mut_doc, obj: *yyjson_mut_val, key: *u8, val: s64) -> bool #foreign libyyjson;

/** Adds an int value at the end of the object.
The `key` should be a null-terminated UTF-8 string.
This function allows duplicate keys in one object.

@warning The key string is not copied, you should keep the string
unmodified for the lifetime of this JSON document. */
yyjson_mut_obj_add_int :: (doc: *yyjson_mut_doc, obj: *yyjson_mut_val, key: *u8, val: s64) -> bool #foreign libyyjson;

/** Adds a float value at the end of the object.
The `key` should be a null-terminated UTF-8 string.
This function allows duplicate keys in one object.

@warning The key string is not copied, you should keep the string
unmodified for the lifetime of this JSON document. */
yyjson_mut_obj_add_float :: (doc: *yyjson_mut_doc, obj: *yyjson_mut_val, key: *u8, val: float) -> bool #foreign libyyjson;

/** Adds a double value at the end of the object.
The `key` should be a null-terminated UTF-8 string.
This function allows duplicate keys in one object.

@warning The key string is not copied, you should keep the string
unmodified for the lifetime of this JSON document. */
yyjson_mut_obj_add_double :: (doc: *yyjson_mut_doc, obj: *yyjson_mut_val, key: *u8, val: float64) -> bool #foreign libyyjson;

/** Adds a real value at the end of the object.
The `key` should be a null-terminated UTF-8 string.
This function allows duplicate keys in one object.

@warning The key string is not copied, you should keep the string
unmodified for the lifetime of this JSON document. */
yyjson_mut_obj_add_real :: (doc: *yyjson_mut_doc, obj: *yyjson_mut_val, key: *u8, val: float64) -> bool #foreign libyyjson;

/** Adds a string value at the end of the object.
The `key` and `val` should be null-terminated UTF-8 strings.
This function allows duplicate keys in one object.

@warning The key/value strings are not copied, you should keep these strings
unmodified for the lifetime of this JSON document. */
yyjson_mut_obj_add_str :: (doc: *yyjson_mut_doc, obj: *yyjson_mut_val, key: *u8, val: *u8) -> bool #foreign libyyjson;

/** Adds a string value at the end of the object.
The `key` should be a null-terminated UTF-8 string.
The `val` should be a UTF-8 string, null-terminator is not required.
The `len` should be the length of the `val`, in bytes.
This function allows duplicate keys in one object.

@warning The key/value strings are not copied, you should keep these strings
unmodified for the lifetime of this JSON document. */
yyjson_mut_obj_add_strn :: (doc: *yyjson_mut_doc, obj: *yyjson_mut_val, key: *u8, val: *u8, len: u64) -> bool #foreign libyyjson;

/** Adds a string value at the end of the object.
The `key` and `val` should be null-terminated UTF-8 strings.
The value string is copied.
This function allows duplicate keys in one object.

@warning The key string is not copied, you should keep the string
unmodified for the lifetime of this JSON document. */
yyjson_mut_obj_add_strcpy :: (doc: *yyjson_mut_doc, obj: *yyjson_mut_val, key: *u8, val: *u8) -> bool #foreign libyyjson;

/** Adds a string value at the end of the object.
The `key` should be a null-terminated UTF-8 string.
The `val` should be a UTF-8 string, null-terminator is not required.
The `len` should be the length of the `val`, in bytes.
This function allows duplicate keys in one object.

@warning The key strings are not copied, you should keep these strings
unmodified for the lifetime of this JSON document. */
yyjson_mut_obj_add_strncpy :: (doc: *yyjson_mut_doc, obj: *yyjson_mut_val, key: *u8, val: *u8, len: u64) -> bool #foreign libyyjson;

/**
Creates and adds a new array to the target object.
The `key` should be a null-terminated UTF-8 string.
This function allows duplicate keys in one object.

@warning The key string is not copied, you should keep these strings
unmodified for the lifetime of this JSON document.
@return The new array, or NULL on error.
*/
yyjson_mut_obj_add_arr :: (doc: *yyjson_mut_doc, obj: *yyjson_mut_val, key: *u8) -> *yyjson_mut_val #foreign libyyjson;

/**
Creates and adds a new object to the target object.
The `key` should be a null-terminated UTF-8 string.
This function allows duplicate keys in one object.

@warning The key string is not copied, you should keep these strings
unmodified for the lifetime of this JSON document.
@return The new object, or NULL on error.
*/
yyjson_mut_obj_add_obj :: (doc: *yyjson_mut_doc, obj: *yyjson_mut_val, key: *u8) -> *yyjson_mut_val #foreign libyyjson;

/** Adds a JSON value at the end of the object.
The `key` should be a null-terminated UTF-8 string.
This function allows duplicate keys in one object.

@warning The key string is not copied, you should keep the string
unmodified for the lifetime of this JSON document. */
yyjson_mut_obj_add_val :: (doc: *yyjson_mut_doc, obj: *yyjson_mut_val, key: *u8, val: *yyjson_mut_val) -> bool #foreign libyyjson;

/** Removes all key-value pairs for the given key.
Returns the first value to which the specified key is mapped or NULL if this
object contains no mapping for the key.
The `key` should be a null-terminated UTF-8 string.

@warning This function takes a linear search time. */
yyjson_mut_obj_remove_str :: (obj: *yyjson_mut_val, key: *u8) -> *yyjson_mut_val #foreign libyyjson;

/** Removes all key-value pairs for the given key.
Returns the first value to which the specified key is mapped or NULL if this
object contains no mapping for the key.
The `key` should be a UTF-8 string, null-terminator is not required.
The `len` should be the length of the key, in bytes.

@warning This function takes a linear search time. */
yyjson_mut_obj_remove_strn :: (obj: *yyjson_mut_val, key: *u8, len: u64) -> *yyjson_mut_val #foreign libyyjson;

/** Replaces all matching keys with the new key.
Returns true if at least one key was renamed.
The `key` and `new_key` should be a null-terminated UTF-8 string.
The `new_key` is copied and held by doc.

@warning This function takes a linear search time.
If `new_key` already exists, it will cause duplicate keys.
*/
yyjson_mut_obj_rename_key :: (doc: *yyjson_mut_doc, obj: *yyjson_mut_val, key: *u8, new_key: *u8) -> bool #foreign libyyjson;

/** Replaces all matching keys with the new key.
Returns true if at least one key was renamed.
The `key` and `new_key` should be a UTF-8 string,
null-terminator is not required. The `new_key` is copied and held by doc.

@warning This function takes a linear search time.
If `new_key` already exists, it will cause duplicate keys.
*/
yyjson_mut_obj_rename_keyn :: (doc: *yyjson_mut_doc, obj: *yyjson_mut_val, key: *u8, len: u64, new_key: *u8, new_len: u64) -> bool #foreign libyyjson;

/** JSON Pointer error code. */
yyjson_ptr_code :: u32;

/** No JSON pointer error. */
YYJSON_PTR_ERR_NONE: yyjson_ptr_code : 0;

/** Invalid input parameter, such as NULL input. */
YYJSON_PTR_ERR_PARAMETER: yyjson_ptr_code : 1;

/** JSON pointer syntax error, such as invalid escape or missing prefix. */
YYJSON_PTR_ERR_SYNTAX: yyjson_ptr_code : 2;

/** JSON pointer resolve failed, such as index out of range, key not found. */
YYJSON_PTR_ERR_RESOLVE: yyjson_ptr_code : 3;

/** Document's root is NULL, but it is required for the function call. */
YYJSON_PTR_ERR_NULL_ROOT: yyjson_ptr_code : 4;

/** Cannot set root as the target is not a document. */
YYJSON_PTR_ERR_SET_ROOT: yyjson_ptr_code : 5;

/** The memory allocation failed and a new value could not be created. */
YYJSON_PTR_ERR_MEMORY_ALLOCATION: yyjson_ptr_code : 6;

/** Error information for JSON pointer. */
yyjson_ptr_err :: struct {
    /** Error code, see `yyjson_ptr_code` for all possible values. */
    code: yyjson_ptr_code;

    /** Error message, constant, no need to free (NULL if no error). */
    msg:  *u8;

    /** Error byte position for input JSON pointer (0 if no error). */
    pos:  u64;
}

/**
A context for JSON pointer operation.

This struct stores the context of JSON Pointer operation result. The struct
can be used with three helper functions: `ctx_append()`, `ctx_replace()`, and
`ctx_remove()`, which perform the corresponding operations on the container
without re-parsing the JSON Pointer.

For example:
@code
// doc before: {"a":[0,1,null]}
// ptr: "/a/2"
val = yyjson_mut_doc_ptr_getx(doc, ptr, strlen(ptr), &ctx, &err);
if (yyjson_is_null(val)) {
yyjson_ptr_ctx_remove(&ctx);
}
// doc after: {"a":[0,1]}
@endcode
*/
yyjson_ptr_ctx :: struct {
    /**
    The container (parent) of the target value. It can be either an array or
    an object. If the target location has no value, but all its parent
    containers exist, and the target location can be used to insert a new
    value, then `ctn` is the parent container of the target location.
    Otherwise, `ctn` is NULL.
    */
    ctn: *yyjson_mut_val;

    /**
    The previous sibling of the target value. It can be either a value in an
    array or a key in an object. As the container is a `circular linked list`
    of elements, `pre` is the previous node of the target value. If the
    operation is `add` or `set`, then `pre` is the previous node of the new
    value, not the original target value. If the target value does not exist,
    `pre` is NULL.
    */
    pre: *yyjson_mut_val;

    /**
    The removed value if the operation is `set`, `replace` or `remove`. It can
    be used to restore the original state of the document if needed.
    */
    old: *yyjson_mut_val;
}

/**
Get value by a JSON Pointer.
@param doc The JSON document to be queried.
@param ptr The JSON pointer string (UTF-8 with null-terminator).
@return The value referenced by the JSON pointer.
NULL if `doc` or `ptr` is NULL, or the JSON pointer cannot be resolved.
*/
yyjson_doc_ptr_get :: (doc: *yyjson_doc, ptr: *u8) -> *yyjson_val #foreign libyyjson;

/**
Get value by a JSON Pointer.
@param doc The JSON document to be queried.
@param ptr The JSON pointer string (UTF-8, null-terminator is not required).
@param len The length of `ptr` in bytes.
@return The value referenced by the JSON pointer.
NULL if `doc` or `ptr` is NULL, or the JSON pointer cannot be resolved.
*/
yyjson_doc_ptr_getn :: (doc: *yyjson_doc, ptr: *u8, len: u64) -> *yyjson_val #foreign libyyjson;

/**
Get value by a JSON Pointer.
@param doc The JSON document to be queried.
@param ptr The JSON pointer string (UTF-8, null-terminator is not required).
@param len The length of `ptr` in bytes.
@param err A pointer to store the error information, or NULL if not needed.
@return The value referenced by the JSON pointer.
NULL if `doc` or `ptr` is NULL, or the JSON pointer cannot be resolved.
*/
yyjson_doc_ptr_getx :: (doc: *yyjson_doc, ptr: *u8, len: u64, err: *yyjson_ptr_err) -> *yyjson_val #foreign libyyjson;

/**
Get value by a JSON Pointer.
@param val The JSON value to be queried.
@param ptr The JSON pointer string (UTF-8 with null-terminator).
@return The value referenced by the JSON pointer.
NULL if `val` or `ptr` is NULL, or the JSON pointer cannot be resolved.
*/
yyjson_ptr_get :: (val: *yyjson_val, ptr: *u8) -> *yyjson_val #foreign libyyjson;

/**
Get value by a JSON Pointer.
@param val The JSON value to be queried.
@param ptr The JSON pointer string (UTF-8, null-terminator is not required).
@param len The length of `ptr` in bytes.
@return The value referenced by the JSON pointer.
NULL if `val` or `ptr` is NULL, or the JSON pointer cannot be resolved.
*/
yyjson_ptr_getn :: (val: *yyjson_val, ptr: *u8, len: u64) -> *yyjson_val #foreign libyyjson;

/**
Get value by a JSON Pointer.
@param val The JSON value to be queried.
@param ptr The JSON pointer string (UTF-8, null-terminator is not required).
@param len The length of `ptr` in bytes.
@param err A pointer to store the error information, or NULL if not needed.
@return The value referenced by the JSON pointer.
NULL if `val` or `ptr` is NULL, or the JSON pointer cannot be resolved.
*/
yyjson_ptr_getx :: (val: *yyjson_val, ptr: *u8, len: u64, err: *yyjson_ptr_err) -> *yyjson_val #foreign libyyjson;

/**
Get value by a JSON Pointer.
@param doc The JSON document to be queried.
@param ptr The JSON pointer string (UTF-8 with null-terminator).
@return The value referenced by the JSON pointer.
NULL if `doc` or `ptr` is NULL, or the JSON pointer cannot be resolved.
*/
yyjson_mut_doc_ptr_get :: (doc: *yyjson_mut_doc, ptr: *u8) -> *yyjson_mut_val #foreign libyyjson;

/**
Get value by a JSON Pointer.
@param doc The JSON document to be queried.
@param ptr The JSON pointer string (UTF-8, null-terminator is not required).
@param len The length of `ptr` in bytes.
@return The value referenced by the JSON pointer.
NULL if `doc` or `ptr` is NULL, or the JSON pointer cannot be resolved.
*/
yyjson_mut_doc_ptr_getn :: (doc: *yyjson_mut_doc, ptr: *u8, len: u64) -> *yyjson_mut_val #foreign libyyjson;

/**
Get value by a JSON Pointer.
@param doc The JSON document to be queried.
@param ptr The JSON pointer string (UTF-8, null-terminator is not required).
@param len The length of `ptr` in bytes.
@param ctx A pointer to store the result context, or NULL if not needed.
@param err A pointer to store the error information, or NULL if not needed.
@return The value referenced by the JSON pointer.
NULL if `doc` or `ptr` is NULL, or the JSON pointer cannot be resolved.
*/
yyjson_mut_doc_ptr_getx :: (doc: *yyjson_mut_doc, ptr: *u8, len: u64, ctx: *yyjson_ptr_ctx, err: *yyjson_ptr_err) -> *yyjson_mut_val #foreign libyyjson;

/**
Get value by a JSON Pointer.
@param val The JSON value to be queried.
@param ptr The JSON pointer string (UTF-8 with null-terminator).
@return The value referenced by the JSON pointer.
NULL if `val` or `ptr` is NULL, or the JSON pointer cannot be resolved.
*/
yyjson_mut_ptr_get :: (val: *yyjson_mut_val, ptr: *u8) -> *yyjson_mut_val #foreign libyyjson;

/**
Get value by a JSON Pointer.
@param val The JSON value to be queried.
@param ptr The JSON pointer string (UTF-8, null-terminator is not required).
@param len The length of `ptr` in bytes.
@return The value referenced by the JSON pointer.
NULL if `val` or `ptr` is NULL, or the JSON pointer cannot be resolved.
*/
yyjson_mut_ptr_getn :: (val: *yyjson_mut_val, ptr: *u8, len: u64) -> *yyjson_mut_val #foreign libyyjson;

/**
Get value by a JSON Pointer.
@param val The JSON value to be queried.
@param ptr The JSON pointer string (UTF-8, null-terminator is not required).
@param len The length of `ptr` in bytes.
@param ctx A pointer to store the result context, or NULL if not needed.
@param err A pointer to store the error information, or NULL if not needed.
@return The value referenced by the JSON pointer.
NULL if `val` or `ptr` is NULL, or the JSON pointer cannot be resolved.
*/
yyjson_mut_ptr_getx :: (val: *yyjson_mut_val, ptr: *u8, len: u64, ctx: *yyjson_ptr_ctx, err: *yyjson_ptr_err) -> *yyjson_mut_val #foreign libyyjson;

/**
Add (insert) value by a JSON pointer.
@param doc The target JSON document.
@param ptr The JSON pointer string (UTF-8 with null-terminator).
@param new_val The value to be added.
@return true if JSON pointer is valid and new value is added, false otherwise.
@note The parent nodes will be created if they do not exist.
*/
yyjson_mut_doc_ptr_add :: (doc: *yyjson_mut_doc, ptr: *u8, new_val: *yyjson_mut_val) -> bool #foreign libyyjson;

/**
Add (insert) value by a JSON pointer.
@param doc The target JSON document.
@param ptr The JSON pointer string (UTF-8, null-terminator is not required).
@param len The length of `ptr` in bytes.
@param new_val The value to be added.
@return true if JSON pointer is valid and new value is added, false otherwise.
@note The parent nodes will be created if they do not exist.
*/
yyjson_mut_doc_ptr_addn :: (doc: *yyjson_mut_doc, ptr: *u8, len: u64, new_val: *yyjson_mut_val) -> bool #foreign libyyjson;

/**
Add (insert) value by a JSON pointer.
@param doc The target JSON document.
@param ptr The JSON pointer string (UTF-8, null-terminator is not required).
@param len The length of `ptr` in bytes.
@param new_val The value to be added.
@param create_parent Whether to create parent nodes if they do not exist.
@param ctx A pointer to store the result context, or NULL if not needed.
@param err A pointer to store the error information, or NULL if not needed.
@return true if JSON pointer is valid and new value is added, false otherwise.
*/
yyjson_mut_doc_ptr_addx :: (doc: *yyjson_mut_doc, ptr: *u8, len: u64, new_val: *yyjson_mut_val, create_parent: bool, ctx: *yyjson_ptr_ctx, err: *yyjson_ptr_err) -> bool #foreign libyyjson;

/**
Add (insert) value by a JSON pointer.
@param val The target JSON value.
@param ptr The JSON pointer string (UTF-8 with null-terminator).
@param doc Only used to create new values when needed.
@param new_val The value to be added.
@return true if JSON pointer is valid and new value is added, false otherwise.
@note The parent nodes will be created if they do not exist.
*/
yyjson_mut_ptr_add :: (val: *yyjson_mut_val, ptr: *u8, new_val: *yyjson_mut_val, doc: *yyjson_mut_doc) -> bool #foreign libyyjson;

/**
Add (insert) value by a JSON pointer.
@param val The target JSON value.
@param ptr The JSON pointer string (UTF-8, null-terminator is not required).
@param len The length of `ptr` in bytes.
@param doc Only used to create new values when needed.
@param new_val The value to be added.
@return true if JSON pointer is valid and new value is added, false otherwise.
@note The parent nodes will be created if they do not exist.
*/
yyjson_mut_ptr_addn :: (val: *yyjson_mut_val, ptr: *u8, len: u64, new_val: *yyjson_mut_val, doc: *yyjson_mut_doc) -> bool #foreign libyyjson;

/**
Add (insert) value by a JSON pointer.
@param val The target JSON value.
@param ptr The JSON pointer string (UTF-8, null-terminator is not required).
@param len The length of `ptr` in bytes.
@param doc Only used to create new values when needed.
@param new_val The value to be added.
@param create_parent Whether to create parent nodes if they do not exist.
@param ctx A pointer to store the result context, or NULL if not needed.
@param err A pointer to store the error information, or NULL if not needed.
@return true if JSON pointer is valid and new value is added, false otherwise.
*/
yyjson_mut_ptr_addx :: (val: *yyjson_mut_val, ptr: *u8, len: u64, new_val: *yyjson_mut_val, doc: *yyjson_mut_doc, create_parent: bool, ctx: *yyjson_ptr_ctx, err: *yyjson_ptr_err) -> bool #foreign libyyjson;

/**
Set value by a JSON pointer.
@param doc The target JSON document.
@param ptr The JSON pointer string (UTF-8 with null-terminator).
@param new_val The value to be set, pass NULL to remove.
@return true if JSON pointer is valid and new value is set, false otherwise.
@note The parent nodes will be created if they do not exist.
If the target value already exists, it will be replaced by the new value.
*/
yyjson_mut_doc_ptr_set :: (doc: *yyjson_mut_doc, ptr: *u8, new_val: *yyjson_mut_val) -> bool #foreign libyyjson;

/**
Set value by a JSON pointer.
@param doc The target JSON document.
@param ptr The JSON pointer string (UTF-8, null-terminator is not required).
@param len The length of `ptr` in bytes.
@param new_val The value to be set, pass NULL to remove.
@return true if JSON pointer is valid and new value is set, false otherwise.
@note The parent nodes will be created if they do not exist.
If the target value already exists, it will be replaced by the new value.
*/
yyjson_mut_doc_ptr_setn :: (doc: *yyjson_mut_doc, ptr: *u8, len: u64, new_val: *yyjson_mut_val) -> bool #foreign libyyjson;

/**
Set value by a JSON pointer.
@param doc The target JSON document.
@param ptr The JSON pointer string (UTF-8, null-terminator is not required).
@param len The length of `ptr` in bytes.
@param new_val The value to be set, pass NULL to remove.
@param create_parent Whether to create parent nodes if they do not exist.
@param ctx A pointer to store the result context, or NULL if not needed.
@param err A pointer to store the error information, or NULL if not needed.
@return true if JSON pointer is valid and new value is set, false otherwise.
@note If the target value already exists, it will be replaced by the new value.
*/
yyjson_mut_doc_ptr_setx :: (doc: *yyjson_mut_doc, ptr: *u8, len: u64, new_val: *yyjson_mut_val, create_parent: bool, ctx: *yyjson_ptr_ctx, err: *yyjson_ptr_err) -> bool #foreign libyyjson;

/**
Set value by a JSON pointer.
@param val The target JSON value.
@param ptr The JSON pointer string (UTF-8 with null-terminator).
@param new_val The value to be set, pass NULL to remove.
@param doc Only used to create new values when needed.
@return true if JSON pointer is valid and new value is set, false otherwise.
@note The parent nodes will be created if they do not exist.
If the target value already exists, it will be replaced by the new value.
*/
yyjson_mut_ptr_set :: (val: *yyjson_mut_val, ptr: *u8, new_val: *yyjson_mut_val, doc: *yyjson_mut_doc) -> bool #foreign libyyjson;

/**
Set value by a JSON pointer.
@param val The target JSON value.
@param ptr The JSON pointer string (UTF-8, null-terminator is not required).
@param len The length of `ptr` in bytes.
@param new_val The value to be set, pass NULL to remove.
@param doc Only used to create new values when needed.
@return true if JSON pointer is valid and new value is set, false otherwise.
@note The parent nodes will be created if they do not exist.
If the target value already exists, it will be replaced by the new value.
*/
yyjson_mut_ptr_setn :: (val: *yyjson_mut_val, ptr: *u8, len: u64, new_val: *yyjson_mut_val, doc: *yyjson_mut_doc) -> bool #foreign libyyjson;

/**
Set value by a JSON pointer.
@param val The target JSON value.
@param ptr The JSON pointer string (UTF-8, null-terminator is not required).
@param len The length of `ptr` in bytes.
@param new_val The value to be set, pass NULL to remove.
@param doc Only used to create new values when needed.
@param create_parent Whether to create parent nodes if they do not exist.
@param ctx A pointer to store the result context, or NULL if not needed.
@param err A pointer to store the error information, or NULL if not needed.
@return true if JSON pointer is valid and new value is set, false otherwise.
@note If the target value already exists, it will be replaced by the new value.
*/
yyjson_mut_ptr_setx :: (val: *yyjson_mut_val, ptr: *u8, len: u64, new_val: *yyjson_mut_val, doc: *yyjson_mut_doc, create_parent: bool, ctx: *yyjson_ptr_ctx, err: *yyjson_ptr_err) -> bool #foreign libyyjson;

/**
Replace value by a JSON pointer.
@param doc The target JSON document.
@param ptr The JSON pointer string (UTF-8 with null-terminator).
@param new_val The new value to replace the old one.
@return The old value that was replaced, or NULL if not found.
*/
yyjson_mut_doc_ptr_replace :: (doc: *yyjson_mut_doc, ptr: *u8, new_val: *yyjson_mut_val) -> *yyjson_mut_val #foreign libyyjson;

/**
Replace value by a JSON pointer.
@param doc The target JSON document.
@param ptr The JSON pointer string (UTF-8, null-terminator is not required).
@param len The length of `ptr` in bytes.
@param new_val The new value to replace the old one.
@return The old value that was replaced, or NULL if not found.
*/
yyjson_mut_doc_ptr_replacen :: (doc: *yyjson_mut_doc, ptr: *u8, len: u64, new_val: *yyjson_mut_val) -> *yyjson_mut_val #foreign libyyjson;

/**
Replace value by a JSON pointer.
@param doc The target JSON document.
@param ptr The JSON pointer string (UTF-8, null-terminator is not required).
@param len The length of `ptr` in bytes.
@param new_val The new value to replace the old one.
@param ctx A pointer to store the result context, or NULL if not needed.
@param err A pointer to store the error information, or NULL if not needed.
@return The old value that was replaced, or NULL if not found.
*/
yyjson_mut_doc_ptr_replacex :: (doc: *yyjson_mut_doc, ptr: *u8, len: u64, new_val: *yyjson_mut_val, ctx: *yyjson_ptr_ctx, err: *yyjson_ptr_err) -> *yyjson_mut_val #foreign libyyjson;

/**
Replace value by a JSON pointer.
@param val The target JSON value.
@param ptr The JSON pointer string (UTF-8 with null-terminator).
@param new_val The new value to replace the old one.
@return The old value that was replaced, or NULL if not found.
*/
yyjson_mut_ptr_replace :: (val: *yyjson_mut_val, ptr: *u8, new_val: *yyjson_mut_val) -> *yyjson_mut_val #foreign libyyjson;

/**
Replace value by a JSON pointer.
@param val The target JSON value.
@param ptr The JSON pointer string (UTF-8, null-terminator is not required).
@param len The length of `ptr` in bytes.
@param new_val The new value to replace the old one.
@return The old value that was replaced, or NULL if not found.
*/
yyjson_mut_ptr_replacen :: (val: *yyjson_mut_val, ptr: *u8, len: u64, new_val: *yyjson_mut_val) -> *yyjson_mut_val #foreign libyyjson;

/**
Replace value by a JSON pointer.
@param val The target JSON value.
@param ptr The JSON pointer string (UTF-8, null-terminator is not required).
@param len The length of `ptr` in bytes.
@param new_val The new value to replace the old one.
@param ctx A pointer to store the result context, or NULL if not needed.
@param err A pointer to store the error information, or NULL if not needed.
@return The old value that was replaced, or NULL if not found.
*/
yyjson_mut_ptr_replacex :: (val: *yyjson_mut_val, ptr: *u8, len: u64, new_val: *yyjson_mut_val, ctx: *yyjson_ptr_ctx, err: *yyjson_ptr_err) -> *yyjson_mut_val #foreign libyyjson;

/**
Remove value by a JSON pointer.
@param doc The target JSON document.
@param ptr The JSON pointer string (UTF-8 with null-terminator).
@return The removed value, or NULL on error.
*/
yyjson_mut_doc_ptr_remove :: (doc: *yyjson_mut_doc, ptr: *u8) -> *yyjson_mut_val #foreign libyyjson;

/**
Remove value by a JSON pointer.
@param doc The target JSON document.
@param ptr The JSON pointer string (UTF-8, null-terminator is not required).
@param len The length of `ptr` in bytes.
@return The removed value, or NULL on error.
*/
yyjson_mut_doc_ptr_removen :: (doc: *yyjson_mut_doc, ptr: *u8, len: u64) -> *yyjson_mut_val #foreign libyyjson;

/**
Remove value by a JSON pointer.
@param doc The target JSON document.
@param ptr The JSON pointer string (UTF-8, null-terminator is not required).
@param len The length of `ptr` in bytes.
@param ctx A pointer to store the result context, or NULL if not needed.
@param err A pointer to store the error information, or NULL if not needed.
@return The removed value, or NULL on error.
*/
yyjson_mut_doc_ptr_removex :: (doc: *yyjson_mut_doc, ptr: *u8, len: u64, ctx: *yyjson_ptr_ctx, err: *yyjson_ptr_err) -> *yyjson_mut_val #foreign libyyjson;

/**
Remove value by a JSON pointer.
@param val The target JSON value.
@param ptr The JSON pointer string (UTF-8 with null-terminator).
@return The removed value, or NULL on error.
*/
yyjson_mut_ptr_remove :: (val: *yyjson_mut_val, ptr: *u8) -> *yyjson_mut_val #foreign libyyjson;

/**
Remove value by a JSON pointer.
@param val The target JSON value.
@param ptr The JSON pointer string (UTF-8, null-terminator is not required).
@param len The length of `ptr` in bytes.
@return The removed value, or NULL on error.
*/
yyjson_mut_ptr_removen :: (val: *yyjson_mut_val, ptr: *u8, len: u64) -> *yyjson_mut_val #foreign libyyjson;

/**
Remove value by a JSON pointer.
@param val The target JSON value.
@param ptr The JSON pointer string (UTF-8, null-terminator is not required).
@param len The length of `ptr` in bytes.
@param ctx A pointer to store the result context, or NULL if not needed.
@param err A pointer to store the error information, or NULL if not needed.
@return The removed value, or NULL on error.
*/
yyjson_mut_ptr_removex :: (val: *yyjson_mut_val, ptr: *u8, len: u64, ctx: *yyjson_ptr_ctx, err: *yyjson_ptr_err) -> *yyjson_mut_val #foreign libyyjson;

/**
Append value by JSON pointer context.
@param ctx The context from the `yyjson_mut_ptr_xxx()` calls.
@param key New key if `ctx->ctn` is object, or NULL if `ctx->ctn` is array.
@param val New value to be added.
@return true on success or false on fail.
*/
yyjson_ptr_ctx_append :: (ctx: *yyjson_ptr_ctx, key: *yyjson_mut_val, val: *yyjson_mut_val) -> bool #foreign libyyjson;

/**
Replace value by JSON pointer context.
@param ctx The context from the `yyjson_mut_ptr_xxx()` calls.
@param val New value to be replaced.
@return true on success or false on fail.
@note On success, the old value will be returned via `ctx->old`.
*/
yyjson_ptr_ctx_replace :: (ctx: *yyjson_ptr_ctx, val: *yyjson_mut_val) -> bool #foreign libyyjson;

/**
Remove value by JSON pointer context.
@param ctx The context from the `yyjson_mut_ptr_xxx()` calls.
@return true on success or false on fail.
@note On success, the old value will be returned via `ctx->old`.
*/
yyjson_ptr_ctx_remove :: (ctx: *yyjson_ptr_ctx) -> bool #foreign libyyjson;

/** Result code for JSON patch. */
yyjson_patch_code :: u32;

/** Success, no error. */
YYJSON_PATCH_SUCCESS: yyjson_patch_code : 0;

/** Invalid parameter, such as NULL input or non-array patch. */
YYJSON_PATCH_ERROR_INVALID_PARAMETER: yyjson_patch_code : 1;

/** Memory allocation failed. */
YYJSON_PATCH_ERROR_MEMORY_ALLOCATION: yyjson_patch_code : 2;

/** JSON patch operation is not object type. */
YYJSON_PATCH_ERROR_INVALID_OPERATION: yyjson_patch_code : 3;

/** JSON patch operation is missing a required key. */
YYJSON_PATCH_ERROR_MISSING_KEY: yyjson_patch_code : 4;

/** JSON patch operation member is invalid. */
YYJSON_PATCH_ERROR_INVALID_MEMBER: yyjson_patch_code : 5;

/** JSON patch `test` operation failed (values not equal). */
YYJSON_PATCH_ERROR_EQUAL: yyjson_patch_code : 6;

/** JSON patch operation failed on JSON pointer. */
YYJSON_PATCH_ERROR_POINTER: yyjson_patch_code : 7;

/** Error information for JSON patch. */
yyjson_patch_err :: struct {
    /** Error code, see `yyjson_patch_code` for all possible values. */
    code: yyjson_patch_code;

    /** Index of the error operation (0 if no error). */
    idx:  u64;

    /** Error message, constant, no need to free (NULL if no error). */
    msg:  *u8;

    /** JSON pointer error if `code == YYJSON_PATCH_ERROR_POINTER`. */
    ptr:  yyjson_ptr_err;
}

/**
Creates and returns a patched JSON value (RFC 6902).
The memory of the returned value is allocated by the `doc`.
The `err` is used to receive error information, pass NULL if not needed.
Returns NULL if the patch could not be applied.
*/
yyjson_patch :: (doc: *yyjson_mut_doc, orig: *yyjson_val, patch: *yyjson_val, err: *yyjson_patch_err) -> *yyjson_mut_val #foreign libyyjson;

/**
Creates and returns a patched JSON value (RFC 6902).
The memory of the returned value is allocated by the `doc`.
The `err` is used to receive error information, pass NULL if not needed.
Returns NULL if the patch could not be applied.
*/
yyjson_mut_patch :: (doc: *yyjson_mut_doc, orig: *yyjson_mut_val, patch: *yyjson_mut_val, err: *yyjson_patch_err) -> *yyjson_mut_val #foreign libyyjson;

/**
Creates and returns a merge-patched JSON value (RFC 7386).
The memory of the returned value is allocated by the `doc`.
Returns NULL if the patch could not be applied.

@warning This function is recursive and may cause a stack overflow if the
object level is too deep.
*/
yyjson_merge_patch :: (doc: *yyjson_mut_doc, orig: *yyjson_val, patch: *yyjson_val) -> *yyjson_mut_val #foreign libyyjson;

/**
Creates and returns a merge-patched JSON value (RFC 7386).
The memory of the returned value is allocated by the `doc`.
Returns NULL if the patch could not be applied.

@warning This function is recursive and may cause a stack overflow if the
object level is too deep.
*/
yyjson_mut_merge_patch :: (doc: *yyjson_mut_doc, orig: *yyjson_mut_val, patch: *yyjson_mut_val) -> *yyjson_mut_val #foreign libyyjson;

/** Payload of a JSON value (8 bytes). */
yyjson_val_uni :: struct {
    _u64: u64;

    #overlay (_u64) i64: s64;
    #overlay (_u64) f64: float64;
    #overlay (_u64) str: *u8;
    #overlay (_u64) ptr: *void;
    #overlay (_u64) ofs: u64;
}

/**
Immutable JSON value, 16 bytes.
*/
yyjson_val :: struct {
    tag: u64; /**< type, subtype and length */
    uni: yyjson_val_uni; /**< payload */
}

yyjson_doc :: struct {
    /** Root value of the document (nonnull). */
    root:     *yyjson_val;

    /** Allocator used by document (nonnull). */
    alc:      yyjson_alc;

    /** The total number of bytes read when parsing JSON (nonzero). */
    dat_read: u64;

    /** The total number of values read when parsing JSON (nonzero). */
    val_read: u64;

    /** The string pool used by JSON values (nullable). */
    str_pool: *u8;
}

/*
Whether the string does not need to be escaped for serialization.
This function is used to optimize the writing speed of small constant strings.
This function works only if the compiler can evaluate it at compile time.

Clang supports it since v8.0,
earlier versions do not support constant_p(strlen) and return false.
GCC supports it since at least v4.4,
earlier versions may compile it as run-time instructions.
ICC supports it since at least v16,
earlier versions are uncertain.

@param str The C string.
@param len The returned value from strlen(str).
*/
unsafe_yyjson_is_str_noesc :: (str: *u8, len: u64) -> bool #foreign libyyjson;

unsafe_yyjson_u64_to_f64 :: (num: u64) -> float64 #foreign libyyjson;

unsafe_yyjson_get_type :: (val: *void) -> yyjson_type #foreign libyyjson;

unsafe_yyjson_get_subtype :: (val: *void) -> yyjson_subtype #foreign libyyjson;

unsafe_yyjson_get_tag :: (val: *void) -> u8 #foreign libyyjson;

unsafe_yyjson_is_raw :: (val: *void) -> bool #foreign libyyjson;

unsafe_yyjson_is_null :: (val: *void) -> bool #foreign libyyjson;

unsafe_yyjson_is_bool :: (val: *void) -> bool #foreign libyyjson;

unsafe_yyjson_is_num :: (val: *void) -> bool #foreign libyyjson;

unsafe_yyjson_is_str :: (val: *void) -> bool #foreign libyyjson;

unsafe_yyjson_is_arr :: (val: *void) -> bool #foreign libyyjson;

unsafe_yyjson_is_obj :: (val: *void) -> bool #foreign libyyjson;

unsafe_yyjson_is_ctn :: (val: *void) -> bool #foreign libyyjson;

unsafe_yyjson_is_uint :: (val: *void) -> bool #foreign libyyjson;

unsafe_yyjson_is_sint :: (val: *void) -> bool #foreign libyyjson;

unsafe_yyjson_is_int :: (val: *void) -> bool #foreign libyyjson;

unsafe_yyjson_is_real :: (val: *void) -> bool #foreign libyyjson;

unsafe_yyjson_is_true :: (val: *void) -> bool #foreign libyyjson;

unsafe_yyjson_is_false :: (val: *void) -> bool #foreign libyyjson;

unsafe_yyjson_arr_is_flat :: (val: *yyjson_val) -> bool #foreign libyyjson;

unsafe_yyjson_get_raw :: (val: *void) -> *u8 #foreign libyyjson;

unsafe_yyjson_get_bool :: (val: *void) -> bool #foreign libyyjson;

unsafe_yyjson_get_uint :: (val: *void) -> u64 #foreign libyyjson;

unsafe_yyjson_get_sint :: (val: *void) -> s64 #foreign libyyjson;

unsafe_yyjson_get_int :: (val: *void) -> s32 #foreign libyyjson;

unsafe_yyjson_get_real :: (val: *void) -> float64 #foreign libyyjson;

unsafe_yyjson_get_num :: (val: *void) -> float64 #foreign libyyjson;

unsafe_yyjson_get_str :: (val: *void) -> *u8 #foreign libyyjson;

unsafe_yyjson_get_len :: (val: *void) -> u64 #foreign libyyjson;

unsafe_yyjson_get_first :: (ctn: *yyjson_val) -> *yyjson_val #foreign libyyjson;

unsafe_yyjson_get_next :: (val: *yyjson_val) -> *yyjson_val #foreign libyyjson;

unsafe_yyjson_equals_strn :: (val: *void, str: *u8, len: u64) -> bool #foreign libyyjson;

unsafe_yyjson_equals_str :: (val: *void, str: *u8) -> bool #foreign libyyjson;

unsafe_yyjson_set_type :: (val: *void, type: yyjson_type, subtype: yyjson_subtype) -> void #foreign libyyjson;

unsafe_yyjson_set_len :: (val: *void, len: u64) -> void #foreign libyyjson;

unsafe_yyjson_set_tag :: (val: *void, type: yyjson_type, subtype: yyjson_subtype, len: u64) -> void #foreign libyyjson;

unsafe_yyjson_inc_len :: (val: *void) -> void #foreign libyyjson;

unsafe_yyjson_set_raw :: (val: *void, raw: *u8, len: u64) -> void #foreign libyyjson;

unsafe_yyjson_set_null :: (val: *void) -> void #foreign libyyjson;

unsafe_yyjson_set_bool :: (val: *void, num: bool) -> void #foreign libyyjson;

unsafe_yyjson_set_uint :: (val: *void, num: u64) -> void #foreign libyyjson;

unsafe_yyjson_set_sint :: (val: *void, num: s64) -> void #foreign libyyjson;

unsafe_yyjson_set_fp_to_fixed :: (val: *void, prec: s32) -> void #foreign libyyjson;

unsafe_yyjson_set_fp_to_float :: (val: *void, flt: bool) -> void #foreign libyyjson;

unsafe_yyjson_set_float :: (val: *void, num: float) -> void #foreign libyyjson;

unsafe_yyjson_set_double :: (val: *void, num: float64) -> void #foreign libyyjson;

unsafe_yyjson_set_real :: (val: *void, num: float64) -> void #foreign libyyjson;

unsafe_yyjson_set_str_noesc :: (val: *void, noesc: bool) -> void #foreign libyyjson;

unsafe_yyjson_set_strn :: (val: *void, str: *u8, len: u64) -> void #foreign libyyjson;

unsafe_yyjson_set_str :: (val: *void, str: *u8) -> void #foreign libyyjson;

unsafe_yyjson_set_arr :: (val: *void, size: u64) -> void #foreign libyyjson;

unsafe_yyjson_set_obj :: (val: *void, size: u64) -> void #foreign libyyjson;

unsafe_yyjson_equals :: (lhs: *yyjson_val, rhs: *yyjson_val) -> bool #foreign libyyjson;

/**
Mutable JSON value, 24 bytes.
The 'tag' and 'uni' fields are the same as immutable value.
The 'next' field links all elements inside the container to be a cycle.
*/
yyjson_mut_val :: struct {
    tag:  u64; /**< type, subtype and length */
    uni:  yyjson_val_uni; /**< payload */
    next: *yyjson_mut_val; /**< the next value in circular linked list */
}

/**
A memory chunk in string memory pool.
*/
yyjson_str_chunk :: struct {
    next:       *yyjson_str_chunk; /* next chunk linked list */
    chunk_size: u64; /* chunk size in bytes */
}

/**
A memory pool to hold all strings in a mutable document.
*/
yyjson_str_pool :: struct {
    cur:            *u8; /* cursor inside current chunk */
    end:            *u8; /* the end of current chunk */
    chunk_size:     u64; /* chunk size in bytes while creating new chunk */
    chunk_size_max: u64; /* maximum chunk size in bytes */
    chunks:         *yyjson_str_chunk; /* a linked list of chunks, nullable */
}

/**
A memory chunk in value memory pool.
`sizeof(yyjson_val_chunk)` should not be larger than `sizeof(yyjson_mut_val)`.
*/
yyjson_val_chunk :: struct {
    next:       *yyjson_val_chunk; /* next chunk linked list */
    chunk_size: u64; /* chunk size in bytes */
}

/**
A memory pool to hold all values in a mutable document.
*/
yyjson_val_pool :: struct {
    cur:            *yyjson_mut_val; /* cursor inside current chunk */
    end:            *yyjson_mut_val; /* the end of current chunk */
    chunk_size:     u64; /* chunk size in bytes while creating new chunk */
    chunk_size_max: u64; /* maximum chunk size in bytes */
    chunks:         *yyjson_val_chunk; /* a linked list of chunks, nullable */
}

yyjson_mut_doc :: struct {
    root:     *yyjson_mut_val; /**< root value of the JSON document, nullable */
    alc:      yyjson_alc; /**< a valid allocator, nonnull */
    str_pool: yyjson_str_pool; /**< string memory pool */
    val_pool: yyjson_val_pool; /**< value memory pool */
}

/* Ensures the capacity to at least equal to the specified byte length. */
unsafe_yyjson_str_pool_grow :: (pool: *yyjson_str_pool, alc: *yyjson_alc, len: u64) -> bool #foreign libyyjson;

/* Ensures the capacity to at least equal to the specified value count. */
unsafe_yyjson_val_pool_grow :: (pool: *yyjson_val_pool, alc: *yyjson_alc, count: u64) -> bool #foreign libyyjson;

/* Allocate memory for string. */
unsafe_yyjson_mut_str_alc :: (doc: *yyjson_mut_doc, len: u64) -> *u8 #foreign libyyjson;

unsafe_yyjson_mut_strncpy :: (doc: *yyjson_mut_doc, str: *u8, len: u64) -> *u8 #foreign libyyjson;

unsafe_yyjson_mut_val :: (doc: *yyjson_mut_doc, count: u64) -> *yyjson_mut_val #foreign libyyjson;

unsafe_yyjson_mut_equals :: (lhs: *yyjson_mut_val, rhs: *yyjson_mut_val) -> bool #foreign libyyjson;

/*==============================================================================
* MARK: - Mutable JSON Object Modification API (Implementation)
*============================================================================*/
unsafe_yyjson_mut_obj_add :: (obj: *yyjson_mut_val, key: *yyjson_mut_val, val: *yyjson_mut_val, len: u64) -> void #foreign libyyjson;

unsafe_yyjson_mut_obj_remove :: (obj: *yyjson_mut_val, key: *u8, key_len: u64) -> *yyjson_mut_val #foreign libyyjson;

unsafe_yyjson_mut_obj_replace :: (obj: *yyjson_mut_val, key: *yyjson_mut_val, val: *yyjson_mut_val) -> bool #foreign libyyjson;

unsafe_yyjson_mut_obj_rotate :: (obj: *yyjson_mut_val, idx: u64) -> void #foreign libyyjson;

/* require: val != NULL, *ptr == '/', len > 0 */
unsafe_yyjson_ptr_getx :: (val: *yyjson_val, ptr: *u8, len: u64, err: *yyjson_ptr_err) -> *yyjson_val #foreign libyyjson;

/* require: val != NULL, *ptr == '/', len > 0 */
unsafe_yyjson_mut_ptr_getx :: (val: *yyjson_mut_val, ptr: *u8, len: u64, ctx: *yyjson_ptr_ctx, err: *yyjson_ptr_err) -> *yyjson_mut_val #foreign libyyjson;

/* require: val/new_val/doc != NULL, *ptr == '/', len > 0 */
unsafe_yyjson_mut_ptr_putx :: (val: *yyjson_mut_val, ptr: *u8, len: u64, new_val: *yyjson_mut_val, doc: *yyjson_mut_doc, create_parent: bool, insert_new: bool, ctx: *yyjson_ptr_ctx, err: *yyjson_ptr_err) -> bool #foreign libyyjson;

/* require: val/err != NULL, *ptr == '/', len > 0 */
unsafe_yyjson_mut_ptr_replacex :: (val: *yyjson_mut_val, ptr: *u8, len: u64, new_val: *yyjson_mut_val, ctx: *yyjson_ptr_ctx, err: *yyjson_ptr_err) -> *yyjson_mut_val #foreign libyyjson;

/* require: val/err != NULL, *ptr == '/', len > 0 */
unsafe_yyjson_mut_ptr_removex :: (val: *yyjson_mut_val, ptr: *u8, len: u64, ctx: *yyjson_ptr_ctx, err: *yyjson_ptr_err) -> *yyjson_mut_val #foreign libyyjson;

/**
Set provided `value` if the JSON Pointer (RFC 6901) exists and is type bool.
Returns true if value at `ptr` exists and is the correct type, otherwise false.
*/
yyjson_ptr_get_bool :: (root: *yyjson_val, ptr: *u8, value: *bool) -> bool #foreign libyyjson;

/**
Set provided `value` if the JSON Pointer (RFC 6901) exists and is an integer
that fits in `uint64_t`. Returns true if successful, otherwise false.
*/
yyjson_ptr_get_uint :: (root: *yyjson_val, ptr: *u8, value: *u64) -> bool #foreign libyyjson;

/**
Set provided `value` if the JSON Pointer (RFC 6901) exists and is an integer
that fits in `int64_t`. Returns true if successful, otherwise false.
*/
yyjson_ptr_get_sint :: (root: *yyjson_val, ptr: *u8, value: *s64) -> bool #foreign libyyjson;

/**
Set provided `value` if the JSON Pointer (RFC 6901) exists and is type real.
Returns true if value at `ptr` exists and is the correct type, otherwise false.
*/
yyjson_ptr_get_real :: (root: *yyjson_val, ptr: *u8, value: *float64) -> bool #foreign libyyjson;

/**
Set provided `value` if the JSON Pointer (RFC 6901) exists and is type sint,
uint or real.
Returns true if value at `ptr` exists and is the correct type, otherwise false.
*/
yyjson_ptr_get_num :: (root: *yyjson_val, ptr: *u8, value: *float64) -> bool #foreign libyyjson;

/**
Set provided `value` if the JSON Pointer (RFC 6901) exists and is type string.
Returns true if value at `ptr` exists and is the correct type, otherwise false.
*/
yyjson_ptr_get_str :: (root: *yyjson_val, ptr: *u8, value: **u8) -> bool #foreign libyyjson;

/** @deprecated renamed to `yyjson_doc_ptr_get` */
yyjson_doc_get_pointer :: (doc: *yyjson_doc, ptr: *u8) -> *yyjson_val #foreign libyyjson;

/** @deprecated renamed to `yyjson_doc_ptr_getn` */
yyjson_doc_get_pointern :: (doc: *yyjson_doc, ptr: *u8, len: u64) -> *yyjson_val #foreign libyyjson;

/** @deprecated renamed to `yyjson_mut_doc_ptr_get` */
yyjson_mut_doc_get_pointer :: (doc: *yyjson_mut_doc, ptr: *u8) -> *yyjson_mut_val #foreign libyyjson;

/** @deprecated renamed to `yyjson_mut_doc_ptr_getn` */
yyjson_mut_doc_get_pointern :: (doc: *yyjson_mut_doc, ptr: *u8, len: u64) -> *yyjson_mut_val #foreign libyyjson;

/** @deprecated renamed to `yyjson_ptr_get` */
yyjson_get_pointer :: (val: *yyjson_val, ptr: *u8) -> *yyjson_val #foreign libyyjson;

/** @deprecated renamed to `yyjson_ptr_getn` */
yyjson_get_pointern :: (val: *yyjson_val, ptr: *u8, len: u64) -> *yyjson_val #foreign libyyjson;

/** @deprecated renamed to `yyjson_mut_ptr_get` */
yyjson_mut_get_pointer :: (val: *yyjson_mut_val, ptr: *u8) -> *yyjson_mut_val #foreign libyyjson;

/** @deprecated renamed to `yyjson_mut_ptr_getn` */
yyjson_mut_get_pointern :: (val: *yyjson_mut_val, ptr: *u8, len: u64) -> *yyjson_mut_val #foreign libyyjson;

/** @deprecated renamed to `yyjson_mut_ptr_getn` */
unsafe_yyjson_get_pointer :: (val: *yyjson_val, ptr: *u8, len: u64) -> *yyjson_val #foreign libyyjson;

/** @deprecated renamed to `unsafe_yyjson_mut_ptr_getx` */
unsafe_yyjson_mut_get_pointer :: (val: *yyjson_mut_val, ptr: *u8, len: u64) -> *yyjson_mut_val #foreign libyyjson;

#scope_file

