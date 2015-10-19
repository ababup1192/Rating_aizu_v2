# -*- coding: utf-8 -*-
require 'tk'
require 'singleton'
require_relative 'util/tkextension'
require_relative 'model/user'
require_relative 'model/prefs_mediator'
require_relative 'model/preferences'
require_relative 'view/preferences'

class MainWindow
  include Singleton

  attr_accessor :user_repo

  # MainWindowの起動
  def launch
    @prefs = Preferences.new
    @mediator = PreferencesMediator.instance
    # @mediator.load_prefs(@prefs)

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

    preferences_button.command(
      proc{
        View::Preferences.new(preferences_button, @prefs).launch()
      }
    )

    label_text = "採点の設定を行ってください。\n" +
                     @mediator.get_notset_prefs_name.join(', ')
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
        main_window.clear_result()
        main_window.set_score()
        main_window.set_filebox()
        main_window.mark_next()
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

    @shortcut_entries = []

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
        @shortcut_entries.push(shortcut_entry)
      else
        TkLabel.new(shortcut_frame2){
          text "F#{i}"
          pack({side: 'left', padx: 10})
        }
        shortcut_entry = TkEntry.new(shortcut_frame2){
          width 5
          pack({side: 'left', padx: 5})
        }
        @shortcut_entries.push(shortcut_entry)
      end
    end

    @mailing_list_box.bind('Key', self.method(:push_shortcut))

    # ==== 画面中央 ====
    bottom_center_frame = TkFrame.new(bottom_frame){
      pack({side: 'left',  padx: 10})
    }

    # ==== ソースコード表示 ====
    combobox_var = TkVariable.new

    @file_combobox = TkCombobox.new(bottom_center_frame){
      textvariable combobox_var
      state 'readonly'
      pack({side: 'top'})
    }

    combobox_var.trace("w", proc{
      set_source_text()
    })

    set_filebox()

    @source_textsc = TkTextWithScrollbar.new(bottom_center_frame, 35, 24)
    source_text = @source_textsc.tk_text
    source_text.state = 'disabled'
    @source_textsc.pack

    # ==== 画面右 ====
    bottom_right_frame = TkFrame.new(bottom_frame){
      pack({side: 'left',  padx: 10})
    }

    # ==== コンパイル・実行 結果 ====
    TkLabel.new(bottom_right_frame){
      text 'コンパイル結果'
      pack({side: 'top'})
    }

    @compile_textsc = TkTextWithScrollbar.new(bottom_right_frame, 35, 5)
    compile_text = @compile_textsc.tk_text
    compile_text.state = 'disabled'
    @compile_textsc.pack

    TkLabel.new(bottom_right_frame){
      text '実行結果'
      pack({side: 'top'})
    }

    @execute_textsc = TkTextWithScrollbar.new(bottom_right_frame, 35, 15)
    execute_text = @execute_textsc.tk_text
    execute_text.state = 'disabled'
    @execute_textsc.pack

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

  def clear_result()
    compile_text = @compile_textsc.tk_text
    execute_text = @execute_textsc.tk_text

    TkUtils.set_text_value(compile_text, '')
    TkUtils.set_text_value(execute_text, '')
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

  def rating?
    get_rating_preparation.empty?
  end

  def set_rating_label()
    if rating? then
     @preferences_label.foreground = 'blue'
     @preferences_label.text = '採点準備完了'
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

  def update_score(score = nil)
    if !@cur_index.nil?
      user = @user_repo.users[@cur_index]
      if score.nil? then
        @user_repo.update_user!(User.new(user.id, @score_entry.value))
      else
        @user_repo.update_user!(User.new(user.id, score))
      end

      update_users()
      @mailing_list_box.selection_set(@cur_index)
      @mailing_list_box.focus
      @mailing_list_box.activate(@cur_index)
      save_score()
    end
  end

  def push_shortcut(e)
    case e.keycode
    when 67,   8058628
      update_score(@shortcut_entries[0].value.to_i)
    when 68,   7927557
      update_score(@shortcut_entries[1].value.to_i)
    when 69,   6551302
      update_score(@shortcut_entries[2].value.to_i)
    when 70,   7796487
      update_score(@shortcut_entries[3].value.to_i)
    when 8124162
      target_files = @command_select.target_files
      if !target_files.nil? then
        @file_combobox.current =
          (@file_combobox.current - 1) % target_files.length
      end
    when 8189699
      target_files = @command_select.target_files
      if !target_files.nil? then
        @file_combobox.current =
          (@file_combobox.current + 1) % target_files.length
      end
    end
  end

  def save_score()
    if rating? then
      File.open(@preferences.result_path, 'w') do |file|
        @user_repo.users.each do |user|
          file.puts(user.to_s(@preferences.delimiter))
        end
      end
    end
  end

  def set_filebox()
=begin
    target_files = Marshal.load(Marshal.dump(@command_select.target_files))
    if !target_files.nil? then
      user = @user_repo.users[@cur_index]
      target_files.map! do |file|
        file.gsub('$id', user.id)
      end

      @file_combobox.values = target_files
      @file_combobox.current = 0
    else
      @file_combobox.values = []
    end
=end
  end

  def set_source_text()
   source_text = @source_textsc.tk_text
   if !@preferences.rating_path.nil? then
      file_path = @preferences.rating_path + '/' +
        @file_combobox.values[@file_combobox.current]
      begin
        File.open(file_path) do |file|
          TkUtils.set_text_value(source_text, file.read)
        end
      rescue IOError => e
        TkUtils.set_errtext(source_text, e.message)
      rescue Errno::ENOENT => e
        TkUtils.set_errtext(source_text, e.message)
      rescue Errno::EISDIR => e
        TkUtils.set_errtext(source_text, e.message)
      end
   else
     TkUtils.set_errtext(source_text, 'ファイルがありません。')
   end
  end

  def set_rating()
    if get_rating_preparation().empty? then
      target_files = @command_select.target_files
      compile_command = @command_select.compile_command
      execute_command = @command_select.execute_command

      target_files.each_with_index do |file, index|
        compile_command.gsub!("$#{index}", file)
        execute_command.gsub!("$#{index}", file)
      end
      @manager.set_rating(@preferences.ml_path, @preferences.rating_path,
                          target_files, compile_command, execute_command,
                          @input.value)
    end
  end

  def mark_next()
    if get_rating_preparation().empty? then
      user = @user_repo.users[@cur_index]
      @manager.mark_next(user.id)
    end
  end

  def set_compile_result(result)
    compile_text = @compile_textsc.tk_text
    TkUtils.set_text_value(compile_text, result)
  end

  def set_compile_err(result)
    compile_text = @compile_textsc.tk_text
    TkUtils.set_errtext(compile_text, result)
  end

  def set_execute_result(result)
    execute_text = @execute_textsc.tk_text
    TkUtils.set_text_value(execute_text, result)
  end

  def set_execute_err(result)
    execute_text = @execute_textsc.tk_text
    TkUtils.set_errtext(execute_text, result)
  end

  def launch_preferences()
  end

end

MainWindow.instance.launch

