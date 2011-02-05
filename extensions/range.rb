class Range
  def overlaps?(range)
    self.include?(range.first) || range.include?(self.first)
  end
end