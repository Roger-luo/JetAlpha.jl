using JetAlpha
using Base.Test

# slack bot test
@test slack_bot("hi") == ""
@test slack_bot("hi, jet") == ""
@test contains(slack_bot("jet, hi"), "")
@test slack_bot("jet calc 1+2+3") == "1 + 2 + 3 = 6"
