# Author:: od (mailto:od@idfuze.com)
# Copyright:: 2011 IDFUZE.COM Olivier DIRRENBERGER - Released under the terms of the MIT license
# 
# :title:Rsmbclient

class Rsmbclient
  
  require 'logger'
  require 'pty'
  require 'expect'
  require 'time'

  attr_reader :files, :dirs, :path, :connected
  
  def initialize(options={:domain => '', :host => '', :share => '', :user => '', :password => ''})
    begin
      @o, @i, @pid = PTY.spawn("smbclient //#{options[:host]}/#{options[:share]} #{options[:password]} -W #{options[:domain]} -U #{options[:user]}")

      res = @o.expect(/^smb:.*\\>/, 10)[0]
      @connected = case res
      when /^put/
        res['putting'].nil? ? false : true
      else
        if res['NT_STATUS']
          false
        elsif res['timed out'] || res['Server stopped']
          false
        else
          true
        end
      end
      
      unless @connected
        close if @pid
        exit(1)
      else
        @path = "."
        ls
      end
    rescue
      raise RuntimeError.exception("Unknown Process Failed!! (#{$!.to_s})")
    end
  end
  
  def resume
    puts "-------------\npath:-------------\n"
    puts "  #{@path}"
    puts "-------------\ndirs:-------------\n"
    @dirs.each do |d|
      puts "  #{d}"
    end
    puts "-------------\nfiles:-------------\n"
    @files.each do |f|
      puts "  #{f[0]} (#{f[2]})"
    end
    return nil
  end
  
  def ls(mask='')
    parse_files(ask("ls"))
  end

  def cd(dir)
    if @dirs.include?(dir)
      if ask "cd #{dir}"
        ls
        make_path(dir)
        return true
      else
        return false
      end
    else
      return nil
    end
  end

  def close
    ask("quit")
    @connected = false
  end
  
  private
  
  def ask(cmd)
    @i.printf("#{cmd}\n")
    response = @o.expect(/^smb:.*\\>/, 10)[0]
    if response.nil?
      $stderr.puts "Failed to do #{cmd}"
      exit(1)
    else
      return response
    end
  end
  
  def make_path(str)
    str.split("/").each do |s|
      ap = @path.split("/")
      @path = case s
        when ".." then ap.pop && ap.join("/")
        when "." then @path
        else ap.push(s).join("/")
        end unless s == "."
    end
  end
  
  def get_files(str)
    
  end
  
  def parse_files(str)
    @files = []
    @dirs = []
    str.each_line do |line|
      if line =~ /\s+(\S+)\s+(\w+)\s+(\d+)\s+(.+)$/
        if $2 == "D"
          @dirs << $1
        else
          #name, type, size, date
          @files << [$1, $2, $3, (Time.parse($4) rescue "!!#{$4}")]
        end
      end
    end
    return @files.size + @files.size
  end
  
end