# frozen_string_literal: true
require 'nokogiri'
require 'rouge'

class RubyMemberDoc
  attr_accessor :uri, :class_type, :class_name, :member_type, :expressions, :description
  def initialize(uri: nil, class_type: nil, class_name: nil, member_type: nil, expressions: nil, description: nil)
    @uri = uri
    @class_type = class_type
    @class_name = class_name
    @member_type = member_type
    @expressions = expressions
    @description = description
  end

  def to_a
    [uri, class_type, class_name, member_type, htmlized_expressions, description]
  end

  private

  def htmlized_expressions
    exps = @expressions.map { |e| do_syntax_highlight(e) }
    "<ul><li>#{exps.join('</li><li>')}</li></ul>"
  end

  def description
    unless @_did_syntax_highlighted_desc
      d = Nokogiri::HTML.parse(@description)
      d.css('pre').each { |e|
        e.inner_html = do_syntax_highlight(e.inner_text)
      }
      @_did_syntax_highlighted_desc = d.to_html
    end
    @_did_syntax_highlighted_desc
  end

  def do_syntax_highlight(code)
    formatter.format(lexer.lex(code))
  end

  def lexer
    @_lexer ||= Rouge::Lexers::Ruby.new
  end

  def formatter
    @_formatter ||= Rouge::Formatters::HTML.new
  end
end
