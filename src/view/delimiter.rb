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

      delimiter_var = TkVariable.new

      @comma_radio = TkRadioButton.new(@frame) {
        text 'カンマ'
        value 0
        variable delimiter_var
      }

      @tab_radio = TkRadioButton.new(@frame) {
        text 'タブ'
        value 1
        variable delimiter_var
      }

      @any_radio = TkRadioButton.new(@frame) {
        text '任意の文字'
        value 2
        variable delimiter_var
      }

      any_delimiter_var = TkVariable.new

      @delimiter_entry = TkEntry.new(@frame){
        width 2
        state 'readonly'
        textvariable any_delimiter_var
      }

      @preview_entry = TkEntry.new(dialog){
        width 30
        state 'readonly'
      }

      # 区切り文字が入力されたときの処理
      any_delimiter_var.trace('w',  proc{
        save_value(@delimiter_entry.value)
        TkUtils.set_entry_value(@preview_entry,
                                "s1111111#{@delimiter_entry.value}100")
      })

      # ラジオボタンが押されたときの処理
      delimiter_var.trace('w',  proc {
        # 任意の区切り文字を選択したとき
        if delimiter_var.value == '2' then
          @delimiter_entry.value = ''
          @delimiter_entry.state = 'normal'
        else
          @delimiter_entry.state = 'readonly'
        end
      })

      @comma_radio.command proc{
        save_value(',')
        TkUtils.set_entry_value(@preview_entry, "s1111111,100")
      }

      @tab_radio.command proc{
        save_value("\t")
        TkUtils.set_entry_value(@preview_entry, "s1111111\t100")
      }

      @any_radio.command proc{
        save_value(@delimiter_entry.value)
        TkUtils.set_entry_value(@preview_entry,
                                "s1111111#{@delimiter_entry.value}100")
      }

      # 区切り文字の読み込み
      case delimiter.value
      when ','
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
          @delimiter_entry.value = delimiter.value
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
      @delimiter_entry.pack(side: 'left',  padx: 3)
      @preview_entry.pack(side: 'top',  pady: 10)
    end

    def save_value(value)
      changed
      notify_observers(value)
    end
  end
end
