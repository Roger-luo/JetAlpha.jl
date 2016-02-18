
# basic
@test slack_bot("hi") == nothing
@test slack_bot("hi, jet") == nothing
@test contains(slack_bot("jet, hi"), "https://github.com/KDr2/JetAlpha.jl")

# cmd calc
@test slack_bot("jet calc 1+2+3") == "1 + 2 + 3 = 6"

# cmd doc
@test slack_bot("jet, doc Main.Base.exit1") == "No object is named `Main.Base.exit1`."
@test contains(slack_bot("jet, doc Main.Base.exit"), "The default exit code is zero")
@test contains(slack_bot("jet, doc Main.Base.@printf"), "`printf()`")
