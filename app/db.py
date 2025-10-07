# app/db.py
import os
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from dotenv import load_dotenv

engine = None
SessionLocal = None

def init_db(app=None):
    global engine, SessionLocal
    load_dotenv()
    url = os.getenv("DB_URL", "mysql+pymysql://root:@localhost:3306/databaseproject")
    engine = create_engine(url, pool_pre_ping=True, future=True)
    SessionLocal = sessionmaker(bind=engine, autoflush=False, autocommit=False, future=True)

def get_session():
    if SessionLocal is None:
        raise RuntimeError("DB not initialized: call init_db() first")
    return SessionLocal()
