# Interval arithmetics

class Int
  include Comparable

  protected attr_reader :beg, :last

  def initialize(beg, last = nil, error: nil)
    if error
      raise ArgumentError, 'do not specify 2nd arg when `error:`' if last
      raise ArgumentError, 'error value should be non-negtative' if error.negative?
      med = beg
      beg, last = med-error, med+error
    else
      raise ArgumentError, 'specify 2nd arg when no `error:`' unless last
      raise ArgumentError, 'needs beg <= last' unless beg <= last
    end
    @beg, @last = beg, last
    @range = nil
    @median = nil
  end

  private

  def range = @range ||= Range.new(@beg, @last)
  def new(...) = self.class.new(...)
  def scala?(other) = [Integer, Float, Rational].include?(other.class)
  def ensure_coerced(other) = other.kind_of?(self.class) ? other : coerce(other).first

  protected

  def values = @values ||= [@beg, @last]
  def round_median(n) = @median = median.round(n)

  public

  def self.error(error)
    new(1, error:)
  end

  def median = @median ||= (@beg + @last) / 2.0

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
    new(@beg + other.beg, @last + other.last)
  end

  def -(other)
    other = ensure_coerced(other)
    new(@beg - other.last, @last - other.beg)
  end

  def *(other)
    other = ensure_coerced(other)
    new(*values.product(other.values).map{_1.inject(:*)}.minmax)
  end

  def /(other)
    other = ensure_coerced(other)
    raise 'I sure I do not know how to implement this method. (TODO: read SICP)'
    new(0, 0)
  end

  def <=>(other)
    other = ensure_coerced(other)
    return 0 if @beg == other.beg && @last == other.last
    return 1 if @beg > other.last
    return -1 if @last < other.beg
    nil
  end

  def <=(other)
    other = ensure_coerced(other)
    @last == other.beg || (self <=> other).then{|c| !c.nil? && c < 0}
  end

  def >=(other)
    other = ensure_coerced(other)
    @beg == other.last || (self <=> other).then{|c| !c.nil? && c > 0}
  end

  def comparable?(other)
    other = ensure_coerced(other) rescue false
    return false unless other
    !!(self <=> other) || @last == other.beg || @beg == other.last
  end

  def round(n)
    new(*[beg,last].map{_1.round(n)}).tap do |x|
      x.instance_variable_set(:@median, median.round(n))
    end
  end

  def to_s = "(#{beg}..#{last})"
  def inspect = self.class.name + to_s.sub('..', "..(#{median})..")
end

def Int(...) = Int.new(...)

if $0 == __FILE__
  x, y = Int(1, 2), Int(2, 3)
  pp [x, y]

  pp [x == y, x != y]
  pp [x >= y, x <= y]
  pp [y >= x, y <= x]
  pp [x.comparable?(y), y.comparable?(x)]
end
