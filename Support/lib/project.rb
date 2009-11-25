require 'rubygems'
require 'erb'
require 'yaml'
require 'ya2yaml'
require 'fileutils'
require 'pathname'

class Project
  RAILS_ROOT = ENV['TM_PROJECT_DIRECTORY'] || ((defined? ::RAILS_ROOT) ? ::RAILS_ROOT : ".")

  def self.save_translations(i18nkey, hash)
    hash.each do |locale, value|
      save_translation(locale, i18nkey, value)
    end
  end

  def self.translation_path(key)
    keys = key.split(".")

    # contextual view key. read the directory directly under views.
    if key[0..0] == "." && PilotAMP.directory.include?("views")
      subpath = PilotAMP.directory.gsub(/^.*?views\/(.*)$/, '\1')
      filename = PilotAMP.filename.split(".").first.gsub(/^_/, '')
      keys[0] = [subpath, filename].join("/")
    end

    dirname = Pathname.new(RAILS_ROOT).join("db", "locales", "translations", *keys)
    filename = dirname.join "translations.yml"
    
    return filename, dirname
  end
  
  def self.save_translation(locale, key, value)
    filename, dirname = translation_path(key)
    FileUtils.mkdir_p(dirname.to_s)
    
    hash = nil
    File.open(filename.to_s, "a+") do |f|
      f.rewind
      hash = YAML.load(f.read) || {}
    end

    hash[locale] = value

    File.open(filename.to_s, "w") do |f|
      f.write(hash.ya2yaml(:syck_compatible => true))
    end
    
    "'%s'" % key
  end

  def self.db
    @@db_conf ||= YAML.load(
      ERB.new(
        IO.read(Pathname.new(RAILS_ROOT).join("config", "database.yml"))
      ).result
    )["live_translations"]

    raise "you need a live_translations entry in database.yml" unless @@db_conf
    @@db_conf
  end
end