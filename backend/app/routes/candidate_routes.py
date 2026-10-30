from flask import Blueprint, request, jsonify
from app.models.models import Candidate
from app.schemas.schemas import candidate_schema, candidates_schema
from app import db

candidate_bp = Blueprint('candidate_bp', __name__, url_prefix='/api/candidates')

@candidate_bp.route('/', methods=['GET', 'POST'])
def handle_candidates():
    """
    Управління кандидатами
    ---
    responses:
      200:
        description: Список кандидатів отримано або кандидата створено
    """
    if request.method == 'GET':
        candidates = Candidate.query.all()
        return jsonify(candidates_schema.dump(candidates)), 200
    
    data = request.get_json()
    new_candidate = Candidate(**data)
    db.session.add(new_candidate)
    db.session.commit()
    return jsonify(candidate_schema.dump(new_candidate)), 201