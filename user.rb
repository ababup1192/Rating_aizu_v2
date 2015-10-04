# -*- coding: utf-8 -*-
require 'SecureRandom'

# ユーザ(学生)。ユーザはIDと点数を持つ。
class User
  attr_accessor :user_id, :point
  # @param [String] user_id ユーザID(学籍番号)
  # @param [Integer] point 点数
  def initialize(user_id)
    @user_id = user_id
    @point = 0
  end
end
