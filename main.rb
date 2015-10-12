# -*- coding: utf-8 -*-
require 'tk'
require 'singleton'
require_relative 'rating'

class MainWindow
  include Singleton

  # MainWindowの起動
  def launch
    root = TkRoot.new{
      title 'Rating Aizu'
      resizable [0, 0]
      geometry '820x540+150+150'

    }

    # 設定ボタン + 警告ラベル
    top_frame = TkFrame.new{
      pack({side: 'top', pady: 15})
    }


    preferences_button = TkButton.new(top_frame){
      text '設定'
      pack side: 'left'
    }

    wait_var = TkVariable.new

    preferences = open_preferences(preferences_button, wait_var)
    preferences_button.command{
      # grabで画面をロックする。
      preferences.deiconify
      preferences.set_grab
      # waitでデータ入力を待つ。
      wait_var.tkwait
      # grabを解除し画面を解放する。
      preferences.release_grab
      preferences.withdraw
    }

    preferences_label = TkLabel.new(top_frame){
      text '採点の設定を行ってください。'
      foreground 'red'
      pack({side: 'left', padx: 20})
    }

    bottom_frame = TkFrame.new{
      pack({side: 'left', pady: 15})
    }

    # ==== 画面左 ====
    bottom_left_frame = TkFrame.new(bottom_frame){
      pack({side: 'left', padx: 10})
    }

    # メーリングリスト・成績一覧
    TkLabel.new(bottom_left_frame){
      text '学生・成績 一覧'
      pack side: 'top'
    }

    mail_frame = TkFrame.new(bottom_left_frame){
      pack({side: 'top', pady: 15})
    }

    mail_scrollbar = TkScrollbar.new(mail_frame)

    mailing_list_box = TkListbox.new(mail_frame){
      height 12
      yscrollbar mail_scrollbar
      pack side: 'left'
    }

    mail_scrollbar.pack(side: 'right', fill: :y)

    (0..300).each{ |n|
      mailing_list_box.insert('end',  "item #{n}")
    }

    score_frame = TkFrame.new(bottom_left_frame){
      pack({side: 'top', pady: 15})
    }

    # 点数
    TkLabel.new(score_frame){
      text '点数'
      pack({side: 'left'})
    }

    score_entry = TkEntry.new(score_frame){
      width 5
      bind 'Return', proc{
        mailing_list_box.focus
      }
      pack({side: 'left', padx: 25})
    }

    mailing_list_box.bind 'Return', proc{
      score_entry.focus
      score_entry.selection_range(0, score_entry.value.size)
    }

    # ショートカット
    TkLabel.new(bottom_left_frame){
      text 'ショートカット'
      pack({side: 'top'})
    }

    shortcut_frame1 = TkFrame.new(bottom_left_frame){
      pack({side: 'top', pady: 5})
    }

    shortcut_frame2 = TkFrame.new(bottom_left_frame){
      pack({side: 'top', pady: 5})
    }

    shortcut_entries = []

    (1..4).each do |i|
      if i <= 2 then
        TkLabel.new(shortcut_frame1){
          text "F#{i}"
          pack({side: 'left', padx: 10})
        }
        shortcut_entry = TkEntry.new(shortcut_frame1){
          width 5
          pack({side: 'left', padx: 5})
        }
        shortcut_entries.push(shortcut_entry)
      else
        TkLabel.new(shortcut_frame2){
          text "F#{i}"
          pack({side: 'left', padx: 10})
        }
        shortcut_entry = TkEntry.new(shortcut_frame2){
          width 5
          pack({side: 'left', padx: 5})
        }
        shortcut_entries.push(shortcut_entry)
      end
    end

    # ==== 画面中央 ====
    bottom_center_frame = TkFrame.new(bottom_frame){
      pack({side: 'left',  padx: 10})
    }

    # ==== ソースコード表示 ====
    combobox_var = TkVariable.new

    file_combobox = TkCombobox.new(bottom_center_frame){
      state 'readonly'
      textvariable combobox_var
      pack({side: 'top'})
    }

    combobox_var.trace("w", proc{ puts file_combobox.current })

    file_combobox.values = ['hoge.c', 'hoge.h', 'in','out']
    file_combobox.current = 0

    source_textsc = TkTextWithScrollbar.new(bottom_center_frame, 35, 24)
    source_text = source_textsc.tk_text
    source_textsc.pack

    # ==== 画面右 ====
    bottom_right_frame = TkFrame.new(bottom_frame){
      pack({side: 'left',  padx: 10})
    }

    # ==== コンパイル・実行 結果 ====
    TkLabel.new(bottom_right_frame){
      text 'コンパイル結果'
      pack({side: 'top'})
    }

    compile_textsc = TkTextWithScrollbar.new(bottom_right_frame, 35, 5)
    compile_text = compile_textsc.tk_text
    compile_textsc.pack

    TkLabel.new(bottom_right_frame){
      text '実行結果'
      pack({side: 'top'})
    }

    execute_textsc = TkTextWithScrollbar.new(bottom_right_frame, 35, 15)
    execute_text = execute_textsc.tk_text
    execute_textsc.pack

    Tk.mainloop
  end
end

def open_preferences(button, var)
    top = TkToplevel.new(button).withdraw
    TkButton.new(top){
      text 'close'
      command proc{top.withdraw; var.value = 1}
      pack
    }
    top
end

class TkTextWithScrollbar
  attr_accessor :tk_text

  def initialize(parent_frame, width, height)
    @frame = TkFrame.new(parent_frame)

    @tk_text = TkText.new(@frame){
      width width
      height height
      yscrollbar @scrollbar
    }

    @scrollbar = TkScrollbar.new(@frame)
  end

  def pack
    @frame.pack({side: 'top', pady: 15})
    @tk_text.pack({'side' => 'left'})
    @scrollbar.pack({side: 'right', fill: :y})
  end
end

MainWindow.instance.launch

