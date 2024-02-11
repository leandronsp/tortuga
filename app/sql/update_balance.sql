UPDATE balances 
SET amount = amount {{operation}} $2
WHERE account_id = $1
