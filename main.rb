# -*- coding: utf-8 -*-

require 'tk'
require_relative './command'

=begin

# コンパイルコマンド, 実行コマンド, タイムアウト(秒)
ExecuteManager.new('ls -l', 'date', 3).execute

puts 'はじめ'
sleep 3
puts 'おわり'

=end

class MainWindow

  def initialize
    # @setting = Setting.new
    # @mailing_list = []
    # @file = nil
    show
  end

  def show
    root = TkRoot.new{
      title '採点ツール'
      geometry '1000x630'
    }
    Tk.mainloop
  end
end

MainWindow.new.show
