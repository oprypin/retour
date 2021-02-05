require "../src/http"

module Foo
  extend self

  @[Retour::Get("/foo")]
  @[Retour::Get("/foo/{x}")]
  def foo(x = "")
    "foo(#{x})"
  end

  @[Retour::Get("/bar/{id:[0-9]+}")]
  def bar(id)
    "bar(#{id})"
  end

  include Retour::HTTPRouter
end

p!(
  Foo.call("GET", "/foo"),
  Foo.call("GET", "/foo/testing"),
  Foo.call("GET", "/bar/5"),
)

p!(
  Foo.gen_foo,
  Foo.gen_foo("testing"),
  Foo.gen_bar(id: 5),
)
