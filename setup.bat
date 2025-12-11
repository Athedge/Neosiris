@echo off
python -m venv .venv
call .venv\Scripts\activate
pip install -r requirements_entretiens.txt
echo Setup terminé! Lance: .venv\Scripts\activate puis python src/Lexiris/main.py
pause