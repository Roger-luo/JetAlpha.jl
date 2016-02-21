
const project_root = dirname(dirname(@__FILE__))

include("mime.jl")

function datafile(relative_path)
    joinpath(project_root, "data", relative_path)
end

function static(prefix, dirname)
    headers = HttpCommon.headers()
    not_found = Dict(:status => 404, :body => "File Not Found.")
    dirname = dirname[1] == '/' ? dirname[2:end] : dirname
    handler = req -> begin
        filename = joinpath(dirname, joinpath(req[:path]...))
        filepath = datafile(filename)
        if !isfile(filepath)
            return not_found
        end
        headers["Content-Type"] = mime_type(filename)
        open(filepath) do file
            Dict(:headers => headers,
                 :body => @compat readstring(file))
        end
    end
    route(prefix, handler)
end


function static_file(filename)
    headers = HttpCommon.headers()
    headers["Content-Type"] = mime_type(filename)

    open(datafile(filename)) do file
        #respond(readstring(file))
        content = @compat readstring(file)
        req -> Dict(:headers => headers,
                    :body => content)
    end
end

function static_file_reloadable(filename)
    headers = HttpCommon.headers()
    headers["Content-Type"] = mime_type(filename)

    req -> open(datafile(filename)) do file
        Dict(:headers => headers,
             :body => @compat readstring(file))
    end
end

function render(file, data...)
end
