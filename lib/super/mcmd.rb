require "./LZBoxDemoAppend/lib/m_command"

if ARGV.length > 0
  $ARG0 = ARGV[0]
else
  $ARG0 = nil
end
if ARGV.length > 1
  $ARG1 = ARGV[1]
else
  $ARG1 = nil
end

cmd = $ARG0

command = M_JF::M_Command.new
if command.respond_to? cmd
  command.public_send cmd
else
  puts "command #{cmd} not found"
end
