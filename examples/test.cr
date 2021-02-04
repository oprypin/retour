require "../src/retour"

module Foo
  extend self

  def foo(x = "")
    "foo(#{x})"
  end

  def bar(id)
    "bar(#{id})"
  end

  retour({
    %q(/foo)             => foo,
    %q(/foo/{x})         => foo,
    %q(/bar/{id:[0-9]+}) => bar,
  }, default: "[^/]+")
end

p!(
  Foo.call("/foo"),
  Foo.call("/foo/testing"),
  Foo.call("/bar/5"),
  Foo.call("/bar/wrong"),
)
