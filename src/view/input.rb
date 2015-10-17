# -*- coding: utf-8 -*-
require 'observer'
require 'tk'
require_relative '../tkextension'

module View
  class Input
    include Observable

    def initialize(button, value)
      @dialog = Dialog.new(button, '入力データの設定', 450, 400){
        dialog = @dialog.dialog

        @input_textsc = TkTextWithScrollbar.new(dialog, 50, 20, value)
        @input_textsc.pack

        button_frame = TkFrame.new(dialog){
          pack(side: 'top', pady: 5)
        }

        ok_button = TkButton.new(button_frame){
          text 'OK'
          pack(side: 'left')
        }
        ok_button.command(self.method(:save_input))

        cancel_button = TkButton.new(button_frame){
          text 'キャンセル'
          pack(side: 'left', padx: 15)
        }
        cancel_button.command(@dialog.method(:close))
      }
    end

    def launch()
      @dialog.launch()
    end

    def save_input()
      changed
      notify_observers(@input_textsc.get_text)
      @dialog.close
    end
  end
end

=begin
root = TkRoot.new{
  title 'Rating Aizu'
  resizable [0, 0]
  geometry '100x100+150+150'
}

button = TkButton.new{
    text 'push'
    command proc{
      View::Input.new(button, 'aaaaa').launch
    }
    pack
}

Tk.mainloop
=end
