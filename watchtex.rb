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
    log "Watching for LaTeX file changes, reloading #{maintex}."
  end
  
  process do |files|
    refresh = false
    files.take_and_map('*.tex') do |file|
      output = `#{@command}`
      succeeded = $? == 0
      growl_status = succeeded ? :succeeded : :failed
      Kicker::Growl.growl(
        GROWL_TYPES[growl_status],
        "LaTeX Build " + growl_status.to_s,
        output.split("\n").reverse.slice(0, 5).reverse.join("\n")
      ) if Kicker::Growl.use
      log "Successfully reloaded!" if succeeded
      succeeded
    end
  end
end