import io
from flask import Blueprint, send_file, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from app.models.models import Employee
from app.services.document_factory import HRDocumentFactory

document_bp = Blueprint('document_bp', __name__, url_prefix='/api/documents')

@document_bp.route('/generate/<int:emp_id>', methods=['GET'])
@jwt_required()
def generate_document(emp_id):
    """
    Генерація PDF документа (contract або order)
    Приклад: /api/documents/generate/1?type=contract
    """
    current_user = get_jwt_identity()
    
    # Працівник може генерувати лише свої документи, HR/Admin - будь-чиї
    if current_user['role'] not in ['hr', 'admin'] and current_user['id'] != emp_id:
        return jsonify({"error": "Немає прав доступу"}), 403

    doc_type = request.args.get('type', 'contract')
    emp = Employee.query.get_or_404(emp_id)

    try:
        doc = HRDocumentFactory.create_document(doc_type, emp)
        pdf_bytes, filename = doc.generate_pdf()
        
        return send_file(
            io.BytesIO(pdf_bytes),
            download_name=filename,
            as_attachment=True,
            mimetype='application/pdf'
        )
    except Exception as e:
        return jsonify({"error": str(e)}), 400