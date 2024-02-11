SELECT 
  accounts.limit_amount AS limit_amount,
  balances.amount AS balance
FROM accounts 
JOIN balances ON balances.account_id = accounts.id
WHERE accounts.id = $1
FOR UPDATE
