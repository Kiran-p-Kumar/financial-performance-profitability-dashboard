import pandas as pd
import os

# =========================================
# FILE PATHS
# =========================================

BASE_PATH = r"C:\Users\HP\Downloads\Data Analytics Projects\Final Projects\Financial_Performance_Analysis_Dashboard\Raw_Data"

transactions_file = os.path.join(BASE_PATH, "transactions.csv")
budget_file = os.path.join(BASE_PATH, "budget.csv")
accounts_file = os.path.join(BASE_PATH, "accounts.csv")

# =========================================
# CLEANING FUNCTION
# =========================================

def clean_dataframe(df):

    # Standardize column names
    df.columns = (
        df.columns
        .str.strip()
        .str.lower()
        .str.replace(" ", "_")
        .str.replace(r"[^a-zA-Z0-9_]", "", regex=True)
    )

    # Remove duplicate rows
    df = df.drop_duplicates()

    # Trim string columns
    for col in df.select_dtypes(include='object').columns:
        df[col] = df[col].astype(str).str.strip()

    # Replace common null-like values
    df.replace(
        ["", " ", "NA", "N/A", "null", "None", "-"],
        pd.NA,
        inplace=True
    )

    return df

# =========================================
# LOAD FILES
# =========================================

transactions_df = pd.read_csv(transactions_file)
budget_df = pd.read_csv(budget_file)
accounts_df = pd.read_csv(accounts_file)

# =========================================
# APPLY CLEANING
# =========================================

transactions_df = clean_dataframe(transactions_df)
budget_df = clean_dataframe(budget_df)
accounts_df = clean_dataframe(accounts_df)

# =========================================
# DATE COLUMN CLEANING
# =========================================

date_columns = ['date']

for col in date_columns:

    if col in transactions_df.columns:
        transactions_df[col] = pd.to_datetime(
            transactions_df[col],
            errors='coerce'
        )

    if col in budget_df.columns:
        budget_df[col] = pd.to_datetime(
            budget_df[col],
            errors='coerce'
        )

# =========================================
# EXPORT CLEAN FILES
# =========================================

transactions_df.to_csv(
    os.path.join(BASE_PATH, "transactions_clean.csv"),
    index=False,
    encoding="utf-8"
)

budget_df.to_csv(
    os.path.join(BASE_PATH, "budget_clean.csv"),
    index=False,
    encoding="utf-8"
)

accounts_df.to_csv(
    os.path.join(BASE_PATH, "accounts_clean.csv"),
    index=False,
    encoding="utf-8"
)

# =========================================
# SUMMARY
# =========================================

print("\n Data Cleaning Completed Successfully!")

print("\n Transactions Shape :", transactions_df.shape)
print(" Budget Shape       :", budget_df.shape)
print(" Accounts Shape     :", accounts_df.shape)

print("\n Clean CSV Files Exported Successfully!")