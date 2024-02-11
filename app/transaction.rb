require_relative 'database'

class Transaction
  class InvalidDataError < StandardError; end
  class InvalidLimitAmountError < StandardError; end
  class NotFoundError < StandardError; end

  def self.call(*args)
    new(*args).call
  end

  def initialize(account_id, amount, transaction_type, description)
    @account_id = account_id
    @amount = amount
    @transaction_type = transaction_type
    @description = description
  end

  def call
    raise InvalidDataError unless @account_id && @amount && @transaction_type && @description
    raise InvalidDataError if @description && @description.empty?

    db.transaction do 
      current = db.exec_params(
        File.read('app/sql/select_account.sql'),
        [@account_id]
      ).first

      raise NotFoundError unless current

      limit_amount = current['limit_amount'].to_i
      balance = current['balance'].to_i

      raise InvalidLimitAmountError if @transaction_type == 'd' && 
                                        reaching_limit?(balance, limit_amount, @amount)

      db.exec_params(
        File.read('app/sql/insert_transaction.sql'),
        [@account_id, @amount, @transaction_type, @description]
      )

      update_operation = @transaction_type == 'd' ? '-' : '+'

      db.exec_params(
        File.read('app/sql/update_balance.sql').gsub('{{operation}}', update_operation),
        [@account_id, @amount]
      )

      db.exec_params(
        File.read('app/sql/select_account_as_json.sql'),
        [@account_id]
      ).first['json_build_object']
    end
  end

  private 

  def reaching_limit?(balance, limit_amount, amount)
    return false if (balance - amount) > limit_amount
    (balance - amount).abs > limit_amount
  end

  def db = Database.pool.checkout
end
