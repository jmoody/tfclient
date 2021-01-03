
module TFClient
  module Models
    module Client
      require "active_record"
    end
  end
end

module TFClient::Models::Client

  DIR_MOD_MAP = {
    "n" => [0, 1],
    "ne" => [1,1],
    "e" => [1, 0],
    "se" => [1, -1],
    "s" => [0, -1],
    "sw" => [-1, -1],
    "w" => [-1, 0],
    "nw" => [-1, 1]
  }.freeze

  INCF_DECF_MAP = {
    "0,1" => "n",
    "1,1" => "ne",
    "1,0" => "e",
    "1,-1" => "se",
    "0,-1" => "s",
    "-1,-1" => "sw",
    "-1,0" => "w",
    "-1,1" => "nw"
  }

  class Coordinate

    attr_reader :x, :y

    def initialize(x:, y:)
      @x = x
      @y = y
    end

    def == (other)
      @x == other.x && @y == other.y
    end

    def to_s
      %Q[#<Client::Coordinate (#{x}, #{y})]
    end

    def coordinates_by_travelling(direction:)
      mod = DIR_MOD_MAP.fetch(direction)
      Coordinate.new(x: @x + mod[0], y: @y + mod[1])
    end
  end

  class System < ActiveRecord::Base
    require "json"

    def self.create_system(nav:, system_id:)
      TFClient.info("creating a new system with id: #{system_id}")

      links = nav.links.items.map do |link|
        [link[:index], link[:direction], link[:drag], link[:faction]]
      end

      planets = nav.planets.items.map do |planet|
        [planet[:index], planet[:type], planet[:name], planet[:faction]]
      end

      System.create(
        system_id: system_id,
        x: nav.coordinates.x,
        y: nav.coordinates.y,
        name: nav.system ? nav.system.name : "",
        claimed_by: nav.claimed_by ? nav.claimed_by.faction : "",
        brightness: nav.brightness.value,
        asteroid_ore: nav.asteroids.ore,
        asteroid_density: nav.asteroids.density,
        links: JSON.generate(links),
        planets: JSON.generate(planets)
      )
    end

    def self.system_for_coordinate(coordinate:)
      System.where("x == ? and y == ?", coordinate.x, coordinate.y).first
    end

    def self.system_for_id(id:)
      System.where("system_id == ?", id).first
    end

    def self.system_for_name(name:)
      System.where("name == ?", name)
    end

    def links_array
      JSON.parse(links)
    end

    def to_s
      %Q[#<Client::System (#{x}, #{y}) #{system_id}>]
    end

    def system_in_direction(direction:)
      coords = Coordinate.new(x: x, y: y)
      other_coords = coords.coordinates_by_travelling(direction: direction)
      return System.system_for_coordinate(coordinate: other_coords), other_coords
    end

    def connected_systems
      links_array.map do |link|
        system, _ = system_in_direction(direction: link[1])
        system
      end
    end
  end
end
