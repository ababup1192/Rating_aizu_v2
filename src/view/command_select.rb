# -*- coding: utf-8 -*-
require 'observer'
require 'tk'
require_relative '../util/tkextension'

module View
  class CommandSelect
    include Observable

    def initialize(button, command_select)
      @dialog = Dialog.new(button, '採点ファイルとコマンドの設定', 455, 490){
        dialog = @dialog.dialog
        @target_files = command_select.value[:target_files]
        compile_command = command_select.value[:compile_command]
        execute_command = command_select.value[:execute_command]

        # 採点ファイルリスト
        TkLabel.new(dialog){
          text '採点ファイルリスト:'
          pack({side: 'top', anchor: 'w', padx: 10, pady: 10})
        }

        filelist_frame = TkFrame.new(dialog){
          pack({side: 'top', pady: 5})
        }

        filelist_scrollbar = TkScrollbar.new(filelist_frame)

        @filelist_box = TkListbox.new(filelist_frame){
          height 5
          width 25
          yscrollbar filelist_scrollbar
          pack side: 'left'
        }
        filelist_scrollbar.pack(side: 'right', fill: :y)
        set_filelist()

        # ファイル名の追加
        TkLabel.new(dialog){
          text "※ 採点に必要なファイル名(ヘッダーファイル等)をすべて追加し、\n" +
          'ファイル名に学籍番号を使う場合は、$idとしてください。'
          pack({side: 'top', pady: 5})
        }

        file_frame = TkFrame.new(dialog){
          pack({side: 'top', pady: 10})
        }

        @file_entry = TkEntry.new(file_frame){
          width 20
          pack({side: 'left'})
        }
        @file_entry.bind 'Return', self.method(:add_filist)

        add_button = TkButton.new(file_frame){
          text '追加'
          pack({side: 'left', padx: 10})
        }
        add_button.command(self.method(:add_filelist))

        delete_button = TkButton.new(file_frame){
          text '削除'
          pack({side: 'left', padx: 5})
        }
        delete_button.command(self.method(:delete_filelist))

        # コンパイルコマンド
        TkLabel.new(dialog){
          text 'コンパイルコマンド :'
          pack({side: 'top', anchor: 'w', padx: 10, pady: 10})
        }

        @compile_entry = TkEntry.new(dialog){
          width 40
          text compile_command
          pack({side: 'top'})
        }

        TkLabel.new(dialog){
          text '※ ファイル名には、変数($0, $1...)を使用してください。'
          pack({side: 'top'})
        }

        # 実行コマンド
        TkLabel.new(dialog){
          text '実行コマンド :'
          pack({side: 'top', anchor: 'w', padx: 10, pady: 10})
        }

        @execute_entry = TkEntry.new(dialog){
          width 40
          text execute_command
          pack({side: 'top'})
        }

        button_frame = TkFrame.new(dialog){
          pack(side: 'top', pady: 5)
        }

        ok_button = TkButton.new(button_frame){
          text 'OK'
          pack(side: 'left')
        }
        ok_button.command(self.method(:save_value))

        cancel_button = TkButton.new(button_frame){
          text 'キャンセル'
          command proc{ @dialog.close }
          pack(side: 'left', padx: 15)
        }
      }
    end

    def launch()
      @dialog.launch()
    end

    def save_value()
      changed
      notify_observers({target_files: @target_files,
                        compile_command: @compile_entry.value,
                        execute_command: @execute_entry.value})
      @dialog.close
    end

    def set_filelist()
      @filelist_box.clear()
      if @target_files.nil? then
        @target_files.each_with_index do |file, i|
          @filelist_box.insert('end', "#{file} -> $#{i}")
        end
      end
    end

    def add_filelist()
      value = @file_entry.value.strip
      @file_entry.value = ""
      if !value.empty? then
        @target_files << value
      end
      set_filelist()
    end

    def delete_filelist()
      @filelist_box.curselection.each do |cur|
        @target_files.delete_at(cur)
      end
      set_filelist()
    end
  end
end
