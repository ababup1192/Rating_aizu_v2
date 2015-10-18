# -*- coding: utf-8 -*-
require 'singleton'
require_relative 'mailinglist'
require_relative 'rating_dir'
require_relative 'command_select'
require_relative 'input'
require_relative 'result_file'
require_relative 'delimiter'

# 設定の仲介役。
# 現在の設定のコピーを受け渡したり、採点可能かどうかを判断する。
class PreferencesMediator
  include Singleton
  attr_reader :prefs

  # 設定ハッシュのクローンを作って渡す。
  def load_prefs(observer)
    # もし、設定が無かったら新規作成。
    if @prefs.nil?
      mailinglist = Mailinglist.new(observer)
      rating_dir = RatingDir.new(observer)
      command_select = CommandSelect.new(observer)
      input = Input.new(observer)
      result_file = ResultFile.new(observer)
      delimiter = Delimiter.new(observer)

      @prefs = {input: input, malinglist: mailinglist, rating_dir: rating_dir,
                command_select: command_select,  input: input,
                result_file: result_file, delimiter: delimiter}
    end
    new_prefs = @prefs.clone
    new_prefs.each{ |pref| pref.change_observer!(observer) }
    new_prefs
  end

  def update(new_prefs)
    @prefs = @prefs.merge(new_prefs)
  end

  # 未設定のものを集める
  def get_notset_prefs
    @prefs.select{ |k, v| v.rating? == true }
  end

  # 未設定のものの名前を集める
  def get_nonset_prefs_name
    get_nonset_prefs.values.map{ |pref| pref.name }.flatten
  end

  def rating?
    # 全ての設定が終了しているか確認して、畳込み
    @prefs.values.map{ |pref| pref.rating? }.inject(:&)
  end
end
