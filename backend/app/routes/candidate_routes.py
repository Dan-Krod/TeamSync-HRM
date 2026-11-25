from flask import Blueprint, request, jsonify
from app.models.models import Candidate
from app.schemas.schemas import candidate_schema, candidates_schema
from app.models.models import Vacancy
from app.schemas.schemas import vacancy_schema, vacancies_schema
from app import db
import re
from datetime import date
from app.models.models import Candidate, Vacancy, Employee, WorkSchedule
from app.services.onboarding_facade import OnboardingFacade

candidate_bp = Blueprint('candidate_bp', __name__, url_prefix='/api/candidates')

@candidate_bp.route('/', methods=['GET', 'POST'])
def handle_candidates():
    if request.method == 'GET':
        candidates = Candidate.query.all()
        return jsonify(candidates_schema.dump(candidates)), 200
    
    data = request.get_json()
    vacancy_id = data.get('vacancy_id')
    if vacancy_id is not None:
        vacancy = Vacancy.query.get(vacancy_id)
        if not vacancy:
            return jsonify({"error": "Вакансію не знайдено"}), 404
        if vacancy.status == 'closed':
            return jsonify({"error": "Вакансія вже закрита"}), 400

    new_candidate = Candidate(**data)
    db.session.add(new_candidate)
    db.session.commit()
    return jsonify(candidate_schema.dump(new_candidate)), 201

def _extract_salary(salary_range: str, default: float = 25000.0) -> float:
    if not salary_range:
        return default
    numbers = re.findall(r'\d+', salary_range.replace(' ', ''))
    return float(numbers[0]) if numbers else default


@candidate_bp.route('/<int:id>', methods=['PUT'])
def update_candidate(id):
    candidate = Candidate.query.get_or_404(id)
    data = request.get_json()
    old_status = candidate.status
    new_status = data.get('status')

    if new_status:
        candidate.status = new_status

    if new_status == 'hired' and old_status != 'hired':
        parts = (candidate.full_name or 'New Employee').strip().split(' ', 1)
        first_name = parts[0]
        last_name = parts[1] if len(parts) > 1 else 'Staff'

        vacancy = Vacancy.query.get(candidate.vacancy_id) if candidate.vacancy_id else None
        position = vacancy.title if vacancy else 'Спеціаліст'
        department_id = vacancy.department_id if (vacancy and vacancy.department_id) else 1
        salary = _extract_salary(vacancy.salary_range if vacancy else '')

        email = f"candidate{candidate.id}@staff.com"
        if not Employee.query.filter_by(email=email).first():
            emp_data = {
                'first_name': first_name,
                'last_name': last_name,
                'email': email,
                'phone': '+380000000000',
                'position': position,
                'salary': salary,
                'hire_date': date.today(),
                'role': 'user',
                'department_id': department_id,
            }
            new_emp = OnboardingFacade.onboard_new_employee(emp_data)
            if new_emp:
                new_emp.set_password('password123')
                if not WorkSchedule.query.filter_by(employee_id=new_emp.id).first():
                    db.session.add(WorkSchedule(employee_id=new_emp.id))

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

@candidate_bp.route('/vacancies', methods=['GET', 'POST'])
def handle_vacancies():
    if request.method == 'GET':
        status_filter = request.args.get('status')
        if status_filter:
            vacancies = Vacancy.query.filter_by(status=status_filter).all()
        else:
            vacancies = Vacancy.query.all()
        return jsonify(vacancies_schema.dump(vacancies)), 200
    
    data = request.get_json()
    new_vacancy = Vacancy(
        title=data['title'],
        salary_range=data.get('salary_range', ''),
        description=data.get('description', ''),
        status=data.get('status', 'open'),
        department_id=data.get('department_id')
    )
    db.session.add(new_vacancy)
    db.session.commit()
    return jsonify(vacancy_schema.dump(new_vacancy)), 201

@candidate_bp.route('/vacancies/<int:id>', methods=['PUT'])
def update_vacancy(id):
    vacancy = Vacancy.query.get_or_404(id)
    data = request.get_json()
    if 'status' in data:
        vacancy.status = data['status']
    db.session.commit()
    return jsonify(vacancy_schema.dump(vacancy)), 200