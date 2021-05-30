require "http"
require "uri"

require "./retour"

module Retour
  private struct Path
    getter path : String

    def initialize(@path)
    end

    forward_missing_to path
    delegate to_s, to: path
  end

  def self.path(path : String)
    return Path.new(path)
  end

  {% for httpm in %w[Get Post Put Patch Delete Link Unlink Head] %}
    annotation {{ httpm.id }}
    end
  {% end %}

  def self.percent_encode(path : Path) : String
    String.build do |io|
      URI.encode(path.path, io) { |c| URI.unreserved?(c) || c == '/'.ord }
    end
  end

  def self.percent_encode(path) : String
    String.build do |io|
      URI.encode(path.to_s, io) { |c| URI.unreserved?(c) }
    end
  end

  def self.percent_decode(path) : String
    URI.decode(path)
  end

  module HTTPRouter
    macro included
      macro finished
        {% verbatim do %}
        {% for httpm in [Retour::Get, Retour::Post, Retour::Put, Retour::Patch, Retour::Delete, Retour::Link, Retour::Unlink, Retour::Head] %}
          Retour.routes({
            {% for method in @type.methods %}{% for annot in method.annotations(httpm) %}\
              {{ annot[0] }} => {{ method.name.id }},
            {% end %}{% end %}\
          } of String => String, default: "[^/]+?", method: _{{ httpm.name.split("::")[-1].downcase.id }}, decode_item: Retour.percent_decode, encode_item: Retour.percent_encode)
        {% end %}
        {% end %}
      end

      def call(method : String, path : String, *args, **kwargs)
        case method
        {% for httpm in %w[Get Post Put Patch Delete Link Unlink Head] %}\
        when {{ httpm.upcase }}
          _{{ httpm.downcase.id }}(path, *args, **kwargs)
        {% end %}\
        else
          return Retour::NotFound.new
        end
      end

      def call(context : HTTP::Server::Context, *args, **kwargs)
        call(context.request.method, context.request.path, *args, **kwargs)
      end
    end
  end
end
