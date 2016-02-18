module JetAlpha

using Mux
using JSON
using HttpCommon
using URIParser

export start_server, slack_bot

include("slack_bot.jl")

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
