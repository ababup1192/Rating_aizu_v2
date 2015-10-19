# -*- coding: utf-8 -*-
require 'observer'
require 'tk'
require_relative '../util/tkextension'
require_relative 'mailinglist'
require_relative 'rating_dir'
require_relative 'command_select'
require_relative 'input'
require_relative 'result_file'
require_relative 'delimiter'

module View
  class Preferences
    include Observable

    def initialize(button, prefs)
      @prefs = prefs

      @dialog = Dialog.new(button, '採点設定', 470, 590){
        dialog = @dialog.dialog

        # メーリングリストパス設定
        View::Mailinglist.new(dialog, prefs.value[:mailinglist]).pack()

        # 採点対象ディレクトリ設定
        View::RatingDir.new(dialog, prefs.value[:rating_dir]).pack()

        # コマンドプレビュー
        TkLabel.new(dialog){
          text 'コマンドプレビュー:'
          pack({side: 'top', anchor: 'w', padx: 10, pady: 10})
        }

        command_frame = TkFrame.new(dialog){
          pack({side: 'top', pady: 10})
        }

        @compile_command_entry = TkEntry.new(command_frame){
          width 40
          text prefs.value[:command_select].value[:compile_command]
          state 'readonly'
          pack({side: 'left'})
        }

        @execute_command_entry = TkEntry.new(dialog){
          width 40
          text prefs.value[:command_select].value[:execute_command]
          state 'readonly'
          pack({side: 'top', anchor: 'w', padx: 27})
        }

        command_button = TkButton.new(command_frame){
          text '変更'
          pack({side: 'left', padx: 15})
        }

        command_button.command(
          proc{
            View::CommandSelect.new(self, command_button,
                                    prefs.value[:command_select]).launch()
          }
        )

        # 入力データ
        TkLabel.new(dialog){
          text '入力データ:'
          pack({side: 'top',  anchor: 'w',  padx: 10,  pady: 10})
        }

        input_button = TkButton.new(dialog){
          text '変更'
          pack({side: 'top',  anchor: 'w',  padx: 20})
        }

        input_button.command(proc{
          View::Input.new(input_button, prefs.value[:input]).launch()
        })

        # 成績ファイル
        View::RatingDir.new(dialog, prefs.value[:rating_dir]).pack()

        # 区切り文字
        View::Delimiter.new(dialog, prefs.value[:delimiter]).pack()

        button_frame = TkFrame.new(dialog){
          pack(side: 'top', pady: 5)
        }

        ok_button = TkButton.new(button_frame){
          text 'OK'
          pack(side: 'left')
        }
        ok_button.command(
          proc{
            main_window = MainWindow.instance
            main_window.set_rating_label()
            main_window.set_mailing_list_box(@ml_path)
            main_window.set_rating()
            @dialog.close
          }
        )

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

    def update(value)
      TkUtils.set_entry_value(@compile_command_entry, value[:compile_command])
      TkUtils.set_entry_value(@execute_command_entry, value[:execute_command])
    end
  end
end

