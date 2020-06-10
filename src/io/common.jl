"""
    parse_json(path)

Parses a JavaScript Object Notation (JSON) file from the file path `path` and
returns a dictionary.
"""
function parse_json(path::String)
    dict = JSON.parsefile(path)
    dict["per_unit"] = false
    return dict
end
