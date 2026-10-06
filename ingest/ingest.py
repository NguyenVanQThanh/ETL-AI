"""
File:        ingest.py
Description: Ingest Olist CSV files into Postgres schema `raw` (idempotent, P1.S1)

Created at:  2026-09-26
Created by:  claude
Updated at:  2026-10-03
Updated by:  thanh
"""
import os
from urllib.parse import quote_plus

import psycopg2
import config
import pandas as pd
from sqlalchemy import create_engine

def get_connection():
    # Connect to Postgres using config.py values, return connection
    return psycopg2.connect(
        host="localhost",
        port=config.POSTGRES_PORT,
        dbname=config.POSTGRES_DB,
        user=config.POSTGRES_USER,
        password=config.POSTGRES_PASSWORD,
    )


def ensure_raw_schema(conn) -> None:
    # CREATE SCHEMA IF NOT EXISTS raw
    with conn.cursor() as cur:
        cur.execute("CREATE SCHEMA IF NOT EXISTS raw")
    conn.commit()


CSV_TABLE_MAP = {
    # Map each CSV file in ingest/data/ to its target table name in raw
    # e.g. "olist_customers_dataset.csv": "customers",
    "olist_customers_dataset.csv": "customers",
    "olist_products_dataset.csv": "products",
    "olist_order_items_dataset.csv": "order_items",
    "olist_order_payments_dataset.csv": "order_payments",
    "olist_order_reviews_dataset.csv": "order_reviews",
    "olist_orders_dataset.csv": "orders",
    "olist_sellers_dataset.csv": "sellers",
    "olist_geolocation_dataset.csv": "geolocation",
    "product_category_name_translation.csv": "product_category_translation",
}


def load_csv_to_table(conn, csv_path: str, table_name: str) -> None:
    # Read CSV, write into raw.<table_name> (df.to_sql or COPY)
    df = pd.read_csv(csv_path, dtype=str)
    engine = create_engine(
        f"postgresql+psycopg2://{quote_plus(conn.info.user)}:{quote_plus(conn.info.password)}"
        f"@{conn.info.host}:{conn.info.port}/{conn.info.dbname}"
    )
    df.to_sql(table_name, engine, schema="raw", if_exists="replace", index=False)



def main() -> None:
    """
    main — Run the full Olist CSV → Postgres ingest pipeline.

    Process:
      1. Open a Postgres connection
      2. Ensure the `raw` schema exists
      3. For each CSV in CSV_TABLE_MAP: reload the table (replace = idempotent)
      4. Close the connection, log row counts loaded per table
    """
    # 1. Open a Postgres connection
    conn = get_connection()

    # 2. Ensure the `raw` schema exists
    ensure_raw_schema(conn)

    # 3. For each CSV in CSV_TABLE_MAP: reload the table (replace = idempotent)
    data_dir = os.path.join(os.path.dirname(__file__), "data", "olist")
    for csv_file, table_name in CSV_TABLE_MAP.items():
        load_csv_to_table(conn, os.path.join(data_dir, csv_file), table_name)

    # 4. Close the connection, log row counts loaded per table
    for table_name in CSV_TABLE_MAP.values():
        with conn.cursor() as cur:
            cur.execute(f'SELECT COUNT(*) FROM raw."{table_name}";')
            print(f'table: {table_name}	rows: {cur.fetchone()[0]}')
    conn.close()
    
if __name__ == "__main__":
    main()
