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
    result = {}

    db.transaction do 
      account = db.exec_params(sql_select_account, [@account_id]).first
      raise NotFoundError unless account

      result["saldo"] = {  
        "total": account['balance'].to_i,
        "data_extrato": Time.now.strftime("%Y-%m-%d"),
        "limite": account['limit_amount'].to_i
      }

      ten_transactions = db.exec_params(sql_ten_transactions, [@account_id])

      result["ultimas_transacoes"] = ten_transactions.map do |transaction|
        { 
          "valor": transaction['amount'].to_i,
          "tipo": transaction['transaction_type'],
          "descricao": transaction['description'],
          "realizada_em": transaction['date']
        }
      end
    end

    result
  end

  private 

  def sql_ten_transactions
    <<~SQL
      SELECT amount, transaction_type, description, date
      FROM transactions
      WHERE transactions.account_id = $1
      ORDER BY date DESC
      LIMIT 10
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
    SQL
  end

  def db = Database.pool.checkout
end
