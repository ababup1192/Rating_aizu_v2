# -*- coding: utf-8 -*-
require 'observer'
require 'tk'
require_relative '../util/tkextension'

module View
  class ResultFile
    include Observable

    def initialize(dialog, result_file)
      add_observer(result_file)

      @label.TkLabel.new(dialog){
        text '成績ファイル:'
        pack({side: 'top', anchor: 'w', padx: 10, pady: 10})
      }

      @frame = TkFrame.new(dialog){
        pack({side: 'top'})
      }

      @entry = TkEntry.new(@frame){
        width 40
        text result_file.value
        state 'readonly'
        pack({side: 'left'})
      }

      result_path_button = TkButton.new(result_path_frame){
        text '変更'
        command proc{
          preferences = RatingPreferences.instance
          preferences.save_result_path()
        }
        pack({side: 'left', padx: 15})
      }



      @label = TkLabel.new(dialog){
        text '"メーリングリスト"の場所:'
      }

      @frame = TkFrame.new(dialog)

      @entry = TkEntry.new(@frame){
        width 40
        text mailinglist.value
        state 'readonly'
      }

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
      @value = Tk.getSaveFile
      if !@value.empty?
        TkUtils.set_entry_value(@entry,  value)
      else
        value = nil
      end
      changed
      notify_observers(value)
    end
  end
end
