module Retour
  class NotFound < Exception
  end

  macro routes(routes, default = ".+?", method = :call)
    {% regex = [] of String %}\
    {% funcs = [] of {name: String, args: Array(String), texts: Array(String)} %}\
    {% for route, func, ri in routes %}\
      {% brack = 0 %}\
      {% escape = false %}\
      {% text_start = 0 %}\
      {% funcs << {name: func.id, args: args = [] of String, texts: texts = [] of String} %}\
      {% if ri > 0 %}\
        {% regex << "|" %}\
      {% end %}\
      {% regex << "(?:()" %}\
      {% for c, ci in route.chars %}\
        {% if escape %}\
          {% escape = false %}\
        {% elsif c == '\\' %}\
          {% escape = true %}\
        {% elsif c == '{' %}\
          {% if brack == 0 %}\
            {% texts << route[text_start...ci] %}\
            {% regex << route[text_start...ci].gsub(/[$()*+.?[\\^{|]/, "\\\\\\0") %}\
            {% regex_start = brack_start = ci + 1 %}\
            {% param_end = nil %}\
          {% end %}\
          {% brack += 1 %}\
        {% elsif c == ':' && brack > 0 && param_end == nil %}\
          {% param_end = ci %}\
          {% regex_start = ci + 1 %}\
        {% elsif c == '}' %}\
          {% brack -= 1 %}\
          {% if brack < 0 %}\
            {% raise "Too many closing curly braces in this route (at position #{ci}):\n#{route.id}" %}\
          {% end %}\
          {% if brack == 0 %}\
            {% if param_end == nil %}\
              {% param_end = ci %}\
              {% re = default %}\
            {% else %}\
              {% re = route[regex_start...ci] %}\
            {% end %}\
            {% regex << "(" << re << ")" %}\
            {% unless brack_start < param_end %}\
              {% raise "Empty parameter name in this route (at position #{param_end}):\n#{route.id}" %}\
            {% end %}\
            {% args << route[brack_start...param_end].id %}\
            {% text_start = ci + 1 %}\
          {% end %}\
        {% end %}\
      {% end %}\
      {% texts << route[text_start..-1] %}\
      {% regex << route[text_start..-1].gsub(/[$()*+.?[\\^{|]/, "\\\\\\0") %}\
      {% regex << ")" %}\
      {% if brack > 0 %}\
        {% raise "Too many opening curly braces in this route (at position #{brack_start}):\n#{route.id}" %}\
      {% end %}\
    {% end %}\

    {% for func in funcs %}\
    def self.gen_{{ func[:name] }}({% for arg, i in func[:args] %}{{ arg }} a{{ i + 1 }}, {% end %}) : String
      String.interpolation({% for text, i in func[:texts] %}{% if i > 0 %}a{{ i }}, {% end %}{{ text }}, {% end %})
    end
    {% end %}\

    {% gi = 0 %}
    def {{method.id}}(input : String, *args, **kwargs)
      if !(m = %r(\A(?:{{ regex.join("").id }})\Z).match(input))
        raise Retour::NotFound.new(input)
      {% for func in funcs %}\
      elsif m[{{ gi += 1 }}]?
        {{ func[:name] }}(*args, **kwargs{% for arg in func[:args] %}, {{ arg }}: m[{{ gi += 1 }}]{% end %})
      {% end %}
      end
    end
  end
end
