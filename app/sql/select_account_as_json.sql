SELECT 
  json_build_object(
    'limite', accounts.limit_amount,
    'saldo', balances.amount
  )
FROM accounts 
JOIN balances ON balances.account_id = accounts.id
WHERE accounts.id = $1
FOR UPDATE
