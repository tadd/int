# Interval arithmetics

class Int < Numeric
  attr_reader :begin, :end, :median
  protected attr_reader :values

  def initialize(beg, encl = nil, error: nil)
    if error
      raise ArgumentError, 'do not specify 2nd arg when `error:`' if encl
      raise ArgumentError, 'error value should be non-negtative' if error.negative?
      med = beg
      beg, encl = med-error, med+error
    else
      raise ArgumentError, 'specify 2nd arg when no `error:`' unless encl
      raise ArgumentError, "needs begin <= end: #{beg} <=> #{encl}" unless beg <= encl
    end
    @begin, @end = beg, encl
    @values = [beg, encl]
    @median = (beg + encl) / 2.0
  end

  private

  def new(...) = self.class.new(...)
  def scala?(other) = [Integer, Float, Rational].include?(other.class)
  def ensure_coerced(other) = other.kind_of?(self.class) ? other : coerce(other).first

  protected

  def round_median(n) = (@median = @median.round(n)).then { self }
  def invert
    one = @end.zero? ? -1.0 : 1.0
    new(one / @end, 1.0 / @begin)
  end

  public

  def self.error(error)
    new(1, error:)
  end

  def coerce(other)
    if other.kind_of?(self.class)
      # do nothing
    elsif scala?(other)
      other = new(*[other]*2)
    else
      raise "Unknown class #{other.class}: #{other}"
    end
    [other, self]
  end

  def +(other)
    other = ensure_coerced(other)
    new(@begin + other.begin, @end + other.end)
  end

  def -(other)
    other = ensure_coerced(other)
    new(@begin - other.end, @end - other.begin)
  end

  def *(other)
    other = ensure_coerced(other)
    mul = values.product(other.values).map{_1.inject(:*)}
    raise "got a NaN; I don't know what to do" if mul.any?(&:nan?)
    new(*mul.minmax)
  end

  def /(other)
    self * ensure_coerced(other).invert
  end

  def <=>(other)
    other = ensure_coerced(other)
    return 0 if @begin == @end && @begin == other.begin && @begin == other.end
    return 1 if @begin > other.end
    return -1 if @end < other.begin
    nil
  end

  def <=(other)
    other = ensure_coerced(other)
    @end <= other.begin
  end

  def >=(other)
    other = ensure_coerced(other)
    @begin >= other.end
  end

  def comparable?(other)
    other = ensure_coerced(other) rescue (return false)
    !!(self <=> other) || @end == other.begin || @begin == other.end
  end

  def round(n)
    new(*[self.begin,self.end].map{_1.round(n)}).round_median(n)
  end

  def with_error(e) = self * self.class.error(e)
  def with_error_percent(e) = with_error(e * 0.01)

  def to_s = "(#{self.begin}..#{self.end})"
  def inspect = self.class.name + to_s.sub('..', "..(#{median})..")
end

def Int(...) = Int.new(...)

if $0 == __FILE__
  x, y = Int(1, 2), Int(2, 3)
  pp(x:, y:)

  pp [x == y, x != y]
  pp [x >= y, x <= y]
  pp [y >= x, y <= x]
  pp [x.comparable?(y), y.comparable?(x)]

  z = Int(1.1, 1.4)
  pp z
  pp [x.comparable?(z), z.comparable?(x)]
  pp z.comparable?(:foo)
  pp z.round(1)
  pp Int.error(0.2)

  pp [x.with_error(0.01), x.with_error_percent(1)].map{_1.round(2)}

  pp [z / 2, z / z].map{_1.round(2)}

  i = Int(0, 1.2)
  j = Int(-1.2, 0)
  pp [x/i, x/j]
  ji = j.send(:invert)
  pp ji
  pp [i, ji]
  #pp i*ji
  #pp i/j
  #pp j/i
end
