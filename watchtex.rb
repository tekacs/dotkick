# TechKid 2k10
# Watch all LaTeX (*.tex) files in the current directory tree and re-render a
# main file if any of them changes.
# Useful in conjunction with subfiles.sty.

# Usage:
# 
#   EITHER:
# 
#     kicker -r watchtex [--no-growl]
# 
#   OR, in ./.kick:
# 
#     LATEX_COMMAND = '... %s'
#     MAINTEX = 'main.tex'
#     recipe :watchtex


recipe :watchtex do
  GROWL_TYPES = Kicker::Growl::NOTIFICATIONS
  DEFAULT_COMMAND = "/usr/bin/env pdflatex %s"
  
  startup do
    maintex = defined?(MAINTEX) ? MAINTEX : nil
    @command = defined?(LATEX_COMMAND) ? LATEX_COMMAND : DEFAULT_COMMAND
    until maintex =~ /\.tex$/ && File.file?(maintex)
      print "Path to main LaTeX file: "
      maintex = gets.chomp
    end
    @command = @command % maintex
    puts "Watching for LaTeX file changes, reloading #{maintex}."
  end
  
  process do |files|
    refresh = false
    files.take_and_map('*.tex') do |file|
      output = `#{@command}`
      status = $? == 0 ? :succeeded : :failed
      Kicker::Growl.growl(
        GROWL_TYPES[status],
        "LaTeX Build " + status.to_s,
        output.split("\n").reverse.slice(0, 10).reverse.join("\n")
      ) if Kicker::Growl.use
      if $? == 0
        2.times do
          `#{@command}`
        end
      end
      true
    end
  end
end