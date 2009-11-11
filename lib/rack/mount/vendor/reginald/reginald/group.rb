module Reginald
  class Group < Struct.new(:expression)
    attr_accessor :quantifier, :capture, :index, :name

    def initialize(*args)
      @capture = true
      super
    end

    def literal?
      quantifier.nil? && expression.literal?
    end

    def to_s
      "(#{capture ? '' : '?:'}#{expression.to_s})#{quantifier}"
    end

    def to_regexp
      Regexp.compile("\\A#{to_s}\\Z")
    end

    def match(char)
      to_regexp.match(char)
    end

    def include?(char)
      expression.include?(char)
    end

    def capture?
      capture
    end

    def ==(other)
      case other
      when String
        other == to_s
      else
        eql?(other)
      end
    end

    def eql?(other)
      other.is_a?(self.class) &&
        self.expression == other.expression &&
        self.quantifier == other.quantifier &&
        self.capture == other.capture &&
        self.index == other.index &&
        self.name == other.name
    end

    def freeze
      expression.freeze
      super
    end
  end
end