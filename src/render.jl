
const project_root = dirname(dirname(@__FILE__))

function datafile(relative_path)
    joinpath(project_root, "data", relative_path)
end

function static(filename, content_type="text/html")
    headers = HttpCommon.headers()
    headers["Content-Type"] = content_type

    open(datafile(filename)) do file
        #respond(readstring(file))
        content = readstring(file)
        req -> Dict(:headers => headers,
                    :body => content)
    end
end

function static_reloadable(filename, content_type="text/html")
    headers = HttpCommon.headers()
    headers["Content-Type"] = content_type

    req -> open(datafile(filename)) do file
        Dict(:headers => headers,
             :body => readstring(file))
    end
end



macro static(filename)
    open(datafile(filename)) do file
        content = readstring(file)
        :(respond($content))
    end
end

function render(file, data...)
end
