
module TFClient
  module Models
    module Local
      require "sequel"
    end
  end
end

module TFClient::Models::Local

  require_relative "../../textflight-client/logging.rb"
  require "json"

  class Database

    attr_reader :connection, :path

    def initialize(path:)
      @connection = Sequel.connect("sqlite://#{path}")

      if !@connection.table_exists?(:systems)
        @connection.create_table(:systems) do
          primary_key :id
          column :x, Integer
          column :y, Integer
          column :claimed_by, String
          column :brightness, Integer
          column :asteroid_ore, String
          column :asteroid_density, Integer
          column :links, String
          column :planets, String
        end
      end
    end

    def system_for_id(id:)
      table = @connection[:systems]
      table.where(id: id)
    end

    def create_system(id:, nav:)
      TFClient.info("creating a new system with id: #{id}")

      links = nav.links.items.map do |link|
        [link[:index], link[:direction], link[:drag], link[:faction]]
      end

      planets = nav.planets.items.map do |planet|
        [planet[:index], planet[:type], planet[:name], planet[:faction]]
      end

      table = @connection[:systems]
      table.insert(
        {
          id: id,
          x: nav.coordinates.x,
          y: nav.coordinates.y,
          claimed_by: nav.claimed_by ? nav.claimed_by.faction : "",
          brightness: nav.brightness.value,
          asteroid_ore: nav.asteroids.ore,
          asteroid_density: nav.asteroids.density,
          links: JSON.generate(links),
          planets: JSON.generate(planets)
        }
      )
    end
  end
end