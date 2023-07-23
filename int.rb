# Interval arithmetics

class Int
  include Comparable
  attr_reader :begin, :last, :median
  protected attr_reader :values

  def initialize(beg, last = nil, error: nil)
    if error
      raise ArgumentError, 'do not specify 2nd arg when `error:`' if last
      raise ArgumentError, 'error value should be non-negtative' if error.negative?
      med = beg
      beg, last = med-error, med+error
    else
      raise ArgumentError, 'specify 2nd arg when no `error:`' unless last
      raise ArgumentError, 'needs begin <= last' unless beg <= last
    end
    @begin, @last = beg, last
    @values = [beg, last]
    @median = (beg + last) / 2.0
  end

  private

  def new(...) = self.class.new(...)
  def scala?(other) = [Integer, Float, Rational].include?(other.class)
  def ensure_coerced(other) = other.kind_of?(self.class) ? other : coerce(other).first

  protected

  def round_median(n) = (@median = @median.round(n)).then { self }
  def invert
    beg = @last.zero? ? -Float::INFINITY : 1.0 / @last
    last = @begin.zero? ? Float::INFINITY : 1.0 / @begin
    new(beg, last)
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
    new(@begin + other.begin, @last + other.last)
  end

  def -(other)
    other = ensure_coerced(other)
    new(@begin - other.last, @last - other.begin)
  end

  def *(other)
    other = ensure_coerced(other)
    new(*values.product(other.values).map{_1.inject(:*)}.minmax)
  end

  def /(other)
    self * ensure_coerced(other).invert
  end

  def <=>(other)
    other = ensure_coerced(other)
    return 0 if @begin == other.begin && @last == other.last
    return 1 if @begin > other.last
    return -1 if @last < other.begin
    nil
  end

  def <=(other)
    other = ensure_coerced(other)
    @last == other.begin || (self <=> other).then{|c| !c.nil? && c < 0}
  end

  def >=(other)
    other = ensure_coerced(other)
    @begin == other.last || (self <=> other).then{|c| !c.nil? && c > 0}
  end

  def comparable?(other)
    other = ensure_coerced(other) rescue (return false)
    !!(self <=> other) || @last == other.begin || @begin == other.last
  end

  def round(n)
    new(*[self.begin,last].map{_1.round(n)}).round_median(n)
  end

  def with_error(e) = self * self.class.error(e)
  def with_error_percent(e) = with_error(e * 0.01)

  def to_s = "(#{self.begin}..#{last})"
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
end
