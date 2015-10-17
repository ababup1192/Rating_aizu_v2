# -*- coding: utf-8 -*-

# 実行時の標準入力を管理。
class Input
  attr_reader :value
  def initialize(input_view)
    @input = nil
    input_view.add_observer(self)
  end

  def update(value)
    @value = value
  end

  def rating?
    !@value.nil?
  end
end
