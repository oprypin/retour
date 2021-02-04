macro retour(routes, default = ".+?")
  {% regex = [] of String %}
  {% gi = 0 %}
  def call(input : String)
    if !REGEX.match(input); nil
    {% for route, func, ri in routes %}
      {% brack = 0 %}
      {% escape = false %}
      {% text_start = 0 %}
      elsif ${{ gi += 1 }}?; {{ func.id }}(
        {% if ri > 0 %}
          {% regex << "|" %}
        {% end %}
        {% regex << "(?:()" %}
        {% for c, ci in route.chars %}
          {% if escape %}
            {% escape = false %}
          {% elsif c == '\\' %}
            {% escape = true %}
          {% elsif c == '{' %}
            {% if brack == 0 %}
              {% regex << route[text_start...ci].gsub(/[$()*+.?[\\^{|]/, "\\\\\\0") %}
              {% regex_start = brack_start = ci + 1 %}
              {% param_end = nil %}
            {% end %}
            {% brack += 1 %}
          {% elsif c == ':' && brack > 0 && param_end == nil %}
            {% param_end = ci %}
            {% regex_start = ci + 1 %}
          {% elsif c == '}' %}
            {% brack -= 1 %}
            {% if brack < 0 %}
              {% raise "Too many closing curly braces in this route (at position #{ci}):\n#{route.id}" %}
            {% end %}
            {% if brack == 0 %}
              {% if param_end == nil %}
                {% param_end = ci %}
                {% re = default %}
              {% else %}
                {% re = route[regex_start...ci] %}
              {% end %}
              {% regex << "(" << re << ")" %}
              {% unless brack_start < param_end %}
                {% raise "Empty parameter name (at position #{param_end}):\n#{route.id}" %}
              {% end %}
              {{ route[brack_start...param_end].id }}: ${{ gi += 1 }},
              {% text_start = ci + 1 %}
            {% end %}
          {% end %}
        {% end %}
        {% regex << route[text_start..-1].gsub(/[$()*+.?[\\^{|]/, "\\\\\\0") %}
      {% regex << ")" %}
      )
      {% if brack > 0 %}
        {% raise "Too many opening curly braces in this route (at position #{brack_start}):\n#{route.id}" %}
      {% end %}
    {% end %}
    end
  end

  REGEX = %r(\A(?:{{ regex.join("").id }})\Z)
end
