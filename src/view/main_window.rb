# -*- coding: utf-8 -*-
require 'singleton'
require 'observer'
require 'tk'
require_relative '../util/tkextension'
require_relative '../util/file_util'
require_relative '../model/prefs_mediator'
require_relative '../model/preferences'
require_relative 'preferences'

module View
  class MainWindow
    include Singleton
    include Observable
    attr_reader :compile_textsc, :execute_textsc

    def launch
      require_relative '../main'
      @mediator = PreferencesMediator.instance
      @main_window = Model::MainWindow.instance

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
          View::Preferences.new(preferences_button, Model::Preferences.new).launch()
        }
      )

      @preferences_label = TkLabel.new(top_frame){
        foreground 'red'
        pack({side: 'top', padx: 20})
      }
      set_preferences_label()

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
        pack side: 'left'
      }
      @mailing_list_box.bind '<ListboxSelect>',
        self.method(:select_mailinglist)

      @mailing_list_box.bind 'Return', proc{
        @score_entry.focus
        @score_entry.selection_range(0, 'end')
      }
      @mailing_list_box.bind('Key', self.method(:push_shortcut))

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
        pack({side: 'left', padx: 25})
      }
      @score_entry.bind 'Return', self.method(:update_score)

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

      # @mailing_list_box.bind('Key', self.method(:push_shortcut))

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

      @source_textsc = TkTextWithScrollbar.new(bottom_center_frame,
                                               35, 24, '', 'disabled')
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

      @compile_textsc = TkTextWithScrollbar.new(bottom_right_frame,
                                                35, 5, '', 'disabled')
      @compile_textsc.pack

      TkLabel.new(bottom_right_frame){
        text '実行結果'
        pack({side: 'top'})
      }

      @execute_textsc = TkTextWithScrollbar.new(bottom_right_frame,
                                                35, 15, '', 'disabled')
      @execute_textsc.pack

      Tk.mainloop
    end

    def set_preferences_label()
      if !@mediator.get_notset_prefs.empty? then
        @preferences_label.foreground = 'red'
        label_text = "採点の設定を行ってください。\n" +
          @mediator.get_notset_prefs_name.join(', ')
        @preferences_label.text = label_text
      else
        @preferences_label.foreground = 'blue'
        @preferences_label.text = '採点準備完了'
      end
    end

    def set_mailinglist(file_path = nil)
      @mailing_list_box.clear()

      # ユーザリポジトリ読み込み
      if !file_path.nil? then
          user_repo = @main_window.create_user_repo(file_path)
      else
          user_repo = @main_window.user_repo
      end

      if !user_repo.nil? then
        # 学生・成績 一覧に反映
        user_repo.users.each do |user|
          @mailing_list_box.insert('end', user)
        end
      end
    end

    def set_score()
      user_repo = @main_window.user_repo
      if !user_repo.nil?
        user = user_repo.users[@cur_index]
        @score_entry.value = user.score
      end
    end

    # 成績の更新
    def update_score(score)
      if !@cur_index.nil?
        user_repo = @main_window.user_repo
        user = user_repo.users[@cur_index]

        if score.is_a?(Integer) then
          @main_window.update_user!(User.new(user.id, score))
        else
          @main_window.update_user!(User.new(user.id, @score_entry.value.to_i))
        end

        set_mailinglist()
        @mailing_list_box.selection_set(@cur_index)
        @mailing_list_box.focus
        @mailing_list_box.activate(@cur_index)
      end
    end

    # 学生一覧でのショートカットキー
    def push_shortcut(e)
      if !@prefs.nil?
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
          target_files = Marshal.load(Marshal.dump(
            @prefs[:command_select].value[:target_files]))
          if !target_files.nil? then
            if !target_files.empty?
              @file_combobox.current =
                (@file_combobox.current - 1) % target_files.length
            end
          end
        when 8189699
          target_files = Marshal.load(Marshal.dump(
            @prefs[:command_select].value[:target_files]))
          if !target_files.nil? then
            if !target_files.empty? then
              @file_combobox.current =
                (@file_combobox.current + 1) % target_files.length
            end
          end
        end
      end
    end

    # ファイルのコンボボックス読み込み
    def set_filebox()
      target_files = Marshal.load(Marshal.dump(
        @prefs[:command_select].value[:target_files]))

      if !target_files.nil? && !target_files.empty? then
        user_repo = @main_window.user_repo
        user = user_repo.users[@cur_index]
        target_files.map! do |file|
          file.gsub('$id', user.id)
        end

        @file_combobox.values = target_files
        @file_combobox.current = 0
      else
        @file_combobox.values = []
      end
    end

    # ソースコードの読み込み
    def set_source_text()
      rating_dir = @prefs[:rating_dir].value

      if !rating_dir.nil? then
        file_path = rating_dir + '/' + @file_combobox.values[@file_combobox.current]
        std_hash = FileUtil.open_file(file_path)
        if std_hash.has_key?(:stdout) then
          @source_textsc.set_text(std_hash[:stdout])
        else
          @source_textsc.set_text(std_hash[:stderr])
        end
      end
    end

    def mark_next()
      user = @main_window.user_repo.users[@cur_index]
      @main_window.manager.mark_next(user.id)
    end

    def select_mailinglist()
      if !@prefs.nil? then
        @cur_index = @mailing_list_box.curselection[0]
        set_score()
        set_filebox()
        set_source_text()
        @compile_textsc.set_text('')
        @execute_textsc.set_text('')
        if @mediator.rating? then
          mark_next()
        end
      end
    end

    def update(prefs)
      @prefs = prefs

      # 設定ラベル
      set_preferences_label()

      # メーリングリスト
      mailinglist_path = prefs[:mailinglist].value
      set_mailinglist(mailinglist_path)

      if @mediator.rating? then
        @main_window.set_rating(prefs)
      end
    end

  end
end
