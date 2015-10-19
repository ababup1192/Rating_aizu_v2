# -*- coding: utf-8 -*-
require 'observer'
require_relative '../util/changing_observer'

# ユーザの一覧を管理。
class Mailinglist
  include ChangingObserver
  attr_reader :name, :value

  def initialize(prefs)
    @observer = prefs
    add_observer(prefs)

    @name = 'メーリングリスト'
    @value = nil
  end

  def update(value)
    @value = value
  end

  def save_value()
    changed
    notify_observers(mailinglist: self)
  end

  # 入力があるかどうか。
  def empty?
    @value.nil?
  end

  # 採点可能かどうか。
  def rating?
    !empty?
  end
end
