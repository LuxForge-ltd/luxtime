"""LuxTime FastAPI entry point and compiled frontend host."""

from __future__ import annotations

import time
from contextlib import asynccontextmanager
from pathlib import Path

from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import FileResponse, JSONResponse
from fastapi.staticfiles import StaticFiles
from foundry.logger import logger
from foundry.postgres import PostgresError

from app import __version__
from app.api.router import router
from app.config import AppConfig
from app.core.errors import DomainError
from app.data.database import Database

log = logger.bind(component="luxtime.api", version=__version__)

_PING_RETRY_DELAYS_SECONDS = (1, 2, 4, 8, 15)


def _ping_with_retry(database: Database) -> bool:
    """Retry the startup connectivity check with backoff.

    Postgres can still be finishing its own startup/recovery when this
    container starts (e.g. right after a host restart), which briefly
    rejects connections rather than refusing them outright. A single failed
    attempt here shouldn't be treated as "database unavailable" for the
    life of the process.
    """
    last_error: Exception | None = None
    for attempt, delay in enumerate((0, *_PING_RETRY_DELAYS_SECONDS), start=1):
        if delay:
            time.sleep(delay)
        try:
            if database.ping():
                return True
        except Exception as error:  # noqa: BLE001 - defensive startup guard
            last_error = error
            log.warning(
                "Database ping failed during startup, will retry",
                attempt=attempt,
                error=str(error),
            )
    if last_error is not None:
        log.error("Database unreachable after startup retries", error=str(last_error))
    return False


def create_app(config: AppConfig | None = None) -> FastAPI:
    application_config = config or AppConfig.from_environment()

    @asynccontextmanager
    async def lifespan(_: FastAPI):
        database = Database.from_config(application_config)
        try:
            connected = _ping_with_retry(database)
            log.info("LuxTime API starting", database_connected=connected)
        finally:
            database.close()
        yield
        log.info("LuxTime API stopped")

    application = FastAPI(
        title="LuxTime API",
        version=__version__,
        docs_url="/api/docs",
        openapi_url="/api/openapi.json",
        lifespan=lifespan,
    )
    application.state.config = application_config
    application.add_middleware(
        CORSMiddleware,
        allow_origins=list(application_config.allowed_origins),
        allow_credentials=False,
        allow_methods=["*"],
        allow_headers=["*"],
    )
    application.include_router(router)

    @application.exception_handler(DomainError)
    async def domain_error_handler(_: Request, error: DomainError) -> JSONResponse:
        return JSONResponse(status_code=error.status_code, content={"detail": error.message})

    @application.exception_handler(PostgresError)
    async def database_error_handler(_: Request, error: PostgresError) -> JSONResponse:
        log.error("Database operation failed", error_type=type(error).__name__)
        return JSONResponse(status_code=503, content={"detail": "Database unavailable"})

    web_dist = Path(application_config.web_dist)
    assets = web_dist / "assets"
    if assets.is_dir():
        application.mount("/assets", StaticFiles(directory=assets), name="web-assets")

    @application.get("/{path:path}", include_in_schema=False, response_model=None)
    def frontend(path: str) -> FileResponse | JSONResponse:
        if path.startswith("api/"):
            return JSONResponse(status_code=404, content={"detail": "Not found"})
        index = web_dist / "index.html"
        if not index.is_file():
            return JSONResponse(
                status_code=503,
                content={"detail": "LuxTime frontend has not been built"},
            )
        return FileResponse(index)

    return application


app = create_app()
