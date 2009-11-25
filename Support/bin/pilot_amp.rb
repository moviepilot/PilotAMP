$:.unshift(ENV['TM_BUNDLE_SUPPORT'] + "/lib")
require ENV['TM_SUPPORT_PATH'] + '/lib/ui'

module PilotAMP

  def self.unquoted_selected_string
    selected_text.gsub(/^(["'])(.*)\1$/, '\2')
  end

  def self.selected_text
    ENV["TM_SELECTED_TEXT"]
  end
  
  def self.directory
    ENV["TM_DIRECTORY"]
  end
  
  def self.filepath
    ENV['TM_FILEPATH']
  end
  
  def self.filename
    File.basename(filepath)
  end

  def self.request(options)
    if string = TextMate::UI.request_string(options)
      require 'project'
      require 'i17on'

      yield string
      
      print "'%s'" % string
    end || PilotAMP.unquoted_selected_string
  end
end