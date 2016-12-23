# frozen_string_literal: true
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
    "<ul><li>#{@expressions.join('</li><li>')}</li></ul>"
  end

end
