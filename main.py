import logging
import uvicorn
from fastapi import FastAPI
from app.routes import router
from app.config import settings

logging.basicConfig(level=logging.INFO, format="%(asctime)s %(levelname)s %(message)s")

app = FastAPI(title="WhatsApp Automation", version="1.0.0")
app.include_router(router)


if __name__ == "__main__":
    uvicorn.run("main:app", host=settings.host, port=settings.port, reload=True)
