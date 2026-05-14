from fastapi import APIRouter, Query, Request, HTTPException
from app.config import settings
from app.models import WhatsAppWebhookPayload
from app.handlers import handle_incoming_message
import logging

router = APIRouter()
logger = logging.getLogger(__name__)


@router.get("/webhook")
async def verify_webhook(
    hub_mode: str = Query(alias="hub.mode"),
    hub_verify_token: str = Query(alias="hub.verify_token"),
    hub_challenge: str = Query(alias="hub.challenge"),
):
    """Meta webhook verification handshake."""
    if hub_mode == "subscribe" and hub_verify_token == settings.whatsapp_verify_token:
        return int(hub_challenge)
    raise HTTPException(status_code=403, detail="Verification failed")


@router.post("/webhook")
async def receive_webhook(request: Request):
    """Receive and process incoming WhatsApp messages."""
    try:
        body = await request.json()
        payload = WhatsAppWebhookPayload(**body)
    except Exception as exc:
        logger.warning(f"Invalid webhook payload: {exc}")
        raise HTTPException(status_code=400, detail="Invalid payload")

    for entry in payload.entry:
        for change in entry.changes:
            if change.field != "messages":
                continue
            messages = change.value.messages or []
            contacts = change.value.contacts or []
            sender = contacts[0].wa_id if contacts else None
            for message in messages:
                await handle_incoming_message(message, sender or message.from_)

    # Always return 200 so Meta stops retrying
    return {"status": "ok"}
