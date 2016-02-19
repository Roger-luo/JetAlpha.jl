module JetAlpha

using Mux
using JSON
using HttpCommon
using URIParser

export start_server, slack_bot

include("render.jl")
include("slack_bot.jl")

@app main = (Mux.defaults,
             page(static_reloadable("templates/index.html")),
             page("/static/styles/style.css", static_reloadable("static/styles/style.css", "text/css")),
             page("/static/styles/foundation.css", static_reloadable("static/styles/foundation.css", "text/css")),
             slack_bot_page,
             Mux.notfound())

function start_server(;wait=true)
    serve(main)
    if wait
        readlines(STDIN)
    end
end

end
