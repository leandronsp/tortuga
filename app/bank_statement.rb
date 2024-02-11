require_relative 'database'

class BankStatement
  class NotFoundError < StandardError; end

  def self.call(*args)
    new(*args).call
  end

  def initialize(account_id)
    @account_id = account_id
  end

  def call
    db.transaction do 
      current = db.exec_params(
        File.read('app/sql/select_account.sql'),
        [@account_id]
      ).first

      raise NotFoundError unless current

      sql = File.read('app/sql/bank_statement_as_json.sql')
      db.exec_params(sql, [@account_id]).first['json_build_object']
    end
  end

  private 

  def db = Database.pool.checkout
end
