# -*- coding: utf-8 -*-
require 'tk'
require 'singleton'

class CommandSelect
  include Singleton

  def launch(button)
    @dialog = Dialog.new(button, '採点ファイルとコマンドの設定', 455, 490){
      dialog = @dialog.dialog

      # 採点ファイルリスト
      TkLabel.new(dialog){
        text '採点ファイルリスト:'
        pack({side: 'top', anchor: 'w', padx: 10, pady: 10})
      }

      filelist_frame = TkFrame.new(dialog){
        pack({side: 'top', pady: 5})
      }

      filelist_scrollbar = TkScrollbar.new(filelist_frame)

      filelist_box = TkListbox.new(filelist_frame){
        height 5
        width 25
        yscrollbar filelist_scrollbar
        pack side: 'left'
      }

      filelist_scrollbar.pack(side: 'right', fill: :y)

      # テストデータ
      filelist_box.insert('end',  '$id.c -> $1')
      filelist_box.insert('end',  '$id.h -> $2')
      filelist_box.insert('end',  'input -> $3')

      # ファイル名の追加
      TkLabel.new(dialog){
        text "※ 採点に必要なファイル名(ヘッダーファイル等)をすべて追加し、\n" +
              'ファイル名に学籍番号を使う場合は、$idとしてください。'
        pack({side: 'top', pady: 5})
      }

      file_frame = TkFrame.new(dialog){
        pack({side: 'top', pady: 10})
      }

      file_entry = TkEntry.new(file_frame){
        width 20
        pack({side: 'left'})
      }

      add_button = TkButton.new(file_frame){
        text '追加'
        command proc{puts 'hoge'}
        pack({side: 'left', padx: 10})
      }

      delete_button = TkButton.new(file_frame){
        text '削除'
        command proc{puts 'hoge'}
        pack({side: 'left', padx: 5})
      }

      # コンパイルコマンド
      TkLabel.new(dialog){
        text 'コンパイルコマンド :'
        pack({side: 'top', anchor: 'w', padx: 10, pady: 10})
      }

      compile_entry = TkEntry.new(dialog){
        width 40
        pack({side: 'top'})
      }

      TkLabel.new(dialog){
        text '※ ファイル名には、変数($1, $2...)を使用してください。'
        pack({side: 'top'})
      }

      # 実行コマンド
      TkLabel.new(dialog){
        text '実行コマンド :'
        pack({side: 'top', anchor: 'w', padx: 10, pady: 10})
      }

      execute_entry = TkEntry.new(dialog){
        width 40
        pack({side: 'top'})
      }

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
