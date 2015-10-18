# -*- coding: utf-8 -*-
require 'observer'
require_relative 'changing_observer'

# 成績ファイルを管理。
class ResultFile
  include ChangingObserver
  attr_reader :name, :value

  def initialize(prefs)
    @observer = prefs
    add_observer(prefs)

    @name = '成績ファイル'
    @value = nil
  end

  def update(hash)
    if hash.has_key?(:result_file)
      @value = value[:result_file]
    end
  end

  def save_value()
    changed
    notify_observers(result: self)
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
