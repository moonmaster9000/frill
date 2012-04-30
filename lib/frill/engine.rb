require 'rails'

module Frill
  class Engine < Rails::Engine
    config.autoload_paths << "app/frills"

    initializer "frill.rails_integration" do
      require 'frill/rails'
    end

    config.to_prepare do
      if Rails.env.development? && !Rails.application.config.cache_classes
        Frill.reset!

        Frill::Engine.force_load Dir["#{Frill::Engine.root}/app/frills/*"]
        Frill::Engine.force_load Dir["#{Rails.root}/app/frills/*"]
      end
    end

    def self.force_load files
      files.each do |f| 
        load f
      end
    end
  end
end
