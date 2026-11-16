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

@candidate_bp.route('/<int:id>', methods=['PUT'])
def update_candidate(id):
    """
    Оновити статус кандидата (наприклад, найнято або відмовлено)
    ---
    parameters:
      - in: path
        name: id
        required: true
        type: integer
      - in: body
        name: body
        required: true
        schema:
          type: object
          properties:
            status:
              type: string
    responses:
      200:
        description: Статус оновлено
    """
    candidate = Candidate.query.get_or_404(id)
    data = request.get_json()
    if 'status' in data:
        candidate.status = data['status']
    db.session.commit()
    return jsonify(candidate_schema.dump(candidate)), 200

@candidate_bp.route('/<int:id>', methods=['DELETE'])
def delete_candidate(id):
    """
    Видалити кандидата
    ---
    parameters:
      - in: path
        name: id
        required: true
        type: integer
    responses:
      200:
        description: Кандидата видалено
    """
    candidate = Candidate.query.get_or_404(id)
    db.session.delete(candidate)
    db.session.commit()
    return jsonify({"message": "Кандидата видалено"}), 200