# -*- coding: utf-8 -*-
require 'observer'
require_relative '../util/changing_observer'

# 区切り文字を管理。
class Delimiter
  include ChangingObserver
  attr_reader :name, :value

  def initialize(prefs)
    @observer = prefs
    add_observer(prefs)

    @name = '区切り文字'
    @value = ','
  end

  def update(value)
    @value = value
  end

  def save_value()
    changed
    notify_observers(delimiter: self)
  end

  # 区切り文字プレビュー
  def preview
    "s1111111#{@value}100"
  end

  # 採点可能かどうか。
  def rating?
    true
  end
end
