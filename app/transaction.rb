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
    result = {}

    raise InvalidDataError unless @account_id && @amount && @transaction_type && @description
    raise InvalidDataError if @description && @description.empty?

    db.describe_prepared('select_account_stmt') rescue db.prepare('select_account_stmt', sql_select_account)
    db.describe_prepared('insert_transaction_stmt') rescue db.prepare('insert_transaction_stmt', sql_insert_transaction)
    db.describe_prepared('update_balance_stmt') rescue db.prepare('update_balance_stmt', sql_update_balance)

    db.transaction do 
      raise InvalidDataError unless %w[d c].include?(@transaction_type)

      account = db.exec_prepared('select_account_stmt', [@account_id]).first
      raise NotFoundError unless account

      limit_amount = account['limit_amount'].to_i
      balance = account['balance'].to_i

      raise InvalidLimitAmountError if @transaction_type == 'd' && 
                                        reaching_limit?(balance, limit_amount, @amount)

      db.exec_prepared('insert_transaction_stmt', [@account_id, @amount, @transaction_type, @description])

      db.exec_prepared('update_balance_stmt', [@account_id, @amount])

      account = db.exec_prepared('select_account_stmt', [@account_id]).first

      result.merge!({ 
        limite: account['limit_amount'].to_i,
        saldo: account['balance'].to_i
      })
    end

    result
  end

  private 

  def sql_update_balance
    case @transaction_type
    in 'd' then operation = 'amount = amount - $2'
    in 'c' then operation = 'amount = amount + $2'
    end

    <<~SQL
      UPDATE balances 
      SET #{operation}
      WHERE account_id = $1
    SQL
  end

  def sql_insert_transaction
    <<~SQL
      INSERT INTO transactions (account_id, amount, transaction_type, description)
      VALUES ($1, $2, $3, $4)
    SQL
  end

  def sql_select_account
    <<~SQL
      SELECT 
        balances.amount AS balance, 
        accounts.limit_amount AS limit_amount
      FROM accounts 
      JOIN balances ON balances.account_id = accounts.id
      WHERE accounts.id = $1
      FOR UPDATE
    SQL
  end

  def reaching_limit?(balance, limit_amount, amount)
    return false if (balance - amount) > limit_amount
    (balance - amount).abs > limit_amount
  end

  def db = Database.pool.checkout
end
