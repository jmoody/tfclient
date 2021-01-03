
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
          if !File.exist?(path)
            ActiveRecord::Schema.define do
              create_table :systems do |table|
                table.column :system_id, :string
                table.column :x, :integer
                table.column :y, :integer
                table.column :brightness, :integer
                table.column :asteroid_ore, :string
                table.column :asteroid_density, :integer
                table.column :links, :string
                table.column :planets, :string
                table.column :name, :string
                table.column :claimed_by, :string
              end

              add_index :systems, :system_id
              add_index :systems, :name
            end
          end
        end
      end
    end
  end
end