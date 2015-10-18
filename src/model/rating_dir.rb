# -*- coding: utf-8 -*-

# 採点対象ディレクトリを管理。
class RatingDir
  attr_reader :name, :value
  def initialize
    @name = '採点対象ディレクトリ'
    @value = nil
  end

  def add_observer(prefs)
    prefs.add_observer(self)
  end

  def update(hash)
    if hash.has_key?(:rating_dir)
      @value = value[:rating_dir]
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
