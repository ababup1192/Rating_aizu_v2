# -*- coding: utf-8 -*-
require 'observer'
require 'tk'
require_relative '../util/tkextension'

module View
  class ResultFile
    include Observable

    def initialize(dialog, result_file)
      add_observer(result_file)

      @label = TkLabel.new(dialog){
        text '成績ファイル:'
      }

      @frame = TkFrame.new(dialog)

      @entry = TkEntry.new(@frame){
        width 40
        state 'readonly'
      }
      TkUtils.set_entry_value(@entry, result_file.value)

      @button = TkButton.new(@frame){
        text '変更'
      }
      @button.command(method(:save_value))
    end

    def pack()
        @label.pack({side: 'top', anchor: 'w', padx: 10, pady: 10})
        @frame.pack({side: 'top'})
        @entry.pack({side: 'left'})
        @button.pack({side: 'left', padx: 15})
    end

    def save_value()
      value = Tk.getSaveFile
      if !value.empty?
        TkUtils.set_entry_value(@entry, value)
      else
        value = nil
      end
      changed
      notify_observers(value)
    end
  end
end
