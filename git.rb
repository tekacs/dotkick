# TechKid 2k10
# Commit on *any* file change to the current Git repository. This allows for constant saving of file state and the ability to revert to any given state.

recipe :simplegit do
  process do |files|
    valid = false
    files.take_and_map do |file|
      valid ||= file !~ %r{^\.git/}
      if FALLTHROUGH
        false
      else
        valid
      end
    end
    if valid
      `git add . 2>/dev/null`
      execute("git commit -am \"Files changed: #{files.join('|')}\"")
    end
  end
end

recipe :complexgit do
  @growl_types = Kicker::Growl::NOTIFICATIONS
  @growl_title = "GIT Watch"
  @cmd = "/usr/bin/env git"
  @commit_message = "File: %s changed."
  @success_message = "Commited on %s change."
  @fail_message = "No changes committed (for %s)."
  @add_options = ""
  @commit_options = ""
  @file_filter = /.*/
  
  def growl(status, title, message)
    Kicker::Growl.growl(
      @growl_types[status],
      title,
      message
    ) if Kicker::Growl.use
  end
  
  startup do
    @commit_message = COMMIT_MESSAGE if defined?(COMMIT_MESSAGE)
    @success_message = SUCCESS_MESSAGE if defined?(SUCCESS_MESSAGE)
    @fail_message = FAIL_MESSAGE if defined?(FAIL_MESSAGE)
    @add_options = FAIL_MESSAGE if defined?(ADD_OPTIONS)
    @commit_options = FAIL_MESSAGE if defined?(COMMIT_OPTIONS)
    @file_filter = FILE_FILTER if defined?(FILE_FILTER)
    if `git status 2>&1` =~ /^fatal/ && (@commit_options !~ /.*git-dir.*/)
      log "NOT A GIT DIRECTORY! ATTEMPTING TO WATCH ANYWAY!"
    else
      log "Watching for changes to commit to Git."
    end
  end
  
  process do |files|
    files.take_and_map do |file|
      valid = (file !~ %r{\.git/} && file =~ @file_filter)
      if valid
        commands = [
          "add . #{@add_options}",
          "commit #{@commit_options} -am '#{@commit_message % file}'"
        ]
        fail = false
        commands.each do |opt|
          fail ||= !system("#{@cmd} #{opt} 1>/dev/null 2>/dev/null")
        end
        if fail
          log @fail_message % file
          growl(:failed, @growl_title, @fail_message % file)
        else
          log @commit_message % file
          growl(:successful, @growl_title, @success_message % file)
        end
      end
      if defined?(FALLTHROUGH)
        false
      else
        valid
      end
    end
  end
end