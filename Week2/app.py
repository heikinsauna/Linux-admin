import os
from datetime import datetime, timezone

import psycopg
from flask import Flask, jsonify, request

app = Flask(__name__)

DATABASE_URL = os.environ.get("DATABASE_URL")

if not DATABASE_URL:
	raise RuntimeError("DATABASE_URL env muuttuja puuttuu")

def get_db():
	return psycopg.connect(DATABASE_URL)

def init_database():
	with get_db() as conn:
		with conn.cursor() as cur:
			cur.execute("""
				CREATE TABLE IF NOT EXISTS visits (
					id BIGSERIAL PRIMARY KEY,
					visited_at TIMESTAMPTZ NOT NULL,
					path TEXT NOT NULL,
					user_agent TEXT
				)
			""")

@app.route("/viikko2/api/visit", methods=["POST"])
def register_visit():
	data = request.get_json(silent=True) or {}
	path = str(data.get("path", "/"))[:500]
	user_agent = request.headers.get("User-Agent","")[:500]

	visited_at = datetime.now(timezone.utc)
	with get_db() as conn:
		with conn.cursor() as cur:
			#tallennetaan vierailu
			cur.execute("""
				INSERT INTO visits (
					visited_at,
					path,
					user_agent
				)
				VALUES (%s, %s, %s)
			""", (
				visited_at,
				path,
				user_agent
			))

			#vierailujen laskenta
			cur.execute("""
				SELECT COUNT(*)
				FROM visits
			""")

			total = cur.fetchone()[0]

		return jsonfy({"status":"ok","visits":total})

@app.route("/viikko2/api/count", methods=["GET"])
def visit_count():
	with get_db() as conn:
		with conn.cursor() as cur:

			cur.execute("""
				SELECT COUNT(*)
				FROM visits
			""")

			total = cur.fetchone()[0]

		return jsonify({"visits": total})

init_database()

