require "http"

require "./retour"

module Retour
  {% for httpm in %w[Get Post Put Patch Delete Link Unlink Head] %}
    annotation {{ httpm.id }}
    end
  {% end %}

  module HTTPRouter
    macro included
      macro finished
        {% for httpm in [Retour::Get, Retour::Post, Retour::Put, Retour::Patch, Retour::Delete, Retour::Link, Retour::Unlink, Retour::Head] %}
          Retour.routes({
            {% for method in @type.methods %}{% for annot in method.annotations(httpm) %}
              {{ annot[0] }} => {{ method.name.id }},
            {% end %}{% end %}
          } of String => String, default: "[^/]+?", method: _{{ httpm.name.split("::")[-1].downcase.id }})
        {% end %}
      end

      def call(method : String, path : String, *args, **kwargs)
        case method
          {% for httpm in %w[Get Post Put Patch Delete Link Unlink Head] %}
            when {{ httpm.upcase }}
              _{{ httpm.downcase.id }}(path, *args, **kwargs)
          {% end %}
          else
          raise Retour::NotFound.new(path)
        end
      end

      def call(context : HTTP::Server::Context, *args, **kwargs)
        call(context.request.method, context.request.path, *args, **kwargs)
      end
    end
  end
end
