class RubyDoc
  attr_accessor :uri, :type, :class_name, :category, :expressions, :description
  def initialize(uri: nil, type: nil, class_name: nil, category: nil, expressions: nil, description: nil)
    @uri = uri
    @type = type
    @class_name = class_name
    @category = category
    @expressions = expressions
    @description = description
  end

  def to_a
    [@uri, @type, @class_name, @category, @expressions.join('<br>'), @description]
  end
end
