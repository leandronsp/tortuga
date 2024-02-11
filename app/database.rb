require 'pg'
require 'connection_pool'

class Database
  POOL_SIZE = ENV['DB_POOL_SIZE'] || 5

  def self.pool
    @pool ||= ConnectionPool.new(size: POOL_SIZE, timeout: 300) do
      PG.connect({ 
        host: 'postgres',
        dbname: 'postgres',
        user: 'postgres',
        password: 'postgres'
      })
    end
  end
end
