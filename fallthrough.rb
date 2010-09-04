recipe :fallthrough do
  startup do
    FALLTHROUGH = true
  end
  
  process do |files|
    files.take_and_map do
      true
    end
    log "Fallthrough success!"
  end
end