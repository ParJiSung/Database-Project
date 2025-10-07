from flask import Flask
from pathlib import Path
from .db import init_db
from .web import bp as web_bp

def create_app():
    tmpl_path = Path(__file__).parent / "templates"   # -> app/templates
    app = Flask(__name__, template_folder=str(tmpl_path))
    init_db(app)
    app.register_blueprint(web_bp)
    return app
