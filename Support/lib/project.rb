require 'fileutils'
require 'erb'
require 'pathname' 
require 'yaml'

class Project
  RAILS_ROOT = ENV['TM_PROJECT_DIRECTORY'] || ((defined? ::RAILS_ROOT) ? ::RAILS_ROOT : ".")
  
  def self.save_translations(i18nkey, hash)
    hash.each do |locale, value|
      save_translation(locale, i18nkey, value)
    end
  end
  
  def self.save_translation(locale, key, value)
    dirname = Pathname.new(RAILS_ROOT).join("db", "locales", "translations", *key.split("."))
    filename = dirname.join "translations.yml"
    FileUtils.mkdir_p(dirname.to_s)
    
    hash = nil
    File.open(filename.to_s, "a+") do |f|
      f.rewind
      hash = YAML.load(f.read) || {}
    end

    hash[locale] = value
    
    File.open(filename.to_s, "w") do |f|
      f.write(YAML.dump(hash))
    end
  end
  
  def self.database_settings
    @@db_conf ||= YAML.load(
      ERB.new(
        IO.read(Pathname.new(RAILS_ROOT).join("config", "database.yml"))
      ).result
    )["live_translations"]
    
    raise "you need a live_translations entry in database.yml" unless @@db_conf
    @@db_conf
  end
end