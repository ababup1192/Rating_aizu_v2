# -*- coding: utf-8 -*-

# ユーザの一覧を管理。
class Mailinglist
  attr_reader :name, :value
  def initialize
    @name = 'メーリングリスト'
    @value = nil
  end

  def add_observer(prefs)
    prefs.add_observer(self)
  end

  def update(hash)
    if hash.has_key?(:mailing_list)
      @value = value[:mailing_list]
    end
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
