# -*- coding: utf-8 -*-
require 'singleton'
require 'SecureRandom'
require_relative 'command'
require_relative 'user'

class RatingManager
  include Singleton

  attr_accessor :user_repo, :target_dir, :target_files,
                  :compile_command, :execute_command

  # 採点の初期設定を行う
  # @param [String] mailing_list_path メーリングリストのファイルパス
  # @param [String] target_dir 採点対象のディレクトリパス
  # @param [Array<String>] target_files 採点対象のファイル
  # @param [String] compile_command コンパイルコマンド
  # @param [String] execute_command 実行コマンド
  def set_rating(mailing_list_path, target_dir, target_files,
                 compile_command, execute_command)
    mailing_list = read_mailing_list(mailing_list_path)
    @user_repo = UserRepository.new(mailing_list)
    @target_dir = target_dir
    @target_files = target_files
    @compile_command = compile_command
    @execute_command = execute_command
    @current_rating = nil
  end

  # メーリングリストを読み込み
  # @param [String] path
  # @return [Array<String>] メーリングリスト
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
    @current_rating = Rating.new(user_id, @target_dir, @target_files)
    @current_rating.execute
  end

  # 点数を付ける
  # @param [Integer] point 点数
  def mark(point)
    user = @user_repo.find_user(@current_rating.user_id)
    user.point = point
    @user_repo.update_user!(user)
    # TODO user_repoをMainWindowへ反映
  end
end

# 対象となるファイルをコピーし、コンパイル・実行・採点を行う
class Rating

  attr_accessor :user_id

  # 採点に必要な情報の初期化
  # @param [String] user_id ユーザID(学籍番号)
  # @param [String] target_dir コピー対象のディレクトリパス
  # @param [Array<String>] target_files コピー対象のファイル名
  def initialize(user_id, target_dir, target_files)
    @user_id = user_id
    @uuid = SecureRandom.uuid
    @target_dir = target_dir
    @target_files = target_files
    @manager = RatingManager.instance
    @execute_dir = '/tmp/rating-aizu/' + @uuid
    copy_targetfiles
  end

  # 採点対象ファイルを実行ディレクトリへコピーする
  def copy_targetfiles
    FileUtils.mkdir_p(@execute_dir)
    @target_files.map!{ |file| @target_dir + '/' + file }
    FileUtils.cp(@target_files, @execute_dir)
  end

  private :copy_targetfiles

  # コンパイルと実行をする
  def execute
    @execute_manager = ExecuteManager.new(@execute_dir, @manager.compile_command,
                        @manager.execute_command, 3)
    @execute_manager.execute
  end

  # 採点を終了する
  def exit
    @execute_manager.cancel
  end
end

