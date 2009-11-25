require File.dirname(__FILE__) + '/pilot_amp'
require File.dirname(__FILE__) + '/../lib/project'

filename, directory = Project.translation_path(PilotAMP.unquoted_selected_string)
`mate #{ directory }/translations.yml`