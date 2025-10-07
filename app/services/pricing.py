from sqlalchemy import text
from ..db import get_session

def price_for_pizza(pizza_id:int):
    with get_session() as s:
        row = s.execute(text("SELECT price FROM v_pizza_price WHERE idPizza=:id"),
                        {"id": pizza_id}).scalar_one()
        return float(row)
