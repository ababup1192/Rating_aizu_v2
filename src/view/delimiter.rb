# -*- coding: utf-8 -*-
require 'observer'
require 'tk'

module View
  class Delimiter
    include Observable

    def initialize(dialog, delimiter)
      add_observer(delimiter)

      @label = TkLabel.new(dialog){
        text '区切り文字:'
      }

      @frame = TkFrame.new(dialog)

      @delimiter_var = TkVariable.new

      @comma_radio = TkRadioButton.new(@frame) {
        text 'カンマ'
        value 0
        variable @delimiter_var
      }

      @tab_radio = TkRadioButton.new(@frame) {
        text 'タブ'
        value 1
        variable @delimiter_var
      }

      @any_radio = TkRadioButton.new(@frame) {
        text '任意の文字'
        value 2
        variable @delimiter_var
      }

      @any_delimiter_var = TkVariable.new

      @delimiter_entry = TkEntry.new(@frame){
        width 2
        state 'readonly'
        textvariable @any_delimiter_var
      }

      @delimiter_var.trace('w',  proc {
        if @delimiter_var.value == '2' then
          @delimiter_entry.state = 'normal'
        else
          @delimiter_entry.state = 'readonly'
        end
      })

      @preview_entry = TkEntry.new(dialog){
        width 30
        state 'readonly'
      }

      any_delimiter_var.trace('w',  proc{
        preferences = RatingPreferences.instance
        preferences.delimiter = any_delimiter.value
        TkUtils.set_entry_value(delimiter_entry,
                                "s1111111#{any_delimiter.value}100")
      })

      @comma_radio.command proc{
        preferences = RatingPreferences.instance
        preferences.delimiter = ',  '
        TkUtils.set_entry_value(delimiter_entry,  "s1111111,  100")
      }

      @tab_radio.command proc{
        preferences = RatingPreferences.instance
        preferences.delimiter = '\t'
        TkUtils.set_entry_value(delimiter_entry,  "s1111111\t100")
      }

      # 区切り文字の読み込み
      case delimiter.value
      when ',  '
        delimiter_var.value = 0
        @comma_radio.select
        @comma_radio.invoke
      when '\t'
        delimiter_var.value = 1
        @tab_radio.select
        @tab_radio.invoke
      else
        delimiter_var.value = 2
        if !@delimiter.nil? then
          any_delimiter.value = @delimiter
          @any_radio.select
          @any_radio.invoke
        else
          delimiter_var.value = 0
          @comma_radio.select
          @comma_radio.invoke
        end
      end

    end

    def pack()
      @label.pack({side: 'top',  anchor: 'w',  padx: 10,  pady: 10})
      @frame.pack({side: 'top'})
      @comma_radio.pack(side: 'left')
      @tab_radio.pack(side: 'left',  padx: 5)
      @any_radio.pack(side: 'left',  padx: 5)
      @entry.pack(side: 'left',  padx: 3)
      @preview_entry.pack(side: 'top',  pady: 10)
      @button.pack({side: 'left', padx: 15})
    end

    def save_value()

      changed
      notify_observers(value)
    end
  end
end
