# -*- coding: utf-8 -*-
require 'singleton'
require 'SecureRandom'
require_relative 'command'

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
    mailing_list = readmaling_list(mailing_list_path)
    @user_repo = create_users(maling_list)
    @target_dir = target_dir
    @target_files = target_files
    @compile_command = compile_command
    @execute_command = execute_command
  end

  # メーリングリストを読み込み
  # @param [String] path
  # @return [Array<String>] メーリングリスト
  private
  def read_mailing_list(path)
  end

  # メーリングリストからユーザリストの作成
  # @return [UserRepository] ユーザリポジトリ
  private
  def create_users(mailing_list)
  end

  # 次の採点対象を決める
  # @param [String] user_id ユーザID(学籍番号)
  def mark_next(user_id)
  end

  # 点数を付ける
  # @param [Integer] point 点数
  def mark(point)
  end
end

# 対象となるファイルをコピーし、コンパイル・実行・採点を行う
class Rating
  # 採点に必要な情報の初期化
  # @param [String] user_id ユーザID(学籍番号)
  # @param [String] target_dir コピー対象のディレクトリパス
  # @param [Array<String>] target_files コピー対象のファイル名
  def initialize(user_id, target_dir, target_files)
    @user_id = user_id
    @uuid = SecureRandom.uuid
    @target_dir = target_dir
    @target_files = target_files
  end

  # 採点対象ファイルを実行ディレクトリへコピーする
  private
  def copy_targetfiles
  end

  # コンパイルと実行をする
  def execute

  end

  # 点数を付ける
  # @param [Integer] point 点数
  def mark(point)
  end

  # 採点を終了する
  def exit
  end
end
