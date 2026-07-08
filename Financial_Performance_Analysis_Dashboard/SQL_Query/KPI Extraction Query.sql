DROP DATABASE IF EXISTS financial_performance_analysis;
CREATE DATABASE financial_performance_analysis;
USE financial_performance_analysis;

DROP TABLE IF EXISTS transactions;
DROP TABLE IF EXISTS budget;
DROP TABLE IF EXISTS accounts;

CREATE TABLE transactions (
    id INT PRIMARY KEY,
    date DATE,
    cod_account INT,
    account VARCHAR(255),
    short_class VARCHAR(50),
    class VARCHAR(255),
    transaction_type VARCHAR(100),
    name VARCHAR(255),
    memodescription TEXT,
    revenueexpenses VARCHAR(50),
    amount DECIMAL(18,2)
);

CREATE TABLE budget (
    id INT PRIMARY KEY,
    date DATE,
    cod_account INT,
    account VARCHAR(255),
    short_class VARCHAR(50),
    class VARCHAR(255),
    revenueexpenses VARCHAR(50),
    budget DECIMAL(18,2)
);

CREATE TABLE accounts (
    id INT PRIMARY KEY,
    cod_account INT,
    account VARCHAR(255),
    revenueexpenses VARCHAR(50),
    level_01 VARCHAR(255),
    level_02 VARCHAR(255),
    level_03 VARCHAR(255)
);

SELECT * FROM transactions LIMIT 10;
SELECT * FROM budget LIMIT 10;
SELECT * FROM accounts LIMIT 10;

-- KPIs Extraction 

-- Revenue & Profit Analysis KPI

SELECT
    SUM(CASE 
            WHEN revenueexpenses = 'REVENUE'
            THEN amount
            ELSE 0
        END) AS total_revenue,

    SUM(CASE 
            WHEN revenueexpenses = 'EXPENSES'
            THEN amount
            ELSE 0
        END) AS total_expenses,

    SUM(CASE 
            WHEN revenueexpenses = 'REVENUE'
            THEN amount
            ELSE 0
        END)
    -
    SUM(CASE 
            WHEN revenueexpenses = 'EXPENSES'
            THEN amount
            ELSE 0
        END) AS net_profit

FROM transactions;


-- Expense Analysis
SELECT
    account,
    SUM(amount) AS total_expense
FROM transactions
WHERE revenueexpenses = 'EXPENSES'
GROUP BY account
ORDER BY total_expense DESC;

-- Budget vs Actuals
SELECT
    b.account,

    b.budget,

    COALESCE(SUM(t.amount),0) AS actual_amount,

    COALESCE(SUM(t.amount),0) - b.budget AS variance

FROM budget b

LEFT JOIN transactions t
ON b.cod_account = t.cod_account

GROUP BY b.account, b.budget

ORDER BY variance DESC;

-- Financial Ratios

SELECT

ROUND(
(
(
SUM(CASE WHEN revenueexpenses = 'REVENUE' THEN amount ELSE 0 END)
-
SUM(CASE WHEN revenueexpenses = 'EXPENSES' THEN amount ELSE 0 END)
)
/
SUM(CASE WHEN revenueexpenses = 'REVENUE' THEN amount ELSE 0 END)
) * 100,
2
) AS profit_margin_percentage,

ROUND(
(
SUM(CASE WHEN revenueexpenses = 'EXPENSES' THEN amount ELSE 0 END)
/
SUM(CASE WHEN revenueexpenses = 'REVENUE' THEN amount ELSE 0 END)
) * 100,
2
) AS expense_ratio_percentage

FROM transactions;

-- YOY / Monthly Trend

SELECT
    YEAR(date) AS year,
    MONTH(date) AS month,

    SUM(CASE 
            WHEN revenueexpenses = 'REVENUE'
            THEN amount
            ELSE 0
        END) AS monthly_revenue,

    SUM(CASE 
            WHEN revenueexpenses = 'EXPENSES'
            THEN amount
            ELSE 0
        END) AS monthly_expenses,

    SUM(CASE 
            WHEN revenueexpenses = 'REVENUE'
            THEN amount
            ELSE 0
        END)

    -

    SUM(CASE 
            WHEN revenueexpenses = 'EXPENSES'
            THEN amount
            ELSE 0
        END) AS monthly_profit

FROM transactions

GROUP BY YEAR(date), MONTH(date)

ORDER BY year, month;

