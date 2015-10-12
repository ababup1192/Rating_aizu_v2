# -*- coding: utf-8 -*-
require 'tk'
require 'singleton'
require_relative 'tkextension'

class RatingPreferences
  include Singleton

  def launch(button)
    @dialog = Dialog.new(button, '採点設定', 470, 590){
      dialog = @dialog.dialog

      # メーリングリストパス設定
      TkLabel.new(dialog){
        text '"メーリングリスト"の場所:'
        pack({side: 'top', anchor: 'w', padx: 10, pady: 15})
      }

      ml_path_frame = TkFrame.new(dialog){
        pack({side: 'top'})
      }

      ml_path_entry = TkEntry.new(ml_path_frame){
        width 40
        pack({side: 'left'})
      }

      ml_path_button = TkButton.new(ml_path_frame){
        text '変更'
        command proc{puts 'hoge'}
        pack({side: 'left', padx: 15})
      }

      # 採点対象ディレクトリ設定
      TkLabel.new(dialog){
        text '"採点対象"ディレクトリの場所:'
        pack({side: 'top', anchor: 'w', padx: 10, pady: 10})
      }

      rating_path_frame = TkFrame.new(dialog){
        pack({side: 'top', pady: 10})
      }

      rating_path_entry = TkEntry.new(rating_path_frame){
        width 40
        pack({side: 'left'})
      }

      rating_path_button = TkButton.new(rating_path_frame){
        text '変更'
        command proc{puts 'hoge'}
        pack({side: 'left', padx: 15})
      }

      # コマンドプレビュー
      TkLabel.new(dialog){
        text 'コマンドプレビュー:'
        pack({side: 'top', anchor: 'w', padx: 10, pady: 10})
      }

      command_frame = TkFrame.new(dialog){
        pack({side: 'top', pady: 10})
      }

      compile_command_entry = TkEntry.new(command_frame){
        width 40
        pack({side: 'left'})
      }

      execute_command_entry = TkEntry.new(dialog){
        width 40
        pack({side: 'top', anchor: 'w', padx: 27})
      }

      rating_path_button = TkButton.new(command_frame){
        text '変更'
        command proc{puts 'hoge'}
        pack({side: 'left', padx: 15})
      }

      # 入力データ
      TkLabel.new(dialog){
        text '入力データ:'
        pack({side: 'top', anchor: 'w', padx: 10, pady: 10})
      }

      input_button = TkButton.new(dialog){
        text '変更'
        command proc{puts 'hoge'}
        pack({side: 'top', anchor: 'w', padx: 20})
      }

      # 成績ファイル
      TkLabel.new(dialog){
        text '成績ファイル:'
        pack({side: 'top', anchor: 'w', padx: 10, pady: 10})
      }

      result_path_frame = TkFrame.new(dialog){
        pack({side: 'top'})
      }

      result_entry = TkEntry.new(result_path_frame){
        width 40
        pack({side: 'left'})
      }

      result_path_button = TkButton.new(result_path_frame){
        text '変更'
        command proc{puts 'hoge'}
        pack({side: 'left', padx: 15})
      }

      # 区切り文字
      TkLabel.new(dialog){
        text '区切り文字:'
        pack({side: 'top', anchor: 'w', padx: 10, pady: 10})
      }

      delimiter = TkVariable.new

      delimiter_frame = TkFrame.new(dialog){
        pack(side: 'top')
      }

      comma_radio = TkRadioButton.new(delimiter_frame) {
        text 'カンマ'
        value 0
        variable delimiter
        pack(side: 'left')
      }

      tab_radio = TkRadioButton.new(delimiter_frame) {
        text 'タブ'
        value 1
        variable delimiter
        command proc{puts 'hoge'}
        pack(side: 'left', padx: 5)
      }

      TkRadioButton.new(delimiter_frame) {
        text '任意の文字'
        value 2
        variable delimiter
        command proc{puts 'hoge'}
        pack(side: 'left', padx: 5)
      }

      any_delimiter = TkEntry.new(delimiter_frame){
        width 2
        pack(side: 'left', padx: 3)
      }

      delimiter_entry = TkEntry.new(dialog){
        width 30
        state 'readonly'
        pack(side: 'top', pady: 10)
      }

      comma_radio.command proc{
        delimiter_entry.state = 'normal'
        delimiter_entry.value = 's1111111, 100'
        delimiter_entry.state = 'readonly'
      }
      tab_radio.command proc{
        delimiter_entry.state = 'normal'
        delimiter_entry.value = "s1111111\t100"
        delimiter_entry.state = 'readonly'
      }
      comma_radio.select
      comma_radio.invoke

      button_frame = TkFrame.new(dialog){
        pack(side: 'top', pady: 5)
      }

      ok_button = TkButton.new(button_frame){
        text 'OK'
        pack(side: 'left')
      }
      ok_button.command(@dialog.method(:close))

      cancel_button = TkButton.new(button_frame){
        text 'キャンセル'
        pack(side: 'left', padx: 15)
      }
      cancel_button.command(@dialog.method(:close))

    }
    @dialog.launch
  end

end
