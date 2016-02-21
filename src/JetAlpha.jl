module JetAlpha

using Compat
using HttpCommon
using JSON
using Mux
using URIParser

export start_server, slack_bot

include("render.jl")
include("slack_bot.jl")

@app main = (Mux.defaults,
             page(static_file_reloadable("templates/index.html")),
             #page("/static/styles/style.css", static_file_reloadable("static/styles/style.css")),
             #page("/static/styles/foundation.css", static_file_reloadable("static/styles/foundation.css")),
             static("/static", "/static"),
             slack_bot_page,
             Mux.notfound())

function start_server(;wait=true)
    serve(main)
    if wait
        readlines(STDIN)
    end
end

end
