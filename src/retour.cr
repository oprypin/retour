module Retour
  class Error < Exception
  end

  class NotFound < Error
  end

  macro routes(routes, default = /.+?/, method = :call)
    {% regex = [] of String %}\
    {% funcs = [] of {name: String, params: Array(String), args: Array(String)} %}\
    {% for route, func, ri in routes %}\
      {% funcs << {name: func.id, params: params = [] of String, args: args = [] of String} %}\
      {% if ri > 0 %}\
        {% regex << "|" %}\
      {% end %}\
      {% regex << "(?:()" %}\
      {% for part in (route.is_a?(StringInterpolation) ? route.expressions : [route]) %}\
        {% if part.is_a?(StringLiteral) %}\
          {% regex << part.gsub(/[$()*+.?[\\^{|]/, "\\\\\\0") %}\
        {% elsif part.is_a?(Call) %}\
          {% regex << "(" << (part.args[0] || default).source << ")" %}\
          {% part = part.name %}\
          {% params << part %}
        {% end %}\
        {% args << part %}\
      {% end %}\
      {% regex << ")" %}\
    {% end %}\

    {% for func in funcs %}\
    def self.gen_{{ func[:name] }}({{*func[:params]}}) : String
      String.interpolation({{*func[:args]}})
    end
    {% end %}\

    {% gi = 0 %}
    def {{method.id}}(input : String, *args, **kwargs)
      {% if regex.empty? %}\
        {% regex = "@^" %}  # Never matches
        raise Retour::NotFound.new(input)
      {% else %}
        {% regex = "(?:" + regex.join("") + ")" %}
        if !(m = %r(\A(?:{{ regex.id }})\Z).match(input))
          raise Retour::NotFound.new(input)
        {% for func in funcs %}\
        elsif m[{{ gi += 1 }}]?
          {{ func[:name] }}(*args, **kwargs{% for param in func[:params] %}, {{ param }}: m[{{ gi += 1 }}]{% end %})
        {% end %}\
        else
          raise Retour::Error.new("BUG: Retour regex matched but didn't find any group")
        end
      {% end %}\
    end

    def self.{{method.id}}_regex : Regex
      %r({{ regex.id }})
    end
  end
end
