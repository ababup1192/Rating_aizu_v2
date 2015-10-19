# -*- coding: utf-8 -*-
require 'observer'
require 'tk'

module View
  class RatingDir
    include Observable

    def initialize(dialog, rating_dir)
      add_observer(rating_dir)

      @label = TkLabel.new(dialog){
        text '"採点対象ディレクトリ"の場所:'
      }

      @frame = TkFrame.new(dialog)

      @entry = TkEntry.new(@frame){
        width 40
        state 'readonly'
      }
      TkUtils.set_entry_value(@entry, rating_dir.value)

      @button = TkButton.new(@frame){
        text '変更'
      }
      @button.command(self.method(:save_value))
   end

    def pack()
        @label.pack({side: 'top', anchor: 'w', padx: 10, pady: 10})
        @frame.pack({side: 'top'})
        @entry.pack({side: 'left'})
        @button.pack({side: 'left', padx: 15})
    end

    def save_value()
      value = Tk.chooseDirectory
      if !value.empty? then
        TkUtils.set_entry_value(@entry,  value)
      else
        @value = nil
      end
      changed
      notify_observers(value)
    end
  end
end
