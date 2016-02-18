
@test slack_bot("hi") == ""
@test slack_bot("hi, jet") == ""
@test contains(slack_bot("jet, hi"), "https://github.com/KDr2/JetAlpha.jl")
@test slack_bot("jet calc 1+2+3") == "1 + 2 + 3 = 6"
