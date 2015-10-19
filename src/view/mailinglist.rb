# -*- coding: utf-8 -*-
require 'observer'
require 'tk'
require_relative '../util/tkextension'

module View
  class Mailinglist
    include Observable

    def initialize(dialog, mailinglist)
      add_observer(mailinglist)

      @label = TkLabel.new(dialog){
        text '"メーリングリスト"の場所:'
      }

      @frame = TkFrame.new(dialog)

      @entry = TkEntry.new(@frame){
        width 40
        state 'readonly'
      }
      TkUtils.set_entry_value(@entry, mailinglist.value)

      @button = TkButton.new(@frame){
        text '変更'
      }
      @button.command(self.method(:save_value))
    end

    def pack()
        @label.pack({side: 'top', anchor: 'w', padx: 10, pady: 15})
        @frame.pack({side: 'top'})
        @entry.pack({side: 'left'})
        @button.pack({side: 'left', padx: 15})
    end

    def save_value()
      value = Tk.getOpenFile
      if !value.empty? then
        TkUtils.set_entry_value(@entry, value)
      else
        value = nil
      end
      changed
      notify_observers(value)
    end
  end
end
