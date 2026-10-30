from flask import Flask
from flask_sqlalchemy import SQLAlchemy
from flask_marshmallow import Marshmallow
from flasgger import Swagger
from config import Config
from app.routes.leave_routes import leave_bp          
from app.routes.attendance_routes import attendance_bp 
from app.routes.candidate_routes import candidate_bp
from app.routes.employee_routes import employee_bp
from app.routes.report_routes import report_bp

db = SQLAlchemy()
ma = Marshmallow()
swagger = Swagger()

def create_app(config_class=Config):
    app = Flask(__name__)
    app.config.from_object(config_class)

    db.init_app(app)
    ma.init_app(app)
    swagger.init_app(app) # Ініціалізація Swagger UI

    with app.app_context():
        from app.models import models
    
    app.register_blueprint(employee_bp)
    app.register_blueprint(report_bp)
    app.register_blueprint(leave_bp)          
    app.register_blueprint(attendance_bp)    
    app.register_blueprint(candidate_bp)

    return app