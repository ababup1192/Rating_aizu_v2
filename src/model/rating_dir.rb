# -*- coding: utf-8 -*-
require 'observer'
require_relative 'changing_observer'

# 採点対象ディレクトリを管理。
class RatingDir
  include ChangingObserver
  attr_reader :name, :value

  def initialize(prefs)
    @observer = prefs
    add_observer(prefs)

    @name = '採点対象ディレクトリ'
    @value = nil
  end

  def update(value)
    @value = value
  end

  def save_value()
    changed
    notify_observers(rating_dir: self)
  end

  # 入力があるかどうか。
  def empty?
    @value.nil?
  end

  # 採点可能かどうか。
  def rating?
    empty?
  end
end
