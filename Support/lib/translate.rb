#!/usr/bin/env ruby
 
# Copyright:
#   (c) 2009 Nico Hagenburger, Hagenburger GmbH
#   Released under the MIT license.
#   Visit my Blog at http://www.hagenburger.net
#   Follow me on http://twitter.com/Hagenburger
# Author: Nico Hagenburger (follow me on twitter for contact)
# Description:
#   Inserts an translation string to the current position
#   and to the localization file(s).
# Example for German/DE and English/EN translation:
#   users.update.success
#   Du hast dein Geschlecht erfolgreich geändert.
#   You changed your gender successfully.
# Hint: 
#   Press fn + return to close window instead of clicking OK
#   (if fn key is available).
 
require 'rails_bundle_tools'
require 'yaml'
require 'rubygems'
require 'ya2yaml'
require 'jcode'
$KCODE = 'u'
 
current_file = RailsPath.new
rails_root = RailsPath.new.rails_root
locales_dir = File.join(rails_root, 'config', 'locales')
 
if [:view, :helper, :controller].include?(current_file.file_type)
  method = 't'
else
  method = 'I18n.t'
end
 
# Change this, if you want to use outher default keys.
# Default is “controller.action.key”
suggestion = ''
unless current_file.controller_name.nil?
  suggestion << "#{current_file.controller_name}."
end
unless current_file.action_name.nil?
  suggestion << "#{current_file.action_name}."
end
case TextMate.current_line
when /flash\[:([a-z_]+)\]/
  suggestion << "#{$~[1]}n"
when /<h1/
  suggestion << "headlinen"
when /link_to/
  suggestion << "link_"
end
 
languages = []
Dir.open(locales_dir).entries.each do |file|
  if file =~ /^translation_([a-zA-Z_-]+).yml$/
    languages << $~[1]
  end
end
 
# Don’t use TextMate.textbox. You won’t get any results.
user_input = TextMate.cocoa_dialog(
    'textbox',
    :informative_text => "Enter ID in the first line and translations " +
      "in the following lines in this order:\n" +
      languages.map { |l| "\n#{l} (optional)" }.join(''),
    :text => suggestion,
    :title => "Add translation (by www.hagenburger.net)",
    :focus_textbox => true,
    :editable => true,
    :button1 => 'OK',
    :button2 => 'Cancel'
  )
 
if user_input[0] == "1" # OK was clicked
  id            = user_input[1]
  id_splitted   = id.split('.')
  translations  = user_input[2..-1]
 
  0.upto(languages.length - 1) do |i|
    filename = File.join(locales_dir, "translation_#{languages[i]}.yml")
    yaml = YAML.load(File.read(filename))
    yaml[languages[i]] ||= {}
    current = yaml[languages[i]]
    id_splitted[0..-2].each do |key|
      current[key] = {} unless current[key].is_a?(Hash)
      current = current[key]
    end
    current[id_splitted.last] = "#{translations[i]}"
    File.open(filename, 'w+') do |file|
      # to_yaml has problems with German umlauts
      # and would print them as binary.
      text = yaml.ya2yaml
      file.puts text
    end
  end
 
  print "#{method}('#{id}')"
  TextMate.exit_insert_text
end
