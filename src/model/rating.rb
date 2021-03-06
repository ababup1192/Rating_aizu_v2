# -*- coding: utf-8 -*-
require 'singleton'
require 'securerandom'
require_relative 'command'
require_relative 'user'

class RatingManager
  include Singleton

  attr_accessor :user_repo, :target_files, :compile_command,
    :execute_command, :current_rating, :input


  # 採点の初期設定を行う
  # @param [String] mailing_list_path メーリングリストのファイルパス
  # @param [String] target_dir 採点対象のディレクトリパス
  # @param [Array<String>] target_files 採点対象のファイル
  # @param [String] compile_command コンパイルコマンド
  # @param [String] execute_command 実行コマンド
  def set_rating(mailing_list_path, target_dir, target_files,
                 compile_command, execute_command, input = nil)
    mailing_list = read_mailing_list(mailing_list_path)
    @user_repo = UserRepository.new(mailing_list)
    @target_files = target_files.map{ |file| target_dir + '/' + file }
    @compile_command = compile_command
    @execute_command = execute_command
    @current_rating = nil
    @input = input
  end

  # メーリングリストを読み込み
  # @param [String] path メーリングリストのパス
  # @return [Array<String>] メーリングリスト(配列)
  def read_mailing_list(path)
      mailing_list = Array.new
      File.open(path) do |file|
        file.each_line do | line |
          # 学籍番号以外を弾くための正規表現
          if (line =~ /^(\w\d*)(.?)(\d*$)/) == 0 then
            mailing_list.push($1)
          end
        end
      end
      mailing_list
  end

  private :read_mailing_list

  # 次の採点対象を決める
  # @param [String] user_id ユーザID(学籍番号)
  def mark_next(user_id)
    # もし前の採点が続いているなら終了する。
    if @current_rating != nil then
      @current_rating.exit
    end

    @current_rating = Rating.new(user_id, @target_files)
    @current_rating.execute
  end

  # 点数を付ける
  # @param [Integer] point 点数
  def mark(point)
    user = @user_repo.find_user(@current_rating.user_id)
    user.point = point
    @user_repo.update_user!(user)
  end

  # 現在の採点を終了する
  def exit
    @current_rating.exit
  end
end

# 対象となるファイルをコピーし、コンパイル・実行・採点を行う
class Rating

  attr_accessor :user_id

  # 採点に必要な情報の初期化
  # @param [String] user_id ユーザID(学籍番号)
  # @param [Array<String>] target_files コピー対象のファイル名
  def initialize(user_id, target_files)
    @user_id = user_id
    @uuid = SecureRandom.uuid
    @input_flag = false

    # 採点対象ファイル、コマンドにユーザIDが使われている場合は置換する。
    @target_files = target_files.map do |file|
      file.gsub('$id', @user_id)
    end
    manager = RatingManager.instance
    @compile_command = manager.compile_command.gsub('$id', @user_id)
    @execute_command = manager.execute_command.gsub('$id', @user_id)
    @execute_dir = '/tmp/rating-aizu/' + @uuid
    copy_targetfiles()
    add_inputfile()
  end

  # 採点対象ファイルを実行ディレクトリへコピーする
  def copy_targetfiles()
    begin
      FileUtils.mkdir_p(@execute_dir)
      FileUtils.cp(@target_files, @execute_dir)
    rescue Errno::ENOENT => e
    end
  end
  private :copy_targetfiles

  def add_inputfile()
    manager = RatingManager.instance
    if !manager.input.nil? then
      File.write(@execute_dir + '/input',  manager.input)
      @input_flag = true
    end
  end

  # コンパイルと実行をする
  def execute
    @execute_manager = ExecuteManager.new(@execute_dir, @compile_command,
                        @execute_command, 3, @input_flag)
    @execute_manager.execute
  end

  # 採点を終了する
  def exit
    # 実行ディレクトリを削除する
    FileUtils.remove_dir(@execute_dir)
    @execute_manager.cancel
  end
end

