"""
File:        config.py
Description: Load Postgres connection config from .env with local-dev defaults

Created at:  2026-09-26
Created by:  claude
Updated at:  2026-09-26
Updated by:  claude
"""
import os

from dotenv import load_dotenv

load_dotenv()

POSTGRES_USER = os.getenv("POSTGRES_USER", "postgres")
POSTGRES_PASSWORD = os.getenv("POSTGRES_PASSWORD", "postgres")
POSTGRES_DB = os.getenv("POSTGRES_DB", "olist")
POSTGRES_PORT = os.getenv("POSTGRES_PORT", "5432")
