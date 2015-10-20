# -*- coding: utf-8 -*-
require 'observer'
require_relative 'prefs_mediator'
require_relative '../view/main_window'

# 採点設定
module Model
  class Preferences
    include Observable
    attr_reader :value

    def initialize
      mediator = PreferencesMediator.instance

      add_observer(mediator)
      @value = mediator.load_prefs(self)
    end

    # 設定を反映
    def update(pref)
      @value = @value.merge(pref)
    end

    # 設定を保存
    def save_prefs()
      changed
      notify_observers(@value)
    end
  end
end
