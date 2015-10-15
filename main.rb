# -*- coding: utf-8 -*-
require 'tk'
require 'singleton'
require_relative 'user'
require_relative 'preferences'
require_relative 'command_select'
require_relative 'rating'
require_relative 'input'

class MainWindow
  include Singleton

  attr_accessor :user_repo

  # MainWindowの起動
  def launch
    if !@init_flag then
      @preferences = RatingPreferences.instance
      @command_select = CommandSelect.instance
      @input = Input.instance
      @init_flag = true
    end

    root = TkRoot.new{
      title 'Rating Aizu'
      resizable [0, 0]
      geometry '820x580+150+150'
    }

    # 設定ボタン + 警告ラベル
    top_frame = TkFrame.new{
      pack({side: 'top', pady: 15})
    }

    preferences_button = TkButton.new(top_frame){
      text '設定'
      pack side: 'top'
    }
    preferences = RatingPreferences.instance
    preferences_button.command(
      proc{preferences.launch(preferences_button)}
    )

    label_text = "採点の設定を行ってください。\n" +
                     get_rating_preparation.to_s
    @preferences_label = TkLabel.new(top_frame){
      text label_text
      foreground 'red'
      pack({side: 'top', padx: 20})
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


    @mailing_list_box = TkListbox.new(mail_frame){
      height 12
      yscrollbar mail_scrollbar
      bind '<ListboxSelect>', proc {
        main_window = MainWindow.instance
        main_window.set_score()
        main_window.set_filebox()
      }
      pack side: 'left'
    }

    mail_scrollbar.pack(side: 'right', fill: :y)

    score_frame = TkFrame.new(bottom_left_frame){
      pack({side: 'top', pady: 15})
    }

    # 点数
    TkLabel.new(score_frame){
      text '点数'
      pack({side: 'left'})
    }

    @score_entry = TkEntry.new(score_frame){
      width 5
      bind 'Return', proc{
        main_window = MainWindow.instance
        main_window.update_score()
      }
      pack({side: 'left', padx: 25})
    }

    @mailing_list_box.bind 'Return', proc{
      @score_entry.focus
      @score_entry.selection_range(0, 'end')
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

    @file_combobox = TkCombobox.new(bottom_center_frame){
      textvariable combobox_var
      pack({side: 'top'})
    }

    combobox_var.trace("w", proc{
      puts @file_combobox.current
    })

    set_filebox()

    source_textsc = TkTextWithScrollbar.new(bottom_center_frame, 35, 24)
    source_text = source_textsc.tk_text
    source_text.state = 'disabled'
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
    compile_text.state = 'disabled'
    compile_textsc.pack

    TkLabel.new(bottom_right_frame){
      text '実行結果'
      pack({side: 'top'})
    }

    execute_textsc = TkTextWithScrollbar.new(bottom_right_frame, 35, 15)
    execute_text = execute_textsc.tk_text
    execute_text.state = 'disabled'
    execute_textsc.pack

    Tk.mainloop
  end

  def set_mailing_list_box(ml_path)
    arr = []
    if !ml_path.nil? then
      File.open(ml_path) do |file|
        file.each_line do |line|
          line =~ /^(\w\d+)$/
          if !$1.nil?
            arr << $1
          end
        end
      end
      if arr != @ml
        @user_repo = UserRepository.new(arr)
        @ml = arr

        # 学生・成績 一覧に反映
        @user_repo.users.each do |user|
          @mailing_list_box.insert('end', user)
        end

      end
    end
  end

  def update_users()
    @mailing_list_box.clear
    @user_repo.users.each do |user|
      @mailing_list_box.insert('end', user)
    end
  end

  def get_rating_preparation
    items = ['メーリングリスト', '採点対象ディレクトリ',
             '採点対象ファイル', 'コンパイルコマンド', '実行コマンド',
             '成績ファイル']
    if !@preferences.ml_path.nil? then
      items.delete_if {|item| item == 'メーリングリスト'}
    end
    if !@preferences.rating_path.nil? then
      items.delete_if {|item| item == '採点対象ディレクトリ'}
    end
    if !@command_select.target_files.nil? then
      items.delete_if {|item| item == '採点対象ファイル'}
    end
    if !@command_select.compile_command.nil? then
      if !@command_select.compile_command.empty? then
        items.delete_if {|item| item == 'コンパイルコマンド'}
      end
    end
    if !@command_select.execute_command.nil?
      if !@command_select.execute_command.empty? then
        items.delete_if {|item| item == '実行コマンド'}
      end
    end
    if !@preferences.result_path.nil?
      items.delete_if {|item| item == '成績ファイル'}
    end
    items
  end

  def set_rating_label()
    items = get_rating_preparation
    if items.empty? then
     @preferences_label.text = ''
    else
     label_text = "採点の設定を行ってください。\n" +
                     get_rating_preparation.to_s
     @preferences_label.text = label_text
    end
  end

  def set_score()
    if !@user_repo.nil? then
      @cur_index = @mailing_list_box.curselection[0]
      user = @user_repo.users[@cur_index]
      @score_entry.value = user.score
    end
  end

  def update_score()
    if !@cur_index.nil?
      user = @user_repo.users[@cur_index]
      @user_repo.update_user!(User.new(user.id, @score_entry.value))
      update_users()
      @mailing_list_box.focus
    end
  end

  def set_filebox()
    target_files = Marshal.load(Marshal.dump(@command_select.target_files))
    if !target_files.nil? then
      user = @user_repo.users[@cur_index]
      target_files.map! do |file|
        file.gsub!('$id', user.id)
      end

      @file_combobox.values = target_files
      @file_combobox.current = 0
    else
      @file_combobox.values = []
    end
  end

end

MainWindow.instance.launch

