App = Struct.new(:left, :right) do
  def to_s
    "(#{left} #{right})"
  end
end

Abs = Struct.new(:param, :body) do
  def to_s
    "(λ#{param}. #{body})"
  end
end

Var = Struct.new(:name) do
  def to_s
    name
  end
end

module Lambda
  extend self

  def eval(term)
    case term
    when App
      if term.left.is_a?(Abs) && term.right.is_a?(Abs)
        replace(param: term.left.param, with: term.right, in: term.left.body)
      end
    end
  end

  def replace(opts)
    param = opts.fetch(:param)
    with = opts.fetch(:with)
    body = opts.fetch(:in)

    case body
    when Var
      if body.name == param
        with
      else
        body
      end
    end
  end
end

# λx. x
id = Abs.new("x", Var.new("x"))

# id id
id_app = App.new(id, id)
Lambda.eval(id_app)

raise unless Lambda.replace(param: "x", with: Var.new("y"), in: Var.new("x")) == Var.new("y")
raise unless Lambda.replace(param: "x", with: Var.new("y"), in: Var.new("z")) == Var.new("z")