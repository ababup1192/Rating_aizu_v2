# -*- coding: utf-8 -*-

class FileUtil

  def self.open_file(file_path)
    begin
      File.open(file_path) do |file|
        {stdout: file.read}
      end
    rescue IOError => e
      {stderr: e.message}
    rescue Errno::ENOENT => e
      {stderr: e.message}
    rescue Errno::EISDIR => e
      {stderr: e.message}
    end
  end

  def self.open_mailinglist(file_path)
    arr = []
    if !file_path.nil? then
      File.open(file_path) do |file|
        file.each_line do |line|
          line =~ /^(\w\d+)$/
          arr << $1 if !$1.nil?
        end
      end
    end
    arr
  end

end
