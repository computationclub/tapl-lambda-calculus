require 'rspec/expectations'
include RSpec::Matchers

AppClass = Struct.new(:left, :right) do
  def to_s
    "(#{left} #{right})"
  end

  def inspect
    to_s
  end
end

AbsClass = Struct.new(:param, :body) do
  def to_s
    "(λ#{param}. #{body})"
  end

  def inspect
    to_s
  end
end

VarClass = Struct.new(:name) do
  def to_s
    name
  end

  def inspect
    to_s
  end
end

def App(left, right)
  AppClass.new(left, right)
end

def Abs(param, body)
  AbsClass.new(param, body)
end

def Var(name)
  VarClass.new(name)
end

module Lambda
  extend self

  def eval(term)
    case term
    when AppClass
      if term.left.is_a?(AbsClass) && term.right.is_a?(AbsClass) # E-AppAbs
        replace(param: term.left.param, with: term.right, in: term.left.body)
      elsif term.left.is_a?(AbsClass) # E-App2
        App(term.left, eval(term.right))
      else # E-App1
        App(eval(term.left), term.right)
      end
    else
      raise "can't eval"
    end
  end

  def replace(opts)
    param = opts.fetch(:param)
    with = opts.fetch(:with)
    term = opts.fetch(:in)

    case term
    when VarClass
      if term.name == param
        with
      else
        term
      end
    when AbsClass
      if term.param == param
        term
      else
        Abs(term.param, replace(param: param, with: with, in: term.body))
      end
    when AppClass
      App(
        replace(param: param, with: with, in: term.left),
        replace(param: param, with: with, in: term.right),
      )
    end
  end
end

# λx. x
id = Abs("x", Var("x"))

# id id
id_app = App(id, id)
Lambda.eval(id_app)

expect(Lambda.replace(param: "x", with: Var("y"), in: Var("x"))).to eq(Var("y"))
expect(Lambda.replace(param: "x", with: Var("y"), in: Var("z"))).to eq(Var("z"))

# id (id (λz. id z)) -> id (λz. id z)
expect(
  Lambda.eval(App(id, App(id, Abs("z", App(id, Var("z")))))
)).to eq(
  App(id, Abs("z", App(id, Var("z"))))
)

expect(
  Lambda.eval(App(id, Abs("z", App(id, Var("z")))))
).to eq(
  Abs("z", App(id, Var("z")))
)

expect(
  Lambda.eval(App(App(id, id), Abs("z", Var("z"))))
).to eq(
  App(id, Abs("z", Var("z")))
)

expect(
  Lambda.eval(
    App(
      Abs("x", Abs("y", App(Var("x"), Var("y")))),
      Abs("z", Var("z"))
    )
  )
).to eq(
  Abs("y", App(Abs("z", Var("z")), Var("y")))
)

expect(
  Lambda.eval(
    App(
      Abs("x", Abs("x", Var("x"))),
      Abs("z", Var("z"))
    )
  )
).to eq(
  Abs("x", Var("x"))
)
