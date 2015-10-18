# -*- coding: utf-8 -*-
require_relative 'mailinglist'
require_relative 'reting_dir'
require_relative 'command_select'
require_relative 'input'
require_relative 'result_file'
require_relative 'delimiter'

# 設定の仲介役
class PreferencesMediator
  include Singleton
  attr_reader :prefs

  # 設定を作成
  def create_prefs()
    mailinglist = Mailinglist.new
    rating_dir = RatingDir.new
    command_select = CommandSelect.new
    input = Input.new
    result_file = ResultFile.new
    delimiter = Delimiter.new

    @prefs = {input: input, malinglist: mailinglist, rating_dir: rating_dir,
              command_select: command_select,  input: input,
              result_file: result_file, delimiter: delimiter}
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
