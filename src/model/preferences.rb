# -*- coding: utf-8 -*-
require 'observer'
require_relative 'prefs_mediator'

# 採点設定
class Preferences
  include Observable

  def initialize
    mediator = PreferencesMediator.instance
    add_observer(mediator)
    @prefs = mediator.load_prefs
  end

  # 設定を反映
  def update(pref)
    @prefs = @prefs.merge(pref)
  end

  # 設定を保存
  def save_prefs()
    changed
    notify_observers(@prefs)
  end
end
