require_relative './lambda'

# λx. x
ID = Abs("x", Var("x"))

TRU = Abs("t", Abs("f", Var("t")))
FLS = Abs("t", Abs("f", Var("f")))
TEST = Abs("l", Abs("m", Abs("n", App(App(Var("l"), Var("m")), Var("n")))))

puts Lambda.eval_full App(App(App(TEST, TRU), Abs("v", Var("v"))), Abs("w", Var("w")))
