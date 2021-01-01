
module TFClient
  module Models
    module Client
      class Database
        require "active_record"

        def self.connect(path:)
          ActiveRecord::Base.establish_connection(
            adapter: 'sqlite3',
            database: path
          )
          # ActiveRecord::Schema.define do
          #   create_table :systems do |table|
          #     table.column :system_id, :string
          #     table.column :x, :integer
          #     table.column :y, :integer
          #     table.column :brightness, :integer
          #     table.column :asteroid_ore, :string
          #     table.column :asteroid_density, :integer
          #     table.column :links, :string
          #     table.column :planets, :string
          #     table.column :name, :string
          #   end
          #
          #   add_index :systems, :system_id
          # end
        end
      end
    end
  end
end