# -*- coding: utf-8 -*-
require 'tk'
require 'singleton'

class CommandSelect
  include Singleton

  def launch(button)
    @dialog = Dialog.new(button, 'ファイルとコマンドの設定', 455, 500){
      dialog = @dialog.dialog

    }
    @dialog.launch
  end
end
