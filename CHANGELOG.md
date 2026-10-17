# Changelog

Formato basado en [Keep a Changelog](https://keepachangelog.com/es-ES/1.1.0/) y versionado [SemVer](https://semver.org/lang/es/).
No existia CHANGELOG ni historial Git previo (el ZIP recibido no traia `.git`); el estado inicial es el commit
`baseline-lab` (6eb9b20). Las entradas se limitan a lo verificable en codigo: blueprints registrados, migraciones y tests.

## [0.1.0-rc.2] - 2026-10-17 (candidata de laboratorio, NO release formal)

### Added
- CI: `.github/workflows/ci.yml` (ruff, black, pytest, pip-audit informativo, empaquetado + SHA-256) y `scripts/ci_local.sh`
  (equivalente local con logs; NO es CI remoto).

### Fixed
- Lint: orden de imports en `scripts/create_db.py` (ruff I001). Sin cambio de comportamiento.

### Verificaciones
- CI local run02: ruff, black, pytest (33 passed), empaquetado y control de secretos en PASS.
- Pendiente (hallazgo informativo, ver plan de mantenimiento): `pip-audit` reporta 24 vulnerabilidades conocidas en 3 paquetes
  (PyJWT 2.10.1, marshmallow 3.23.2, Werkzeug 3.1.8).

## [0.1.0-rc.1] - 2026-10-17 (candidata de laboratorio, NO release formal)

Primera version etiquetada. Agrupa lo implementado en los Sprints 1-5 (segun `docs/roadmap/roadmap-sprints-restantes.md`
y verificado en archivos).

### Added
- Endpoint publico `GET /health`.
- Usuarios y autenticacion JWT: `POST /api/v1/usuarios/registro`, `POST /api/v1/usuarios/login`,
  `GET|PATCH /api/v1/usuarios/perfil`.
- Roles/autorizacion: `GET /api/v1/admin/usuarios` (solo admin); decoradores `requiere_token` / `requiere_admin`.
- CRUD de alojamientos: `POST|GET /api/v1/alojamientos`, `GET|PATCH|DELETE /api/v1/alojamientos/<id>`.
- Comodidades (N:M con alojamientos): `POST|GET /api/v1/comodidades`, `GET /api/v1/comodidades/<id>`,
  `PATCH /api/v1/alojamientos/<id>/comodidades`.
- 3 migraciones Alembic (usuarios/perfiles -> alojamientos -> comodidades) y 33 tests pytest.
- Empaquetado: `VERSION`, `Dockerfile`, `.dockerignore` (Dockerfile escrito, NO construido: sin daemon Docker en el entorno de practica).

### No incluido (documentado pero sin implementar)
- Sprints 6-10 (imagenes, reservas, busqueda/disponibilidad, favoritos, resenas): solo tienen documento en `docs/sprints/`.

### Compatibilidad
- Prefijo de API `/api/v1` (el valor `v1` de `/health` es la version de URL, no la version del paquete).
- Sin historial previo: no se puede afirmar compatibilidad con versiones anteriores.

### Verificaciones
- Linea base: `pytest` 33 passed (Python 3.13, SQLite en memoria). `ruff check`: 1 hallazgo (I001 en `scripts/create_db.py`) - pendiente. `black --check`: limpio.
