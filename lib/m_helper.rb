$verbose = true

def exec_cmd_line(script, err_msg = nil, err_code = 0)
  puts "+ #{script} - #{Dir.pwd}"
  # script = "#{script} >~/.jf/jf.log 2>&1"
  st = system script
  # $cmd_line_last_log = `cat ~/.jf/jf.log`
  if not st
    if err_msg
      puts "ERROR: #{err_msg}\n#{script}"
      # puts $cmd_line_last_log
    end
    if err_code != 0
      exit err_code
    end
  end
  st
end
