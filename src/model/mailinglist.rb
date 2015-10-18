# -*- coding: utf-8 -*-
require 'observer'
require_relative 'changing_observer'

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

  def add_observer(prefs)
    prefs.add_observer(self)
  end

  def update(hash)
    if hash.has_key?(:mailinglist)
      @value = value[:mailinglist]
    end
  end

  def save_value()
    changed
    notify_observers(mailinglist: value)
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
