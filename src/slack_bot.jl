
function slack_bot(req)
    #print(req)
    request_data = parsequerystring(bytestring(req[:data]))
    response_text = slack_message_router(request_data)
    response_text == nothing && return Dict(:status => 204)

    data = Dict(:text => response_text,
                :username => "JetAlpha",
                :icon_url => "http://res.cloudinary.com/kdr2/image/upload/c_crop,g_center,h_250,w_250,x_0,y_10/v1454772214/misc/c3p0-001.jpg",)
    text = JSON.json(data)
    headers = HttpCommon.headers()
    headers["Content-Type"] = "application/json"

    #Response(text, headers)

    Dict(:headers => headers,
         :body => text)
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
    end

    return "Hi @$request_user, I got your cmd: [ $cmd ], " *
    "But I'm sorry that I don't know how to execute it yet. " *
    "Please teach me by contributing to https://github.com/KDr2/JetAlpha.jl if you can."
end


function slack_bot_cmd_calc(cmd)
    rmatch = match(r"^calc\b([\d\s+\-*/.]+)$"im, cmd)
    rmatch == nothing && return "Bad expression"
    expr_str = rmatch[1]
    println(expr_str)
    try
        expr = parse(expr_str)
        return string(expr) * " = " * string(eval(expr))
    catch
        return "Bad expression"
    end
end
