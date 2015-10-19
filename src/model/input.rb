# -*- coding: utf-8 -*-
require 'observer'
require_relative 'changing_observer'

# 実行時の標準入力を管理。
class Input
  include ChangingObserver
  attr_reader :name, :value

  def initialize(prefs)
    @observer = prefs
    add_observer(prefs)

    @name = '標準入力'
    @value = nil
  end

  def update(value)
    @value = value
  end

  def save_value()
    changed
    notify_observers(input: self)
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
