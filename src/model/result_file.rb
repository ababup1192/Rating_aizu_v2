# -*- coding: utf-8 -*-

# 成績ファイルを管理。
class ResultFile
  attr_reader :name, :value
  def initialize
    @name = '成績ファイル'
    @value = nil
  end

  def add_observer(prefs)
    prefs.add_observer(self)
  end

  def update(hash)
    if hash.has_key?(:result_file)
      @value = value[:result_file]
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
