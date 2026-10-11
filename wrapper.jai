Raw_JSON_Value :: struct {
    json: string;
}

json_raw_is_null :: (raw: Raw_JSON_Value) -> bool {
    return raw.json.count == 0 || raw.json == "null";
}

json_raw_string :: (text: string) -> Raw_JSON_Value {
    _, json_str := json_write(text);
    return {json_str};
}

JSON_READ_FLAGS :: YYJSON_READ_ALLOW_INVALID_UNICODE;

json_parse :: (text: string, $T: Type) -> ok: bool, T {
    result: T;

    if text.count == 0 {
        return false, result;
    }

    error: yyjson_read_err;
    allocator := context_yyjson_allocator(*context);
    document := yyjson_read_opts(text.data, cast(u64) text.count, JSON_READ_FLAGS, *allocator, *error);
    if !document {
        log_error("Invalid JSON at byte %: %", error.pos, to_string(error.msg));
        return false, result;
    }

    defer yyjson_doc_free(document);

    ok := json_parse_value(yyjson_doc_get_root(document), *result);
    return ok, result;
}

json_parse_value :: (value: *yyjson_val, result: *$T) -> bool {
    if !value || json_type(value) == YYJSON_TYPE_NULL {
        return true;
    }

    #if T == *void {
        return true;
    } else #if T == Raw_JSON_Value {
        result.json = json_value_text(value);
        return true;
    } else #if #run is_string_table(T) {
        if json_type(value) != YYJSON_TYPE_OBJ {
            return type_error(value, "object");
        }

        Value_Type :: T.Value_Type;

        key := json_first_child(value);

        for 1..json_length(value) {
            member_value := json_next(key);

            parsed: Value_Type;

            if !json_parse_value(member_value, *parsed) {
                return false;
            }

            table_set(result, copy_string(json_string_view(key)), parsed);

            key = json_next(member_value);
        }

        return true;
    } else {
        TYPE_TAG :: #run (cast(*Type_Info) T).type;

        #if TYPE_TAG == .BOOL {
            if json_type(value) != YYJSON_TYPE_BOOL {
                return type_error(value, "bool");
            }

            result.* = json_subtype(value) == YYJSON_SUBTYPE_TRUE;
            return true;
        } else #if TYPE_TAG == .INTEGER {
            ok, number := json_integer(value, T);
            if !ok {
                return false;
            }

            result.* = number;
            return true;
        } else #if TYPE_TAG == .FLOAT {
            if json_type(value) != YYJSON_TYPE_NUM {
                return type_error(value, "number");
            }

            result.* = cast(T) json_number(value);
            return true;
        } else #if TYPE_TAG == .ENUM {
            return json_parse_enum(value, result);
        } else #if TYPE_TAG == .STRING {
            if json_type(value) != YYJSON_TYPE_STR {
                return type_error(value, "string");
            }

            result.* = copy_string(json_string_view(value));
            return true;
        } else #if TYPE_TAG == .POINTER {
            Pointed :: type_of(result.*.*);

            pointed := New(Pointed);
            if !json_parse_value(value, pointed) {
                return false;
            }

            result.* = pointed;
            return true;
        } else #if TYPE_TAG == .ARRAY {
            return json_parse_array(value, result);
        } else #if TYPE_TAG == .STRUCT {
            if json_type(value) != YYJSON_TYPE_OBJ {
                return type_error(value, "object");
            }

            return json_parse_object(value, result);
        } else {
            #assert false "yyjson wrapper: unsupported type for json_parse.";
            return false;
        }
    }
}

#scope_file

json_parse_array :: (value: *yyjson_val, result: *$T) -> bool {
    if json_type(value) != YYJSON_TYPE_ARR {
        return type_error(value, "array");
    }

    Element :: type_of(result.*[0]);
    ARRAY_KIND :: #run (cast(*Type_Info_Array) T).array_type;
    FIXED_COUNT :: #run (cast(*Type_Info_Array) T).array_count;

    count := json_length(value);

    #if ARRAY_KIND == .FIXED {
        if count != FIXED_COUNT {
            log_error("Expected an array of % elements, got %.", FIXED_COUNT, count);
            return false;
        }
    } else #if ARRAY_KIND == .VIEW {
        result.* = NewArray(count, Element, initialized=true);
    } else {
        array_resize(result, count, initialize=true);
    }

    element := json_first_child(value);

    for index: 0..count-1 {
        if !json_parse_value(element, *(result.*)[index]) {
            return false;
        }

        element = json_next(element);
    }

    return true;
}

json_parse_enum :: (value: *yyjson_val, result: *$T) -> bool {
    if json_type(value) == YYJSON_TYPE_STR {
        name := json_string_view(value);
        names := enum_names(T);
        values := enum_values_as_s64(T);

        for names {
            if it == name {
                result.* = cast(T) values[it_index];
                return true;
            }
        }

        log_error("'%' is not a member of enum %.", name, T);
        return false;
    }

    Internal :: #run enum_internal_type(T);

    ok, number := json_integer(value, Internal);
    if !ok {
        return false;
    }

    result.* = cast,no_check(T) number;
    return true;
}

json_parse_object :: (value: *yyjson_val, result: *$T) -> bool {
    #insert #run generate_object_parser(T);
    return true;
}

generate_object_parser :: ($T: Type) -> string {
    builder: String_Builder;
    info := cast(*Type_Info_Struct) T;

    for member: info.members {
        if !is_serialized(*member) || !(member.flags & .USING) {
            continue;
        }

        print_to_builder(*builder, #string DONE
            if !json_parse_object(value, *result.%) return false;
        DONE, member.name);
    }

    cases: String_Builder;
    for member: info.members {
        if !is_serialized(*member) || member.flags & .USING {
            continue;
        }

        names: [..]string;
        array_add(*names, json_member_name(*member));

        for note: member.notes {
            if begins_with(note, "json_alias(") && ends_with(note, ")") {
                array_add(*names, slice(note, "json_alias(".count, note.count - "json_alias()".count));
            }
        }

        for name: names {
            print_to_builder(*cases, #string DONE
                case "%1"; if !json_parse_value(member_value, *result.%2) { log_error("... in member '%1'."); return false; }
            DONE, name, member.name);
        }
    }

    cases_text := builder_to_string(*cases);
    if cases_text.count == 0 {
        return builder_to_string(*builder);
    }

    append(*builder, #string DONE
        key := json_first_child(value);
        for 1..json_length(value) {
            member_value := json_next(key);
            if json_string_view(key) == {
    DONE);

    append(*builder, cases_text);

    append(*builder, #string DONE
            }
            key = json_next(member_value);
        }
    DONE);

    return builder_to_string(*builder);
}

json_integer :: (value: *yyjson_val, $T: Type) -> bool, T {
    result: T;
    if json_type(value) != YYJSON_TYPE_NUM {
        return type_error(value, "integer"), result;
    }

    number: s64;
    subtype := json_subtype(value);

    if subtype == YYJSON_SUBTYPE_REAL {
        real := value.uni.f64;

        if real < cast(float64) JSON_S64_MIN || real > cast(float64) JSON_S64_MAX || real != cast(float64) cast(s64) real {
            return type_error(value, "integer"), result;
        }

        number = cast(s64) real;
    } else if subtype == YYJSON_SUBTYPE_UINT {
        unsigned := value.uni._u64;

        if unsigned > cast(u64) JSON_S64_MAX {
            #if T == u64 {
                return true, unsigned;
            }

            log_error("Integer % is out of range.", unsigned);

            return false, result;
        }

        number = cast(s64) unsigned;
    } else {
        number = value.uni.i64;
    }

    ok: bool;
    ok, result = json_store_integer(number, T);

    return ok, result;
}

json_store_integer :: (number: s64, $T: Type) -> bool, T {
    result: T;

    info := cast(*Type_Info_Integer) T;
    low, high := integer_range(info);

    if number < low || (high >= 0 && number > high) {
        log_error("Integer % is out of range of %.", number, T);
        return false, result;
    }

    return true, cast,no_check(T) number;
}

integer_range :: (info: *Type_Info_Integer) -> low: s64, high: s64 {
    bits := info.runtime_size * 8;
    if info.signed {
        if bits == 64 {
            return JSON_S64_MIN, JSON_S64_MAX;
        }
        return -(cast(s64) 1 << (bits - 1)), (cast(s64) 1 << (bits - 1)) - 1;
    }

    if bits == 64 {
        return 0, -1;
    }

    return 0, (cast(s64) 1 << bits) - 1;
}

type_error :: (value: *yyjson_val, expected: string) -> bool {
    log_error("Expected % but got %.", expected, json_type_name(value));
    return false;
}

#scope_export

JSON_WRITE_FLAGS :: YYJSON_WRITE_INF_AND_NAN_AS_NULL;

json_write :: (value: $T, pretty := false) -> bool, string {
    allocator := context_yyjson_allocator(*context);
    document := yyjson_mut_doc_new(*allocator);
    defer yyjson_mut_doc_free(document);

    root := json_value_to_mutable(document, *value);

    flags := JSON_WRITE_FLAGS;
    if pretty {
        flags |= YYJSON_WRITE_PRETTY_TWO_SPACES;
    }

    length: u64;
    error: yyjson_write_err;
    text := yyjson_mut_val_write_opts(root, flags, *allocator, *length, *error);

    if !text && error.code == YYJSON_WRITE_ERROR_INVALID_STRING {
        text = yyjson_mut_val_write_opts(root, flags | YYJSON_WRITE_ALLOW_INVALID_UNICODE | YYJSON_WRITE_ESCAPE_UNICODE, *allocator, *length, *error);
    }

    if !text {
        log_error("Failed to write JSON: %", to_string(error.msg));
        return false, "null";
    }

    defer free(text);

    return true, copy_string(to_string(text, cast(s64) length));
}

json_value_to_mutable :: (document: *yyjson_mut_doc, value: *$T) -> *yyjson_mut_val {
    #if T == *void {
        return yyjson_mut_null(document);
    } else #if T == Raw_JSON_Value {

        if value.json.count == 0 {
            return yyjson_mut_null(document);
        }

        return yyjson_mut_rawn(document, value.json.data, cast(u64) value.json.count);
    } else #if #run is_string_table(T) {
        object := yyjson_mut_obj(document);

        for * value.* {
            key_data := ifx it_index.count then it_index.data else EMPTY_STRING.data;
            key := yyjson_mut_strn(document, key_data, cast(u64) it_index.count);
            yyjson_mut_obj_add(object, key, json_value_to_mutable(document, it));
        }

        return object;
    } else {
        TYPE_TAG :: #run (cast(*Type_Info) T).type;

        #if TYPE_TAG == .BOOL {
            return yyjson_mut_bool(document, value.*);
        } else #if TYPE_TAG == .INTEGER {
            #if #run (cast(*Type_Info_Integer) T).signed {
                return yyjson_mut_sint(document, cast(s64) value.*);
            } else {
                return yyjson_mut_uint(document, cast(u64) value.*);
            }
        } else #if TYPE_TAG == .FLOAT {
            return yyjson_mut_real(document, cast(float64) value.*);
        } else #if TYPE_TAG == .ENUM {
            Internal :: #run enum_internal_type(T);
            internal := cast,no_check(Internal) value.*;
            return json_value_to_mutable(document, *internal);
        } else #if TYPE_TAG == .STRING {
            if value.count == 0 {
                return yyjson_mut_strn(document, EMPTY_STRING.data, 0);
            }

            return yyjson_mut_strn(document, value.data, cast(u64) value.count);
        } else #if TYPE_TAG == .POINTER {
            if !value.* {
                return yyjson_mut_null(document);
            }

            return json_value_to_mutable(document, value.*);
        } else #if TYPE_TAG == .ARRAY {
            array := yyjson_mut_arr(document);

            for * value.* {
                yyjson_mut_arr_append(array, json_value_to_mutable(document, it));
            }

            return array;
        } else #if TYPE_TAG == .STRUCT {
            object := yyjson_mut_obj(document);
            json_add_members(document, object, value);

            return object;
        } else {
            #assert false "yyjson wrapper: unsupported type for json_write.";
            return null;
        }
    }
}

#scope_file

json_add_members :: (document: *yyjson_mut_doc, object: *yyjson_mut_val, value: *$T) {
    #insert #run generate_object_writer(T);
}

generate_object_writer :: ($T: Type) -> string {
    builder: String_Builder;
    info := cast(*Type_Info_Struct) T;

    for member: info.members {
        if !is_serialized(*member) {
            continue;
        }

        if member.flags & .USING {
            print_to_builder(*builder, "json_add_members(document, object, *value.%);\n", member.name);
            continue;
        }

        name := json_member_name(*member);
        if has_note(*member, "json_optional") {
            print_to_builder(*builder, "if !json_is_empty(*value.%) ", member.name);
        }

        print_to_builder(*builder, #string DONE
        	yyjson_mut_obj_add(object, yyjson_mut_strn(document, "%1".data, "%1".count), json_value_to_mutable(document, *value.%2));
        DONE, name, member.name);
    }

    return builder_to_string(*builder);
}

json_is_empty :: (value: *$T) -> bool {
    #if T == Raw_JSON_Value {
        return json_raw_is_null(value.*);
    } else #if #run is_string_table(T) {
        return value.count == 0;
    } else {
        TYPE_TAG :: #run (cast(*Type_Info) T).type;

        #if TYPE_TAG == .STRING {
            return value.count == 0;
        } else #if TYPE_TAG == .ARRAY && (#run (cast(*Type_Info_Array) T).array_type != .FIXED) {
            return value.count == 0;
        } else {
            bytes := cast(*u8) value;
            for 0..size_of(T)-1 {
                if bytes[it] != 0 {
                    return false;
                }
            }
            return true;
        }
    }
}

EMPTY_STRING :: "\0";

is_serialized :: (member: *Type_Info_Struct_Member) -> bool {
    if member.flags & .CONSTANT {
        return false;
    }

    if has_note(member, "json_ignore") {
        return false;
    }

    return true;
}

has_note :: (member: *Type_Info_Struct_Member, note: string) -> bool {
    for member.notes {
        if it == note {
            return true;
        }
    }
    return false;
}

json_member_name :: (member: *Type_Info_Struct_Member) -> string {
    for note: member.notes {
        if begins_with(note, "json(") && ends_with(note, ")") && note.count > "json()".count {
            return slice(note, "json(".count, note.count - "json()".count);
        }
    }

    return member.name;
}

is_string_table :: (T: Type) -> bool {
    info := cast(*Type_Info) T;
    if info.type != .STRUCT {
        return false;
    }

    struct_info := cast(*Type_Info_Struct) info;
    if struct_info.name != "Table" {
        return false;
    }

    for struct_info.members {
        if it.name == "entries" && it.type.type == .ARRAY {
            entry := cast(*Type_Info_Struct) (cast(*Type_Info_Array) it.type).element_type;
            for entry.members {
                if it.name == "key" {
                    return it.type.type == .STRING;
                }
            }
        }
    }

    return false;
}

enum_internal_type :: (T: Type) -> Type {
    internal := (cast(*Type_Info_Enum) T).internal_type;
    if internal == type_info(u8) {
        return u8;
    }
    if internal == type_info(u16) {
        return u16;
    }
    if internal == type_info(u32) {
        return u32;
    }
    if internal == type_info(u64) {
        return u64;
    }
    if internal == type_info(s8) {
        return s8;
    }
    if internal == type_info(s16) {
        return s16;
    }
    if internal == type_info(s32) {
        return s32;
    }
    return s64;
}

JSON_S64_MAX :: 0x7fff_ffff_ffff_ffff;
JSON_S64_MIN :: -JSON_S64_MAX - 1;

#scope_export

JSON_Document :: struct {
    document: *yyjson_doc;
    root: *yyjson_val;
}

json_parse_document :: (text: string) -> ok: bool, JSON_Document {
    result: JSON_Document;
    if text.count == 0 {
        return false, result;
    }

    error: yyjson_read_err;
    result.document = yyjson_read_opts(text.data, cast(u64) text.count, JSON_READ_FLAGS, context_yyjson_allocator(*context), *error);
    if !result.document {
        log_error("Invalid JSON at byte %: %", error.pos, to_string(error.msg));
        return false, result;
    }

    result.root = yyjson_doc_get_root(result.document);

    return true, result;
}

json_free :: (document: JSON_Document) {
    if !document.document {
        return;
    }

    yyjson_doc_free(document.document);
}

json_get :: (value: *yyjson_val, keys: ..string) -> *yyjson_val {
    current := value;

    for key: keys {
        if !current || json_type(current) != YYJSON_TYPE_OBJ {
            return null;
        }

        found: *yyjson_val;
        member_key := json_first_child(current);

        for 1..json_length(current) {
            member_value := json_next(member_key);

            if json_string_view(member_key) == key {
                found = member_value;
                break;
            }

            member_key = json_next(member_value);
        }

        current = found;
    }

    return current;
}

json_string :: (value: *yyjson_val, default := "") -> string {
    if !value || json_type(value) != YYJSON_TYPE_STR {
        return default;
    }

    return json_string_view(value);
}

json_int :: (value: *yyjson_val, default: s64 = 0) -> s64 {
    if !value || json_type(value) != YYJSON_TYPE_NUM {
        return default;
    }

    ok, number := json_integer(value, s64);
    if !ok {
        return default;
    }

    return number;
}

json_bool :: (value: *yyjson_val, default := false) -> bool {
    if !value || json_type(value) != YYJSON_TYPE_BOOL {
        return default;
    }

    return json_subtype(value) == YYJSON_SUBTYPE_TRUE;
}

json_is_null :: (value: *yyjson_val) -> bool {
    return !value || json_type(value) == YYJSON_TYPE_NULL;
}

json_is_array :: (value: *yyjson_val) -> bool {
    return value && json_type(value) == YYJSON_TYPE_ARR;
}

json_is_object :: (value: *yyjson_val) -> bool {
    return value && json_type(value) == YYJSON_TYPE_OBJ;
}

json_array_items :: (value: *yyjson_val) -> [..]*yyjson_val {
    items: [..]*yyjson_val;

    if !json_is_array(value) {
        return items;
    }

    array_reserve(*items, json_length(value));
    item := json_first_child(value);

    for 1..json_length(value) {
        array_add(*items, item);
        item = json_next(item);
    }

    return items;
}

json_object_values :: (value: *yyjson_val) -> [..]*yyjson_val {
    values: [..]*yyjson_val;
    if !json_is_object(value) {
        return values;
    }

    key := json_first_child(value);
    for 1..json_length(value) {
        array_add(*values, json_next(key));
        key = json_next(json_next(key));
    }

    return values;
}

json_value_text :: (value: *yyjson_val) -> string {
    if !value {
        return "null";
    }

    length: u64;
    allocator := context_yyjson_allocator(*context);

    text := yyjson_val_write_opts(value, YYJSON_WRITE_NOFLAG, *allocator, *length, null);
    if !text {
        return "null";
    }

    defer free(text);

    return copy_string(to_string(text, cast(s64) length));
}

json_type_name :: (value: *yyjson_val) -> string {
    if !value {
        return "nothing";
    }

    if json_type(value) == {
        case YYJSON_TYPE_NULL; return "null";
        case YYJSON_TYPE_BOOL; return "bool";
        case YYJSON_TYPE_NUM;  return "number";
        case YYJSON_TYPE_STR;  return "string";
        case YYJSON_TYPE_ARR;  return "array";
        case YYJSON_TYPE_OBJ;  return "object";
        case YYJSON_TYPE_RAW;  return "raw";
    }

    return "unknown";
}

json_type :: inline (value: *yyjson_val) -> yyjson_type {
    return cast(yyjson_type) (value.tag & YYJSON_TYPE_MASK);
}

json_subtype :: inline (value: *yyjson_val) -> u8 {
    return cast(u8) (value.tag & YYJSON_SUBTYPE_MASK);
}

json_length :: inline (value: *yyjson_val) -> s64 {
    return cast(s64) (value.tag >> YYJSON_TAG_BIT);
}

json_string_view :: inline (value: *yyjson_val) -> string {
    return to_string(value.uni.str, json_length(value));
}

json_number :: inline (value: *yyjson_val) -> float64 {
    subtype := json_subtype(value);

    if subtype == YYJSON_SUBTYPE_REAL {
        return value.uni.f64;
    }

    if subtype == YYJSON_SUBTYPE_SINT {
        return cast(float64) value.uni.i64;
    }

    return cast(float64) value.uni._u64;
}

json_first_child :: inline (container: *yyjson_val) -> *yyjson_val {
    return cast(*yyjson_val) (cast(*u8) container + size_of(yyjson_val));
}

json_next :: inline (value: *yyjson_val) -> *yyjson_val {
    CONTAINER_MASK :: YYJSON_TYPE_ARR & YYJSON_TYPE_OBJ;

    is_container := (value.tag & CONTAINER_MASK) == CONTAINER_MASK;
    offset := ifx is_container then cast(s64) value.uni._u64 else size_of(yyjson_val);

    return cast(*yyjson_val) (cast(*u8) value + offset);
}

#scope_file

context_yyjson_allocator :: (caller: *#Context) -> yyjson_alc {
    allocator: yyjson_alc;

    allocator.ctx = caller;

    allocator.malloc = (ctx: *void, size: u64) -> *void #c_call {
        push_context (cast(*#Context) ctx).* {
            return alloc(cast(s64) size,, context.default_allocator);
        }
    };

    allocator.realloc = (ctx: *void, pointer: *void, old_size: u64, size: u64) -> *void #c_call {
        push_context (cast(*#Context) ctx).* {
            return realloc(pointer, cast(s64) size, cast(s64) old_size,, context.default_allocator);
        }
    };

    allocator.free = (ctx: *void, pointer: *void) #c_call {
        push_context (cast(*#Context) ctx).* {
            free(pointer,, context.default_allocator);
        }
    };

    return allocator;
}

#import "Basic";
#import "String";
#import "Hash_Table";
#import "Reflection";
