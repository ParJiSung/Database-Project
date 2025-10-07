# app/web.py
from flask import Blueprint, jsonify
from sqlalchemy import text
from . import db   # ← import the module, not the variable
from flask import request
from .services import orders as orders_service
from flask import render_template
from .services import reports

bp = Blueprint("web", __name__)

@bp.get("/")
def index():
    return {"ok": True, "service": "pizza-api"}

@bp.get("/menu")
def menu():
    with db.SessionLocal() as s:  # ← now SessionLocal is initialized by init_db()
        rows = s.execute(text("SELECT * FROM v_menu ORDER BY pizza_name")).mappings().all()
        return jsonify([dict(r) for r in rows])
    
@bp.get("/menu/page")
def menu_page():
    from sqlalchemy import text
    from . import db
    with db.SessionLocal() as s:
        rows = s.execute(text("SELECT * FROM v_menu ORDER BY pizza_name")).mappings().all()
    return render_template("menu.html", rows=rows)

@bp.post("/orders")
def create_order():
    data = request.get_json(force=True)
    out = orders_service.place(data)
    return (out, 201) if out.get("ok") else (out, 400)

@bp.get("/reports/undelivered")
def r1(): return reports.undelivered()

@bp.get("/reports/top-pizzas")
def r2(): return reports.top_pizzas_last_month()

@bp.get("/reports/earnings")
def r3():
    by = request.args.get("by","postcode")
    return reports.earnings(by)