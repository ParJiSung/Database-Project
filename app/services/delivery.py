from datetime import datetime, timedelta
from sqlalchemy import text
from ..db import get_session

COOLDOWN_MIN = 30

def assign_driver_for_postcode(postcode:str)->int|None:
    """
    1) Pick employees mapped in delivery_area for this postal_code.
    2) Exclude employees currently blocked by delivery_unavailable (now between start_time and end_time).
    3) Exclude employees who delivered within last 30 minutes (orders.deliveredat).
    4) Return the least-recently assigned (or lowest id) as a simple heuristic.
    """
    now = datetime.utcnow()
    with get_session() as s:
        eligible = s.execute(text("""
            SELECT e.idEmployee
            FROM employee e
            JOIN delivery_area da ON da.idemployee = e.idEmployee
            WHERE da.postal_code = :pc
        """), {"pc": postcode}).scalars().all()

        if not eligible: return None

        # filter: unavailable window
        filtered = []
        for eid in eligible:
            clash = s.execute(text("""
                SELECT 1 FROM delivery_unavailable
                WHERE idemployee=:e
                  AND :now BETWEEN start_time AND end_time
                LIMIT 1
            """), {"e": eid, "now": now}).first()
            if clash: 
                continue
            # cooldown: last delivered within 30 min
            last_delivered = s.execute(text("""
                SELECT MAX(STR_TO_DATE(deliveredat, '%Y-%m-%d %H:%i:%s'))
                FROM orders WHERE idemployee=:e AND deliveredat IS NOT NULL
            """), {"e": eid}).scalar()
            if last_delivered and (now - last_delivered) < timedelta(minutes=COOLDOWN_MIN):
                continue
            filtered.append(eid)

        return min(filtered) if filtered else None
