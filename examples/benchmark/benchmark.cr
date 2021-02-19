# Based on https://github.com/amberframework/amber-router/blob/v0.4.4/examples/benchmark.cr
# Copyright (c) 2019 Robert L Carpenter

require "benchmark"
require "colorize"

require "radix"
require "amber_router"

require "../../src/http"

annotation Route
end

module RouteApp
  extend self

  @[Route("/get")]
  def root(p)
    "/get"
  end

  @[Route("/get/users/:id")]
  def users(p)
    "/get/users/<#{p["id"]}>"
  end

  @[Route("/get/users/:id/books")]
  def users_books(p)
    "/get/users/<#{p["id"]}>/books"
  end

  @[Route("/get/books/:id")]
  def books(p)
    "/get/books/<#{p["id"]}>"
  end

  @[Route("/get/books/:id/chapters")]
  def book_chapters(p)
    "/get/books/<#{p["id"]}>/chapters"
  end

  @[Route("/get/books/:id/authors")]
  def book_authors(p)
    "/get/books/<#{p["id"]}>/authors"
  end

  @[Route("/get/books/:id/pictures")]
  def book_pictures(p)
    "/get/books/<#{p["id"]}>/pictures"
  end

  @[Route("/get/a/b/c/d/e/f/g/h/i/j/k/l/m/n/o/p/q/r/s/t/u/v/w/x/y/z")]
  def alphabet(p)
    "/get/a/b/c/d/e/f/g/h/i/j/k/l/m/n/o/p/q/r/s/t/u/v/w/x/y/z"
  end

  @[Route("/get/var/:b/:c/:d/:e/:f/:g/:h/:i/:j/:k/:l/:m/:n/:o/:p/:q/:r/:s/:t/:u/:v/:w/:x/:y/:z")]
  def variable_alphabet(p)
    "/get/var/<#{p["b"]}>/<#{p["c"]}>/<#{p["d"]}>/<#{p["e"]}>/<#{p["f"]}>/<#{p["g"]}>/<#{p["h"]}>/<#{p["i"]}>/<#{p["j"]}>/<#{p["k"]}>/<#{p["l"]}>/<#{p["m"]}>/<#{p["n"]}>/<#{p["o"]}>/<#{p["p"]}>/<#{p["q"]}>/<#{p["r"]}>/<#{p["s"]}>/<#{p["t"]}>/<#{p["u"]}>/<#{p["v"]}>/<#{p["w"]}>/<#{p["x"]}>/<#{p["y"]}>/<#{p["z"]}>"
  end

  @[Route("/get/foobarbizfoobarbizfoobarbizfoobarbizfoobarbizbat/:id")]
  def foobar_bat(p)
    "/get/foobarbizfoobarbizfoobarbizfoobarbizfoobarbizbat/<#{p["id"]}>"
  end

  @[Route("/get/foobarbizfoobarbizfoobarbizfoobarbizfoobarbizbom/:id")]
  def foobar_bom(p)
    "/get/foobarbizfoobarbizfoobarbizfoobarbizfoobarbizbom/<#{p["id"]}>"
  end

  @[Route("/post/*rest")]
  def catchall(p)
    "/post/<#{p["rest"]}>"
  end

  @[Route("/put/products/*slug/dp/:id")]
  def amazon_style_url(p)
    "/put/products/<#{p["slug"]?}>/dp/<#{p["id"]?}>"
  end

  @[Route("/get/test/:id", constraints: {:id => /foo_[0-9]+/})]
  def requirement_path(p)
    "/get/test/<#{p["id"]}>"
  end

  def get(payload, params)
    {% begin %}
    case payload
      {% for method in RouteApp.methods %}
        {% for ann in method.annotations(Route) %}
          when {{method.name.symbolize}}
            {{method.name.id}}(params)
        {% end %}
      {% end %}
    end
    {% end %}
  end
end

amber_router = Amber::Router::RouteSet(Symbol).new
radix_router = Radix::Tree(Symbol).new

{% for method in RouteApp.methods %}
  {% for ann in method.annotations(Route) %}
    amber_router.add({{*ann.args}}, {{method.name.symbolize}}, {{**ann.named_args}})
    radix_router.add({{*ann.args}}, {{method.name.symbolize}})
  {% end %}
{% end %}

module RetourApp
  extend self
  include Retour::HTTPRouter

  @[Retour::Get("/get")]
  def root
    "/get"
  end

  @[Retour::Get("/get/users/{id}")]
  def users(id)
    "/get/users/<#{id}>"
  end

  @[Retour::Get("/get/users/{id}/books")]
  def users_books(id)
    "/get/users/<#{id}>/books"
  end

  @[Retour::Get("/get/books/{id}")]
  def books(id)
    "/get/books/<#{id}>"
  end

  @[Retour::Get("/get/books/{id}/chapters")]
  def book_chapters(id)
    "/get/books/<#{id}>/chapters"
  end

  @[Retour::Get("/get/books/{id}/authors")]
  def book_authors(id)
    "/get/books/<#{id}>/authors"
  end

  @[Retour::Get("/get/books/{id}/pictures")]
  def book_pictures(id)
    "/get/books/<#{id}>/pictures"
  end

  @[Retour::Get("/get/a/b/c/d/e/f/g/h/i/j/k/l/m/n/o/p/q/r/s/t/u/v/w/x/y/z")]
  def alphabet
    "/get/a/b/c/d/e/f/g/h/i/j/k/l/m/n/o/p/q/r/s/t/u/v/w/x/y/z"
  end

  @[Retour::Get("/get/var/{b}/{c}/{d}/{e}/{f}/{g}/{h}/{i}/{j}/{k}/{l}/{m}/{n}/{o}/{p}/{q}/{r}/{s}/{t}/{u}/{v}/{w}/{x}/{y}/{z}")]
  def variable_alphabet(b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r, s, t, u, v, w, x, y, z)
    "/get/var/<#{b}>/<#{c}>/<#{d}>/<#{e}>/<#{f}>/<#{g}>/<#{h}>/<#{i}>/<#{j}>/<#{k}>/<#{l}>/<#{m}>/<#{n}>/<#{o}>/<#{p}>/<#{q}>/<#{r}>/<#{s}>/<#{t}>/<#{u}>/<#{v}>/<#{w}>/<#{x}>/<#{y}>/<#{z}>"
  end

  @[Retour::Get("/get/foobarbizfoobarbizfoobarbizfoobarbizfoobarbizbat/{id}")]
  def foobar_bat(id)
    "/get/foobarbizfoobarbizfoobarbizfoobarbizfoobarbizbat/<#{id}>"
  end

  @[Retour::Get("/get/foobarbizfoobarbizfoobarbizfoobarbizfoobarbizbom/{id}")]
  def foobar_bom(id)
    "/get/foobarbizfoobarbizfoobarbizfoobarbizfoobarbizbom/<#{id}>"
  end

  @[Retour::Get("/post/{rest:.*}")]
  def catchall(rest)
    "/post/<#{rest}>"
  end

  @[Retour::Get("/put/products/{slug:.*}/dp/{id}")]
  def amazon_style_url(slug, id)
    "/put/products/<#{slug}>/dp/<#{id}>"
  end

  @[Retour::Get("/get/test/{id:foo_[0-9]+}")]
  def requirement_path(id)
    "/get/test/<#{id}>"
  end
end

{
  {"root", "/get", "/get"},
  {"deep", "/get/books/23/chapters", "/get/books/<23>/chapters"},
  {"wrong", "/get/books/23/pages", nil},
  {"many segments", "/get/a/b/c/d/e/f/g/h/i/j/k/l/m/n/o/p/q/r/s/t/u/v/w/x/y/z", "/get/a/b/c/d/e/f/g/h/i/j/k/l/m/n/o/p/q/r/s/t/u/v/w/x/y/z"},
  {"many variables", "/get/var/2/3/4/5/6/7/8/9/0/1/2/3/4/5/6/7/8/9/0/1/2/3/4/5/6", "/get/var/<2>/<3>/<4>/<5>/<6>/<7>/<8>/<9>/<0>/<1>/<2>/<3>/<4>/<5>/<6>/<7>/<8>/<9>/<0>/<1>/<2>/<3>/<4>/<5>/<6>"},
  {"long segments", "/get/foobarbizfoobarbizfoobarbizfoobarbizfoobarbizbat/3", "/get/foobarbizfoobarbizfoobarbizfoobarbizfoobarbizbat/<3>"},
  {"catchall route", "/post/products/23/reviews", "/post/<products/23/reviews>"},
  {"globs with suffix match", "/put/products/Winter-Windproof-Trapper-Hat/dp/B01J7DAMCQ", "/put/products/<Winter-Windproof-Trapper-Hat>/dp/<B01J7DAMCQ>"},
  {"route with a valid constraint", "/get/test/foo_99", "/get/test/<foo_99>"},
  {"route with an invalid constraint", "/get/test/foo_bar", nil},
}.each_with_index do |(name, path, expected), ti|
  puts path.colorize(:white).bold

  Benchmark.ips(*{% if flag?(:release) %}{3, 1}{% else %}{0.01, 0.001}{% end %}) do |x|
    x.report("retour") do
      actual = RetourApp._get(path).as?(String)
      raise "#{actual.inspect} != #{expected.inspect}" if actual != expected
    end
    x.report("amber") do
      actual = amber_router.find(path)
      actual = actual.found? ? RouteApp.get(actual.payload, actual.params) : nil
      raise "#{actual.inspect} != #{expected.inspect}" if actual != expected
    end
    x.report("radix") do
      actual = radix_router.find(path)
      actual = actual.found? ? RouteApp.get(actual.payload, actual.params) : nil
      raise "#{actual.inspect} != #{expected.inspect}" if actual != expected
    end if ti < 7
  end

  puts
end
