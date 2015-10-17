# -*- coding: utf-8 -*-
require 'concurrent'
require 'timeout'
require 'open4'

# コマンド実行後の処理をするためのObserver
class PostTask
    # 正常処理とエラー処理をする実行ブロックを確保するHashを初期化。
    def initialize
      @events = Hash.new
    end

    # Hashに実行ブロックをイベント名(symbol)と紐付けてHashへ登録。
    # @param [Symbol] symbol イベント名を表すシンボル
    # @param [Proc] block 実行ブロック
    def register(symbol, &block)
      @events[symbol] = block
    end

    # Subject(CommandExecutor)がコマンドの実行が終了したときに呼び出される。
    # @param [Date] time 実行時刻
    # @param [String] value コマンド実行結果
    # @param [Error] reason コマンド実行時のエラー 失敗時はnil
    def update(time, value, reason)
      # 正常時とエラー時の実行ブロックが登録されていない場合はRuntimeErrorを起こす。
      if !@events.key?(:stdout) || !@events.key?(:stderr) then
        raise 'Please register stdout and stderr events.'
      end

      stdout = value[:stdout]
      stderr = value[:stderr]
      success = value[:success]

      # 結果がなく、Statusがおかしいときエラー落ち。
      if stdout.empty? && stderr.empty? && !success
        @events[:stderr].call('エラー終了しました。')
      # エラーがあるときはそれを表示。
      elsif !stderr.empty? then
        @events[:stderr].call(stderr)
      # それ以外は正常。
      else
        @events[:stdout].call(stdout)
      end
    end
end

# コマンド実行を行う
class CommandExecutor
  # コマンド実行をConcurrent::Futureでラッピング。
  # コマンド終了時処理(PostTask)をオブサーバーとして追加。
  # @param [String] command コマンド文字列
  # @param [PostTask] observer コマンド終了時処理
  # @param [Integer] time タイムアウト時間(秒)
  def initialize(execute_dir, command, observer, time, input_flag = false)
    @command = command
    @task = Concurrent::Future.new {
      timeout(time){
        out_r, out_w = IO.pipe
        err_r, err_w = IO.pipe

        if input_flag then
          @pid = spawn @command, {in: execute_dir + '/input', out: out_w,
                                   err: err_w, chdir: execute_dir}
        else
          @pid = spawn @command, {out: out_w, err: err_w, chdir: execute_dir}
        end

        @thread = Process.detach(@pid)
        _, status = Process.wait2(@pid)

        out_w.close
        err_w.close
        {stdout: out_r.read, stderr: err_r.read, success: status.success?}
      }
    }
    @task.add_observer(observer)
  end

  # Futureタスク(@task)の実行
  def execute
    @task.execute
  end

  # Futureタスク(@task)の停止
  def cancel
    if @task.state == :pending then
      @task.cancel
    end
    force_kill
  end

  def force_kill
    Process.kill 'KILL', @pid if @pid != nil && @thread.status
    @thread.kill if !@thread.nil?
  end
  private :force_kill

end

# コンパイルコマンドと実行コマンドの制御
class ExecuteManager
  # コンパイルコマンド・実行コマンド、それぞれのオブザーバーの生成。
  # @param [String] compile_command コンパイルコマンド文字列
  # @param [String] execute_command 実行コマンド文字列
  # @param [Integer] time タイムアウト時間(秒)
  def initialize(execute_dir, compile_command, execute_command, time, input_flag)
    # 実行コマンドのオブザーバーの生成
    execute_task = PostTask.new
    execute_task.register(:stdout) do |value|
      if !value.empty?
        main_window = MainWindow.instance
        main_window.set_execute_result(value)
      end
    end

    execute_task.register(:stderr) do |reason|
      if !reason.empty?
        main_window = MainWindow.instance
        main_window.set_execute_err(reason)
      end
    end

    # 実行コマンド制御
    @executor = CommandExecutor.new(execute_dir, execute_command, execute_task, time, input_flag)

    # コンパイルコマンドのオブザーバーの生成
    compile_task = PostTask.new
    compile_task.register(:stdout) do |value|
      if !value.empty?
        main_window = MainWindow.instance
        main_window.set_compile_result(value)
      end
      @executor.execute
    end

    compile_task.register(:stderr) do |reason|
      if !reason.empty?
        main_window = MainWindow.instance
        main_window.set_compile_err(reason)
      end
      @executor.execute
    end

    @compile_executor = CommandExecutor.new(execute_dir, compile_command, compile_task, time)
  end

  # コマンドの実行(コンパイルが終了次第、
  #   実行コマンドが動くのでコンパイルコマンドだけを実行する。)
  def execute
    @compile_executor.execute
  end

  # コンパイルコマンドと実行コマンドをキャンセルする。
  def cancel
    @compile_executor.cancel
    @executor.cancel
  end
end
