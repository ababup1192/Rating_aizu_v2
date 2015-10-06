# -*- coding: utf-8 -*-
require 'tk'
require 'singleton'
require_relative 'rating'

class MainWindow
  include Singleton

  def launch
    window = TkRoot.new{
      title 'Rating Aizu'
      resizable [0, 0]
      geometry '300x200+100+100'
    }

    helloworld = TkLabel.new{
      text 'Hello World'
      pack
    }

    button = TkButton.new{
      text 'exit'
      command proc{ exit }
      pack
    }

    Tk.mainloop
  end

end

MainWindow.instance.launch
