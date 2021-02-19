require "../src/retour"

module Foo
  extend self

  def foo(x = "")
    "foo(#{x})"
  end

  def bar(id)
    "bar(#{id})"
  end

  Retour.routes({
    %q(/foo)             => :foo,
    %q(/foo/{x})         => :foo,
    %q(/bar/{id:[0-9]+}) => :bar,
  }, default: "[^/]+")
end

p!(
  Foo.call("/foo"),
  Foo.call("/foo/testing"),
  Foo.call("/bar/5"),
)

p!(
  Foo.gen_foo,
  Foo.gen_foo("testing"),
  Foo.gen_bar(id: 5),
)
