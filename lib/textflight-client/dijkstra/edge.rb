
class Edge
  attr_accessor :from, :to, :weight, :direction

  def initialize(from, to, weight, direction = nil)
    if from.nil? || to.nil?
      message = <<~EOM
        From and to need to be non-null, found:

        from: '#{from}'
          to: '#{to}'
      EOM

      raise message
    end
    @from, @to, @weight = from, to, weight
    @direction = direction
  end

  def <=>(other)
    self.weight <=> other.weight
  end

  def == (other)
    (other.to == @to && other.from == @from) ||
      (other.to = @from && other.from == @to)
  end

  def to_s
    str = "#{from.to_s} => #{to.to_s} with weight #{weight}"
    if @direction
      str = "#{str} (#{@direction})"
    end
    str
  end

  def inspect; to_s; end
end
