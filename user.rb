# -*- coding: utf-8 -*-

# ユーザ(学生)。ユーザはIDと点数を持つ。
class User
  attr_accessor :id, :score
  # @param [String] id ユーザID(学籍番号)
  # @param [Integer] score 点数
  def initialize(id, score = 0)
    @id = id
    @score = score
  end

  def to_s
    "#{@id} -> #{@score}"
  end
end

# ユーザ全体を管理する
class UserRepository
  attr_accessor :users

  # メーリングリストからユーザのリストへと変換
  # @param [String] mailing_list メーリングリスト
  def initialize(mailing_list)
    @users = mailing_list.map{ |mail| User.new(mail) }
  end

  # ユーザの検索
  # @param [String] user_id ユーザID(学籍番号)
  # @return [User] ユーザ
  def find_user(user_id)
    @users.find{ |user| user.id == user_id }
  end

  # ユーザ情報(主に点数)の更新
  # @param [User] user ユーザの更新情報
  def update_user!(user)
    index = @users.index{ |u| u.id == user.id }
    if index != nil then
      @users[index] = user
    end
  end
end

