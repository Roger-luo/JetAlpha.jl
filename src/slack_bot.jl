
function slack_bot(req::Dict)
    #print(req)
    request_data = parsequerystring(bytestring(req[:data]))
    response_text = slack_message_router(request_data)
    response_text == nothing && return Dict(:status => 204)

    data = Dict(:text => response_text,
                :username => "JetAlpha",
                :icon_url => "http://res.cloudinary.com/kdr2/image/upload/v1455802308/misc/jetalpha-logo-v1.png",)
    text = JSON.json(data)
    headers = HttpCommon.headers()
    headers["Content-Type"] = "application/json"

    #Response(text, headers)

    Dict(:headers => headers,
         :body => text)
end

function slack_bot(text::AbstractString, user=nothing)
    text = URIParser.escape(text)
    user = URIParser.escape(user == nothing ? "Tester" : user)
    data = "text=$text&user_name=$user".data
    #fake_req = Request("POST", "/bot/slack", Dict(), data)
    fake_req = Dict(:data => data)
    response = slack_bot(fake_req)
    rdata = JSON.Parser.parse(get(response, :body, "{}"))
    return get(rdata, "text", nothing)
end

slack_bot_page = page("/bot/slack",
                      method("GET", respond("JetAlpha BOT")),
                      method("POST", slack_bot),
                      Mux.notfound())

function slack_message_router(msg)
    request_text = get(msg, "text", "")
    request_user = get(msg, "user_name", "")

    rmatch = match(r"^jet\b\W*([\D\d]+)$"im, request_text)
    rmatch == nothing && return
    cmd = rmatch[1]

    if ismatch(r"^calc\b"i, cmd)
        return slack_bot_cmd_calc(cmd)
    elseif ismatch(r"^doc\b"i, cmd)
        return slack_bot_cmd_doc(cmd)
    end

    return "Hi @$request_user, I got your cmd: [ $cmd ], " *
    "But I'm sorry that I don't know how to execute it yet. " *
    "Please teach me by contributing to https://github.com/KDr2/JetAlpha.jl if you can."
end


function slack_bot_cmd_calc(cmd)
    rmatch = match(r"^calc\b([\^\(\)\d\s+\-*/.]+)$"im, cmd)
    rmatch == nothing && return "Bad expression"
    expr_str = rmatch[1]
    try
        expr = parse(expr_str)
        return string(expr) * " = " * string(eval(expr))
    catch
        return "Bad expression"
    end
end

function slack_bot_cmd_doc(cmd)
    rmatch = match(r"^doc\s+([\w@][_\d\w]*(\.[\w@][_\d\w]*)*)\b"i, cmd)
    rmatch == nothing && return "Bad object name."
    names = split(rmatch[1], ".")

    #keyword
    if length(names) == 1 && haskey(Docs.keywords, symbol(names[1]))
        doc_md = Docs.keywords[symbol(names[1])]
        @goto found
    end

    #obj
    target_obj = Main
    for name in names
        !isa(target_obj, Module) && @goto not_found
        sym = symbol(name)
        !isdefined(target_obj, sym) && @goto not_found
        if VERSION < v"0.5.0" && name[1] == '@'
            target_obj = Base.Docs.Binding(target_obj, sym)
        else
            target_obj = eval(target_obj, sym)
        end
    end
    doc_md = Docs.doc(target_obj)
    @label found
    buf = IOBuffer()
    writemime(buf, MIME{symbol("text/plain")}(), doc_md)
    doc = takebuf_string(buf)
    return "Document for `$(rmatch[1])`:\n$(doc)\n"
    @label not_found
    return "No object is named `$(rmatch[1])`."
end
