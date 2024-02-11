WITH ten_transactions AS (
    SELECT * FROM transactions 
    WHERE account_id = $1
    ORDER BY date DESC
    LIMIT 10
)
SELECT 
  json_build_object('saldo', json_build_object(
    'total', balances.amount,
    'data_extrato', NOW()::date,
    'limite', accounts.limit_amount,
    'ultimas_transacoes', 
      CASE 
      WHEN COUNT(transactions) = 0 THEN '[]'
      ELSE
        json_agg(
          json_build_object(
            'valor', transactions.amount,
            'tipo', transactions.transaction_type,
            'descricao', transactions.description,
            'realizada_em', transactions.date::date
          )
        )
      END
  ))
FROM accounts
LEFT JOIN balances ON balances.account_id = accounts.id
LEFT JOIN ten_transactions AS transactions ON transactions.account_id = accounts.id
WHERE accounts.id = $1
GROUP BY accounts.id, balances.amount, accounts.limit_amount
