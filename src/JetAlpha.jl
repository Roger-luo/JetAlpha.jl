module JetAlpha

using Mux
using JSON
using HttpCommon

export start_server

function slack_bot(req)
    #print(req)
    data = Dict(:text => "Hi, I'm JetAlpha Bot",
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

@app main = (Mux.defaults,
             page(respond("<h1>Welcome to JetAlpha!</h1>")),
             slack_bot_page,
             Mux.notfound())

function start_server(;wait=true)
    serve(main)
    if wait
        readlines(STDIN)
    end
end

end
