# TechKid 2k10
# Open a given file.

recipe :open do
  process do |files|
    if defined?(OPEN)
      files.take_and_map do |file|
        system 'open -g "%s"' % OPEN
        log 'Opened file %s.' % OPEN
        (defined?(FALLTHROUGH) ? false : $?)
      end
    else
      log "No file to open given."
      false
    end
  end
end