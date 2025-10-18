# app/web.py
import logging
from flask import Blueprint, jsonify, render_template, request, current_app
import json
from sqlalchemy import text
from . import db
from .services import orders as orders_service, reports as reports_service


# ---- logging setup ----
logger = logging.getLogger("pizza")
if not logger.handlers:
    logging.basicConfig(level=logging.INFO, format="%(asctime)s [%(levelname)s] %(message)s")

bp = Blueprint("web", __name__)

def _form_as_dict(req):
    d = {}
    for k in req.form.keys():
        vals = req.form.getlist(k)
        d[k] = ",".join(vals) if len(vals) > 1 else (vals[0] if vals else None)
    return d

@bp.before_app_request
def _log_request():
    try:
        if request.method in ("POST", "PUT", "PATCH"):
            if request.is_json:
                logger.info("REQ %s %s JSON=%s", request.method, request.path, json.dumps(request.get_json(silent=True)))
            else:
                logger.info("REQ %s %s FORM=%s", request.method, request.path, _form_as_dict(request))
        else:
            logger.info("REQ %s %s", request.method, request.path)
    except Exception as e:
        logger.warning("Failed to log request: %s", e)

@bp.errorhandler(Exception)
def _any_error(e):
    logger.exception("UNCAUGHT ERROR on %s %s: %s", request.method, request.path, e)
    if request.path.startswith("/ui/"):
        return render_template("receipt.html", res={"ok": False, "msg": str(e)}, payload={}), 500
    return jsonify({"ok": False, "error": str(e)}), 500

# ---------- health / debug ----------
@bp.get("/debug/ping")
def debug_ping():
    return {"ok": True, "time": datetime.utcnow().isoformat()}

@bp.get("/")
def index():
    return {"ok": True, "service": "pizza-api"}

# ---------- JSON API ----------
@bp.get("/menu")
def menu():
    sql = """
    SELECT idPizza, pizza_name, CAST(price AS DOUBLE) AS price, is_vegetarian, is_vegan
    FROM v_menu
    ORDER BY pizza_name
    """
    with db.SessionLocal() as s:
        rows = s.execute(text(sql)).mappings().all()
    return jsonify([dict(r) for r in rows])

@bp.post("/orders")
def api_create_order():
    data = request.get_json(force=True, silent=False)
    logger.info("API /orders payload: %s", json.dumps(data))
    out = orders_service.place(data)            # <— call the function you actually have
    logger.info("API /orders result: %s", json.dumps(out))
    return (out, 201) if out.get("ok") else (out, 400)

@bp.get("/reports/undelivered")
def api_reports_undelivered():
    return jsonify(reports_service.undelivered())

@bp.get("/reports/top-pizzas")
def api_reports_top_pizzas():
    return jsonify(reports_service.top_pizzas_last_month())

@bp.get("/reports/earnings")
def api_reports_earnings():
    by = request.args.get("by", "postcode")
    return jsonify(reports_service.earnings(by))

# ---------- UI ----------
@bp.get("/ui")
def ui_home():
    return render_template("home.html")

@bp.get("/ui/menu")
def ui_menu():
    with db.SessionLocal() as s:
        rows = s.execute(text("""
            SELECT idPizza, pizza_name, CAST(price AS DOUBLE) AS price, is_vegetarian, is_vegan
            FROM v_menu ORDER BY pizza_name
        """)).mappings().all()
    return render_template("menu.html", rows=rows)

@bp.get("/ui/order")
def ui_order_form():
    with db.SessionLocal() as s:
        pizzas = s.execute(text("""
            SELECT idPizza, pizza_name, CAST(price AS DOUBLE) AS price
            FROM v_menu ORDER BY pizza_name
        """)).mappings().all()
        products = s.execute(text("SELECT idproduct, name FROM product ORDER BY name")).mappings().all()
        customers = s.execute(text("SELECT idCustomer FROM customer ORDER BY idCustomer")).mappings().all()
    return render_template("order.html", pizzas=pizzas, products=products, customers=customers)

@bp.post("/ui/order")
def ui_order_submit():
    def parse_multi(name: str):
        vals = request.form.getlist(name)
        if len(vals) == 1 and ',' in vals[0]:
            vals = [v.strip() for v in vals[0].split(',') if v.strip()]
        return vals

    current_app.logger.info("POST /ui/order form=%s", dict(request.form))

    mode = request.form.get("mode", "existing")
    code_raw = request.form.get("discount_code")
    try: discount_code = int(code_raw) if code_raw else None
    except ValueError: discount_code = None

    with db.SessionLocal() as s, s.begin():
        if mode == "new":
            new_id = s.execute(text("SELECT COALESCE(MAX(idCustomer),0)+1 FROM customer")).scalar_one()
            first = (request.form.get("new_first_name") or "").strip() or "(unknown)"
            last  = (request.form.get("new_last_name")  or "").strip() or "(unknown)"
            s.execute(text("""
                INSERT INTO customer
                  (idCustomer, first_name, last_name, birthdate, postcode, city, street, `number`, createdat)
                VALUES
                  (:id, :first, :last, :bd, :pc, :ct, :st, :nr, CURDATE())
            """), {
                "id": new_id,
                "first": first, "last": last,
                "bd": request.form["new_birthdate"],
                "pc": request.form["new_postcode"],
                "ct": request.form["new_city"],
                "st": request.form["new_street"],
                "nr": request.form["new_number"],
            })
            customer_id = new_id
        else:
            customer_id = int(request.form["customer_id"])

    pizzas = []
    for pid in parse_multi("pizzas"):
        qty = int(request.form.get(f"qty_p_{pid}", "0") or 0)
        if qty > 0:
            pizzas.append({"id": int(pid), "qty": qty})

    products = []
    for pr in parse_multi("products"):
        qty = int(request.form.get(f"qty_prod_{pr}", "0") or 0)
        if qty > 0:
            products.append({"id": int(pr), "qty": qty})

    payload = {"customer_id": customer_id, "pizzas": pizzas, "products": products, "discount_code": discount_code}
    current_app.logger.info("ORDER PAYLOAD -> %s", json.dumps(payload))

    # MUST exist in app/services/orders.py
    result = orders_service.place_order(payload)

    return render_template("receipt.html", res=result, payload=payload)

@bp.get("/ui/reports")
def ui_reports():
    undel = reports_service.undelivered()
    top3 = reports_service.top_pizzas_last_month()
    earn = reports_service.earnings("postcode")
    try:
        top_products = reports_service.top_products_last_month(10)
    except Exception:
        top_products = []
    return render_template("reports.html", undel=undel, top3=top3, earn=earn, top_products=top_products)
