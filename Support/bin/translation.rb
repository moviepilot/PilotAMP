require File.dirname(__FILE__) + '/pilot_amp'

PilotAMP.request :title => "Migrate from Gettext", :prompt => "I18n Key" do |key|
  Project.save_translations key, Translation.lookup(PilotAMP.unquoted_selected_string)
end