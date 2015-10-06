# -*- coding: utf-8 -*-
require 'concurrent'
require 'timeout'

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

      # 正常時のブロック呼び出し。
      if reason.nil? then
        @events[:stdout].call(value)
      # エラー時のブロック呼び出し。
      else
        @events[:stderr].call(reason)
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
  def initialize(execute_dir, command, observer, time)
    @command = command
    @task = Concurrent::Future.new {
      timeout(time){
        out_r, out_w = IO.pipe
        err_r, err_w = IO.pipe
        @pid = spawn @command, {out: out_w, err: err_w, chdir: execute_dir}
        @thread = Process.detach(@pid)
        out_w.close
        err_w.close
        out_r.read
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
  def initialize(execute_dir, compile_command, execute_command, time)
    # 実行コマンドのオブザーバーの生成
    execute_task = PostTask.new
    execute_task.register(:stdout) do |value|
      puts '------execute------'
      puts value
      puts '--------end--------'
    end

    execute_task.register(:stderr) do |reason|
      puts '------execute------'
      puts reason
      puts '--------end--------'
    end

    # 実行コマンド制御
    @executor = CommandExecutor.new(execute_dir, execute_command, execute_task, time)

    # コンパイルコマンドのオブザーバーの生成
    compile_task = PostTask.new
    compile_task.register(:stdout) do |value|
      puts '------compile------'
      puts value
      puts '--------end--------'

      @executor.execute
    end

    compile_task.register(:stderr) do |reason|
      puts '------compile------'
      p reason
      puts '--------end--------'

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
