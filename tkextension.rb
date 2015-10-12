# -*- coding: utf-8 -*-
require 'tk'

# オリジナルダイアログ
class Dialog
  attr_accessor :dialog

  # @param [TkButton] button ダイアログを開くためのボタン
  # @param [String] title ダイアログタイトル
  # @param [Integer] width ダイアログの幅
  # @param [Integer] height ダイアログの高さ
  # @param [Proc] block ダイアログのウィジェット配置を行うブロック
  def initialize(button, title, width, height, &block)
    dialog = self
    @dialog = TkToplevel.new(button){
      title title
      resizable [0, 0]
      geometry "#{width}x#{height}+150+150"
      protocol 'WM_DELETE_WINDOW', dialog.method(:close)
    }.withdraw
    @wait_var = TkVariable.new
    @is_launch = false
    @block = block
  end

  # ダイアログの表示
  def launch
    # 初回のみダイアログのウィジェット配置を行う
    if !@is_launch && !@block.nil? then
      @block.call
      @is_launch = true
    end
    # ダイアログの表示
    @dialog.deiconify
    # トップレベルWindowとして設定。
    @dialog.set_grab
    # ダイアログの処理を待つ。
    @wait_var.tkwait
    # トップレベルWindowを解除、画面を閉じる。
    @dialog.release_grab
    @dialog.withdraw
  end

  def close
    @dialog.withdraw
    @wait_var.value = 1
  end
end

# テキストとスクロールバー一体ウィジェット
class TkTextWithScrollbar
  attr_accessor :tk_text

  # @param [TkFrame] parent_frame 設置元
  # @param [Integer] width テキストボックスの幅
  # @param [Integer] height テキストボックスの高さ
  def initialize(parent_frame, width, height)
    @frame = TkFrame.new(parent_frame)

    @tk_text = TkText.new(@frame){
      width width
      height height
      yscrollbar @scrollbar
    }

    @scrollbar = TkScrollbar.new(@frame)
  end

  def pack
    @frame.pack({side: 'top', pady: 15})
    @tk_text.pack({'side' => 'left'})
    @scrollbar.pack({side: 'right', fill: :y})
  end
end


