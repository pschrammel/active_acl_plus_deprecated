class ::Object

  # Loads all files it finds at the specified path - 
  # use /path/**/[^.]*.rb to load from sub directories as well
  # 
  # Silently fails if path is not found or an error occurs
  def load_files_from(filenames)
    # don't show files that begin with . and ensure .rb ending
    cs = Dir["#{filenames}"]
    for file_name in cs.sort  
      begin
        # load file_name    
        load(file_name)
        Rails.logger.info "#{file_name} loaded"
      rescue Exception => e
        Rails.logger.warn("error loading file #{file_name}: #{e.message}")
        Rails.logger.warn(e.backtrace)
      end  
    end
  end
end