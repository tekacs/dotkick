# TechKid 2k10
# Watch all LaTeX (*.tex) files in the current directory tree and re-render a
# main file if any of them changes.
# Useful in conjunction with subfiles.sty.

recipe :watchtex do
  GROWL_TYPES = Kicker::Growl::NOTIFICATIONS
  command = "/usr/bin/env pdflatex %s"
  
  startup do
    maintex = defined?(MAINTEX) ? MAINTEX : nil
    until maintex =~ /\.tex$/ && File.file?(maintex)
      print "Path to main LaTeX file: "
      maintex = gets.chomp
    end
    command = command % maintex
    puts "Watching for LaTeX file changes, reloading #{maintex}."
  end
  
  process do |files|
    refresh = false
    files.take_and_map('*.tex') do |file|
      output = `#{command}`
      status = $? == 0 ? :succeeded : :failed
      Kicker::Growl.growl(
        GROWL_TYPES[status],
        "LaTeX Build " + status.to_s,
        output.split("\n").reverse.slice(0, 10).reverse.join("\n")
      ) if Kicker::Growl.use
      true
    end
  end
end