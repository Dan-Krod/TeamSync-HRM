import io
import json
from flask import Blueprint, send_file, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from app.models.models import Document
from app.services.document_factory import HRDocumentFactory
from app.repositories.employee_repository import SQLEmployeeRepository
from app.repositories.document_repository import SQLDocumentRepository

document_bp = Blueprint('document_bp', __name__, url_prefix='/api/documents')

@document_bp.route('/generate/<int:emp_id>', methods=['GET'])
@jwt_required()
def generate_document(emp_id):
    current_user = json.loads(get_jwt_identity())
    
    if current_user['role'] not in ['hr', 'admin'] and current_user['id'] != emp_id:
        return jsonify({"error": "Немає прав доступу"}), 403

    doc_type = request.args.get('type', 'contract')
    emp_repo = SQLEmployeeRepository()
    doc_repo = SQLDocumentRepository()

    emp = emp_repo.findById(emp_id)
    if not emp:
        return jsonify({"error": "Співробітника не знайдено"}), 404

    try:
        doc = HRDocumentFactory.create_document(doc_type, emp)
        pdf_bytes, filename = doc.generate_pdf()
        
        virtual_path = f"/storage/documents/{emp.id}/{filename}"
        new_doc_record = Document(
            employee_id=emp.id,
            doc_type=doc_type,
            file_path=virtual_path
        )
        doc_repo.save(new_doc_record)
        
        return send_file(
            io.BytesIO(pdf_bytes),
            download_name=filename,
            as_attachment=True,
            mimetype='application/pdf'
        )
    except Exception as e:
        return jsonify({"error": str(e)}), 400