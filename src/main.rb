# -*- coding: utf-8 -*-
require 'singleton'
require_relative 'model/preferences'
require_relative 'model/prefs_mediator'
require_relative 'model/user'
require_relative 'model/rating'

module Model
  class MainWindow
    include Singleton
    attr_reader :user_repo, :manager

    def launch
      # 設定準備
      @mediator = PreferencesMediator.instance
      @manager = RatingManager.instance
      Model::Preferences.new
      require_relative 'view/main_window'
      View::MainWindow.instance.launch
    end

    # メーリングリストからユーザリポジトリを生成
    def create_user_repo(file_path)
      arr = FileUtil.open_mailinglist(file_path)
      if @user_repo.nil? then
        @user_repo = UserRepository.new(arr)
      else
        if arr != @user_repo.get_userslist then
          @user_repo = UserRepository.new(arr)
        end
      end
      @user_repo
    end

    def update_user!(user)
      @user_repo.update_user!(user)
      save_score()
    end

    def save_score()
      result_file = @mediator.prefs[:result_file].value
      delimiter = @mediator.prefs[:delimiter].value

      if !result_file.nil?
        File.open(result_file, 'w') do |file|
          @user_repo.users.each do |user|
            file.puts(user.to_s(delimiter))
          end
        end
      end
    end

    def set_rating(prefs)
      command_select = prefs[:command_select].value

      compile_command = command_select[:compile_command]
      execute_command = command_select[:execute_command]

      target_files = command_select[:target_files]
      target_files.each_with_index do |file, index|
        compile_command.gsub!("$#{index}", file)
        execute_command.gsub!("$#{index}", file)
      end

      @manager.set_rating(prefs[:mailinglist].value, prefs[:rating_dir].value,
                          target_files, compile_command, execute_command,
                          prefs[:input].value)
    end
  end
end

Model::MainWindow.instance.launch
