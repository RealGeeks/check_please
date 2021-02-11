module CheckPlease

  class PathSegmentMatcher
    def self.call(a,b)
      new(a,b).call
    end

    attr_reader :a, :b, :types
    def initialize(a, b)
      @a, @b = a, b
      @types = [ _type(a), _type(b) ].sort
    end

    def call
      # These checks are order-dependent
      return true  if both?(:empty)
      return false if either?(:empty) # assumes !both?(:empty)
      return true  if either?(:splat) # assumes !either?(:empty)
      # The rest aren't

      return a.name == b.name if both?(:plain)
      return a.key == b.key   if key_and_key_value?
      return false
    end

    private

    def _type(x)
      return :empty     if x.empty?
      return :splat     if x.splat?
      return :key       if x.key_expr?
      return :key_value if x.key_val_expr?
      :plain
    end

    def both?(type)
      types.uniq == [type]
    end

    def either?(type)
      types.include?(type)
    end

    def key_and_key_value?
      types == [ :key, :key_value ]
    end
  end

end
