# -*- coding: utf-8 -*-
require 'tk'
require 'singleton'

class CommandSelect
  include Singleton

  attr_accessor :target_files, :compile_command, :execute_command

  def launch(button)
    if @init_flag.nil? then
      @target_files = Array.new
      @tmp_arr = Array.new
      @init_flag = true
    else
      @tmp_arr = Marshal.load(Marshal.dump(@target_files))
    end

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

      @filelist_box = TkListbox.new(filelist_frame){
        height 5
        width 25
        yscrollbar filelist_scrollbar
        pack side: 'left'
      }

      filelist_scrollbar.pack(side: 'right', fill: :y)

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

      add_button = TkButton.new(file_frame){
        text '追加'
        command proc{
          command_select = CommandSelect.instance
          command_select.add_filelist()
        }
        pack({side: 'left', padx: 10})
      }

      delete_button = TkButton.new(file_frame){
        text '削除'
        command proc{
          command_select = CommandSelect.instance
          command_select.delete_filelist()
        }
        pack({side: 'left', padx: 5})
      }

      # コンパイルコマンド
      TkLabel.new(dialog){
        text 'コンパイルコマンド :'
        pack({side: 'top', anchor: 'w', padx: 10, pady: 10})
      }

      @compile_entry = TkEntry.new(dialog){
        width 40
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
        pack({side: 'top'})
      }

      button_frame = TkFrame.new(dialog){
        pack(side: 'top', pady: 5)
      }

      ok_button = TkButton.new(button_frame){
        text 'OK'
        pack(side: 'left')
      }
      ok_button.command(
        proc{
          command_select = CommandSelect.instance
          command_select.save_command()
          @dialog.close
        }
      )

      cancel_button = TkButton.new(button_frame){
        text 'キャンセル'
        pack(side: 'left', padx: 15)
      }
      cancel_button.command(
        proc{
          @target_files = Marshal.load(Marshal.dump(@tmp_arr))
          @dialog.close
        }
      )

      set_values()
    }
    @dialog.launch
  end

  def set_values()
    set_filelist()
    set_command()
  end

  def set_filelist()
    @filelist_box.clear()
    if !@target_files.nil? then
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

  def set_command()
    @compile_entry.value = @compile_command if !@compile_command.nil?
    @execute_entry.value = execute_command if !@execute_command.nil?
  end

  def save_command()
    @compile_command = @compile_entry.value
    @execute_command = @execute_entry.value
    # 採点設定画面へコマンドの反映
    preferences = RatingPreferences.instance.set_command()
  end


end
