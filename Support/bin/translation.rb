require 'rubygems'
require "#{ ENV['TM_SUPPORT_PATH'] }/lib/ui.rb"

require 'project'
require 'i17on'

gettext_key = ENV["TM_SELECTED_TEXT"].gsub(/^(["'])(.*)\1$/, '\2')

i18nkey = TextMate::UI.request_string(
  :title => "Enter the new I18n key", 
  :prompt => "Enter the new I18n key",
  :button1 => 'Create'
)

hash = Translation.lookup(gettext_key)
Project.save_translations(i18nkey, hash)

print "'" + i18nkey + "'"
