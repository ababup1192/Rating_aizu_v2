# -*- coding: utf-8 -*-

# 区切り文字を管理。
class Delimiter
  attr_reader :name, :value
  def initialize
    @name = '区切り文字'
    @value = ','
  end

  def add_observer(pref)
    pref.add_observer(self)
  end

  def update(hash)
    if hash.has_key?(:delimiter)
      @value = value[:delimiter]
    end
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
