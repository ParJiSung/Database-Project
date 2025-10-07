Just plug in this shit looool:

Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\.venv\Scripts\Activate.ps1
$env:FLASK_APP="app:create_app"
flask run
