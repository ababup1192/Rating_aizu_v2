require 'tk'



class Dialog
  attr_accessor :dialog
  def initialize(button, title, width, height, &block)
    @dialog = TkToplevel.new(button){
      title title
      resizable [0, 0]
      geometry "#{width}x#{height}+150+150"
      protocol 'WM_DELETE_WINDOW', proc{ puts 'hoge' }
    }.withdraw
    @wait_var = TkVariable.new
    @block = block
  end

  def launch
    @block.call
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

class TkTextWithScrollbar
  attr_accessor :tk_text

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


