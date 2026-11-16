import io
from flask import render_template
from xhtml2pdf import pisa

class BaseDocument:
    def __init__(self, employee):
        self.employee = employee

    def _render_pdf(self, html_string):
        result = io.BytesIO()
        # Створюємо PDF з HTML-рядка
        pdf = pisa.pisaDocument(io.StringIO(html_string), result)
        if pdf.err:
            raise Exception("Помилка генерації PDF")
        return result.getvalue()

    def generate_pdf(self):
        raise NotImplementedError

class ContractDocument(BaseDocument):
    def generate_pdf(self):
        html_string = render_template('contract.html', emp=self.employee)
        pdf_bytes = self._render_pdf(html_string)
        return pdf_bytes, f"contract_{self.employee.last_name}.pdf"

class OrderDocument(BaseDocument):
    def generate_pdf(self):
        html_string = render_template('order.html', emp=self.employee)
        pdf_bytes = self._render_pdf(html_string)
        return pdf_bytes, f"order_{self.employee.last_name}.pdf"

class HRDocumentFactory:
    @staticmethod
    def create_document(doc_type, employee):
        if doc_type == 'contract':
            return ContractDocument(employee)
        elif doc_type == 'order':
            return OrderDocument(employee)
        else:
            raise ValueError("Невідомий тип документа")