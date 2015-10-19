# -*- coding: utf-8 -*-
require 'observer'
require_relative 'changing_observer'

# 採点対象ファイルとコマンドを管理。
class CommandSelect
  include ChangingObserver
  attr_reader :name, :value

  def initialize(prefs)
    @observer = prefs
    @name = ['採点対象ファイル', 'コンパイルコマンド', '実行コマンド']
    @value = {target_files: [], compile_command: nil,
              execute_command: nil}
  end

  def update(value)
    @value = @value.merge(value)
    update_name()
  end

  def update_name()
    names = ['採点対象ファイル', 'コンパイルコマンド', '実行コマンド']
    # ハッシュから値がnil(未設定)のものを取得
    args = @value.values.map.with_index{ |v, index| v.nil? || v.empty? ? index : nil }.
      select{ |v| !v.nil? }
    # 未設定のものの名前をnameとしてupdate
    @name = names.values_at(*args)
  end

  def save_value()
    changed
    notify_observers(command_select: self)
  end

  # 採点可能かどうか。
  def rating?
    # 全ての値が必須。
    @value.values.select{ |v| v.nil? || v.empty? }.length == 0
  end
end
