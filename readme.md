# Jai YYJSON bindings and wrapper

Repository contains generated bindings for [yyjson](https://github.com/ibireme/yyjson) and Jai wrapper to make working with the language easy.

## Reading JSON
```jai
ok, value := json_parse(json_str, Type);
```

## Writing JSON
```jai
ok, json_str := json_write(value);
```

## Member notes
- `@json(name)` = member is called `name` in JSON.
- `@json_alias(n)` = reading accepts also the name `n`.
- `@json_ignore` = member is ignored.
- `@json_optional` = member is not written if empty.
