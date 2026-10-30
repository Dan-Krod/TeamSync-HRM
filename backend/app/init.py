from flask import Flask
from flask_sqlalchemy import SQLAlchemy
from flask_marshmallow import Marshmallow
from config import Config
from app.routes.employee_routes import employee_bp
from app.routes.employee_routes import employee_bp
from app.routes.report_routes import report_bp

db = SQLAlchemy()
ma = Marshmallow()

def create_app(config_class=Config):
    app = Flask(__name__)
    app.config.from_object(config_class)

    db.init_app(app)
    ma.init_app(app)
    
    with app.app_context():
        from app.models import models
        
    app.register_blueprint(employee_bp)
    app.register_blueprint(employee_bp)
    app.register_blueprint(report_bp)

    @app.route('/api/health')
    def health_check():
        return {"status": "success", "message": "StaffFlow API is running"}

    return app