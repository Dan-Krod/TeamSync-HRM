from flask import Flask
from flask_sqlalchemy import SQLAlchemy
from flask_marshmallow import Marshmallow
from flasgger import Swagger
from configure import Config
from flask_cors import CORS
from flask_jwt_extended import JWTManager

db = SQLAlchemy()
ma = Marshmallow()
swagger = Swagger()

def create_app(config_class=Config):
    app = Flask(__name__)
    app.config.from_object(config_class)
    
    CORS(app)
    
    app.config['JWT_SECRET_KEY'] = 'super-secret-hrm-key-2026-very-secure' 
    wt = JWTManager(app)

    db.init_app(app)
    ma.init_app(app)
    swagger.init_app(app)

    with app.app_context():
        from app.models import models

    from app.routes.employee_routes import employee_bp
    from app.routes.report_routes import report_bp
    from app.routes.leave_routes import leave_bp
    from app.routes.attendance_routes import attendance_bp
    from app.routes.candidate_routes import candidate_bp
    from app.routes.auth_routes import auth_bp
    from app.routes.time_routes import time_bp
    from app.routes.document_routes import document_bp
    
    app.register_blueprint(employee_bp)
    app.register_blueprint(report_bp)
    app.register_blueprint(leave_bp)
    app.register_blueprint(attendance_bp)
    app.register_blueprint(candidate_bp)
    app.register_blueprint(auth_bp)
    app.register_blueprint(time_bp)
    app.register_blueprint(document_bp)

    return app