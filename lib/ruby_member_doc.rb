# frozen_string_literal: true
require 'nokogiri'
require 'rouge'

class RubyMemberDoc
  attr_accessor :uri,
                :class_type,
                :class_name,
                :member_type,
                :expressions,
                :description
  def initialize(args)
    args ||= {}
    @uri         = args[:uri]
    @class_type  = args[:class_type]
    @class_name  = args[:class_name]
    @member_type = args[:member_type]
    @expressions = args[:expressions]
    @description = args[:description]
  end

  def to_a
    [
      uri,
      class_type,
      class_name,
      member_type,
      htmlized_expressions,
      syntax_highlighted_description
    ]
  end

  private

  def htmlized_expressions
    "<ul><li>#{@expressions.join('</li><li>')}</li></ul>"
  end

  def syntax_highlighted_description
    unless @_did_syntax_highlighted_desc
      d = Nokogiri::HTML.parse(@description)
      d.css('pre').each do |e|
        e.inner_html = do_syntax_highlight(e.inner_text)
      end
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
