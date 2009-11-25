require 'erb'
require 'rubygems'
require 'active_record'
require 'jcode'

$KCODE="UTF8"

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
        :port     => Project.db["port"],
        :encoding => Project.db["encoding"],
        :host     => Project.db["host"],
        :username => Project.db["username"],
        :password => Project.db["password"],
        :database => [language, Project.db["database"]].join("_")

      Translation.all(:conditions => ["tr_key = ? AND text IS NOT NULL", globalize_key] , :include => :language).map do |tr|
        results[tr.language.iso_639_1] = tr.text
      end
    end

    results["example"] = globalize_key
    results
  end
end