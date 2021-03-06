# -*- coding: utf-8 -*-
require 'tk'

# Tkユーティリティクラス
class TkUtils
  def self.set_entry_value(entry, value)
    if !value.nil? then
      entry.state = 'normal'
      entry.value = value
      entry.state = 'readonly'
    end
  end

  def self.set_text_value(textbox, value)
    if !value.nil? then
      textbox.state = 'normal'
      textbox.foreground 'black'
      textbox.value = value
      textbox.state = 'disabled'
    end
  end

  def self.set_errtext(textbox, value)
    if !value.nil? then
      textbox.state = 'normal'
      textbox.foreground 'red'
      textbox.value = value
      textbox.state = 'disabled'
    end
  end

end

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
      geometry "#{width}x#{height}"
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
  def initialize(parent_frame, width, height, text_value = '', state = 'normal')
    @frame = TkFrame.new(parent_frame)

    @tk_text = TkText.new(@frame){
      width width
      height height
      state state
      yscrollbar @scrollbar
    }
    set_text(text_value)

    @scrollbar = TkScrollbar.new(@frame)
  end

  def pack
    @frame.pack({side: 'top', pady: 15})
    @tk_text.pack({'side' => 'left'})
    @scrollbar.pack({side: 'right', fill: :y})
  end

  def get_text
    @tk_text.value
  end

  def set_text(value)
    if !value.nil?
      if @tk_text.state == 'normal' then
        @tk_text.value = value
      # disabledの場合は、テキストを挿入してから状態を戻す。
      else
        TkUtils.set_text_value(@tk_text, value)
      end
    end
  end

  def set_errtext(value)
    if !value.nil?
      if @tk_text.state == 'normal' then
        @tk_text.value = value
      # disabledの場合は、テキストを挿入してから状態を戻す。
      else
        TkUtils.set_errtext(@tk_text, value)
      end
    end

  end
end


