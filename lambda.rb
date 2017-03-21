require 'rspec/expectations'
include RSpec::Matchers

App = Struct.new(:left, :right) do
  def to_s
    "(#{left} #{right})"
  end

  def inspect
    to_s
  end
end

Abs = Struct.new(:param, :body) do
  def to_s
    "(λ#{param}. #{body})"
  end

  def inspect
    to_s
  end
end

Var = Struct.new(:name) do
  def to_s
    name
  end

  def inspect
    to_s
  end
end

module Lambda
  extend self

  def eval(term)
    case term
    when App
      if term.left.is_a?(Abs) && term.right.is_a?(Abs) # E-AppAbs
        replace(param: term.left.param, with: term.right, in: term.left.body)
      elsif term.left.is_a?(Abs) # E-App2
        App.new(term.left, eval(term.right))
      else # E-App1
        App.new(eval(term.left), term.right)
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
    when Var
      if term.name == param
        with
      else
        term
      end
    when Abs
      if term.param == param
        term
      else
        Abs.new(term.param, replace(param: param, with: with, in: term.body))
      end
    when App
      App.new(
        replace(param: param, with: with, in: term.left),
        replace(param: param, with: with, in: term.right),
      )
    end
  end
end

# λx. x
id = Abs.new("x", Var.new("x"))

# id id
id_app = App.new(id, id)
Lambda.eval(id_app)

expect(Lambda.replace(param: "x", with: Var.new("y"), in: Var.new("x"))).to eq(Var.new("y"))
expect(Lambda.replace(param: "x", with: Var.new("y"), in: Var.new("z"))).to eq(Var.new("z"))

# id (id (λz. id z)) -> id (λz. id z)
expect(
  Lambda.eval(App.new(id, App.new(id, Abs.new("z", App.new(id, Var.new("z")))))
)).to eq(
  App.new(id, Abs.new("z", App.new(id, Var.new("z"))))
)

expect(
  Lambda.eval(App.new(id, Abs.new("z", App.new(id, Var.new("z")))))
).to eq(
  Abs.new("z", App.new(id, Var.new("z")))
)

expect(
  Lambda.eval(App.new(App.new(id, id), Abs.new("z", Var.new("z"))))
).to eq(
  App.new(id, Abs.new("z", Var.new("z")))
)

expect(
  Lambda.eval(
    App.new(
      Abs.new("x", Abs.new("y", App.new(Var.new("x"), Var.new("y")))),
      Abs.new("z", Var.new("z"))
    )
  )
).to eq(
  Abs.new("y", App.new(Abs.new("z", Var.new("z")), Var.new("y")))
)

expect(
  Lambda.eval(
    App.new(
      Abs.new("x", Abs.new("x", Var.new("x"))),
      Abs.new("z", Var.new("z"))
    )
  )
).to eq(
  Abs.new("x", Var.new("x"))
)
