# -*- coding: utf-8 -*-
require 'observer'

module ChangingObserver
  include Observable

  # 古いオブザーバを削除し、新しいオブザーバに変える。
  def change_observer!(new_observer)
    delete_observers(@observer)
    add_observer(new_observer)
    @observer = new_observer
  end
end
