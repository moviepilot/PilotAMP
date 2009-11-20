require 'fileutils'
require 'erb'
require 'active_record'
require 'pathname' 
require 'yaml'

#
#  Change this once 2.3.4 is rolled out and Globalize removed. Change names and add
#
class Language < ActiveRecord::Base
  set_table_name "globalize_languages"
end

class Translation < ActiveRecord::Base
  set_table_name "globalize_translations"
  set_inheritance_column :disable_single_table_inheritance

  belongs_to :language

  def self.lookup(globalize_key)
    results = {}

    [:de, :en, :fr, :es, :pl].map do |language|
      
      ActiveRecord::Base.establish_connection \
        :adapter  => "mysql",
        :host     => Project.database_settings["host"],
        :username => Project.database_settings["username"],
        :password => Project.database_settings["password"],
        :database => [language, Project.database_settings["database"]].join("_")

      Translation.all(:conditions => ["tr_key = ? AND text IS NOT NULL", globalize_key] , :include => :language).map do |tr|
        results[tr.language.iso_639_1] = tr.text
      end
    end

    results["globalize"] = globalize_key
    results
  end
end