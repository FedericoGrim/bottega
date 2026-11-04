# Python

## Ambiente virtuale e pacchetti

| Comando | Cosa fa |
| --- | --- |
| `python3 -m venv .venv` | crea l'ambiente virtuale |
| `source .venv/bin/activate` | attiva l'ambiente |
| `deactivate` | esce dall'ambiente |
| `pip install nome` | installa un pacchetto |
| `pip install -r requirements.txt` | installa le dipendenze del progetto |
| `pip freeze > requirements.txt` | salva le versioni installate |
| `pip list --outdated` | pacchetti da aggiornare |

## uv

| Comando | Cosa fa |
| --- | --- |
| `uv init mio-progetto` | crea un progetto |
| `uv add nome` | aggiunge un pacchetto |
| `uv sync` | installa le dipendenze |
| `uv run script.py` | esegue con l'ambiente del progetto |
| `uv run pytest` | esegue i test |
| `uv venv` | crea la cartella .venv |
| `uv add --dev pytest` | aggiunge un pacchetto solo per lo sviluppo |
| `uv remove nome` | rimuove un pacchetto |
| `uv tree` | albero delle dipendenze |
| `uv pip install nome` | come pip, ma molto più veloce |
| `uv python install 3.13` | installa una versione di Python |
| `uv python list` | versioni di Python disponibili |
| `uvx ruff check .` | esegue uno strumento senza installarlo |
| `uv self update` | aggiorna uv |

## Django

| Comando | Cosa fa |
| --- | --- |
| `django-admin startproject mio_sito .` | crea il progetto |
| `python manage.py startapp blog` | crea un'app |
| `python manage.py runserver` | avvia il server (localhost:8000) |
| `python manage.py makemigrations` | crea le migrazioni dai modelli |
| `python manage.py migrate` | applica le migrazioni |
| `python manage.py createsuperuser` | crea un utente admin |
| `python manage.py shell` | shell con il progetto caricato |
| `python manage.py test` | esegue i test |
| `python manage.py collectstatic` | raccoglie i file statici |

## FastAPI

| Comando | Cosa fa |
| --- | --- |
| `pip install "fastapi[standard]"` | installa FastAPI con gli strumenti |
| `fastapi dev main.py` | avvia in sviluppo con ricarica automatica |
| `uvicorn main:app --reload` | avvia con uvicorn e ricarica automatica |
| `uvicorn main:app --host 0.0.0.0 --port 8000` | avvia raggiungibile dalla rete |
| `/docs` | documentazione Swagger dell'API (nel browser) |

## Test e migrazioni (pytest, Alembic)

| Comando | Cosa fa |
| --- | --- |
| `pytest` | esegue i test |
| `pytest -k nome` | esegue solo i test che contengono nome |
| `pytest -x` | si ferma al primo errore |
| `alembic init migrations` | prepara Alembic |
| `alembic revision --autogenerate -m "messaggio"` | crea una migrazione dai modelli |
| `alembic upgrade head` | applica le migrazioni |
| `alembic downgrade -1` | annulla l'ultima migrazione |
