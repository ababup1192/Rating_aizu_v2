# -*- coding: utf-8 -*-

# 実行時の標準入力を管理。
class Input
  attr_reader :name, :value
  def initialize
    @name = '標準入力'
    @value = nil
  end

  def add_observer(input_view)
    input_view.add_observer(self)
  end

  def update(value)
    @value = value
  end

  # 入力があるかどうか。
  def empty?
    @value.nil?
  end

  # 採点可能かどうか。
  def rating?
    # 標準入力は必須ではないので、常にtrue
    true
  end
end
