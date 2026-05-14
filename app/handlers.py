from app.models import WhatsAppMessage
from app.whatsapp_client import send_text_message
import logging

logger = logging.getLogger(__name__)


async def handle_incoming_message(message: WhatsAppMessage, sender: str) -> None:
    """Process an incoming WhatsApp message and respond."""
    if message.type != "text" or not message.text:
        logger.info(f"Received non-text message of type '{message.type}' from {sender}")
        return

    text = message.text.body.strip().lower()
    logger.info(f"Message from {sender}: {text}")

    # Route based on message content — extend this with your own logic
    if text in ("hallo", "hi", "hey", "hello"):
        reply = "Hallo! Hoe kan ik je helpen?"
    elif text == "help":
        reply = "Stuur een bericht en ik reageer automatisch. Type 'stop' om je af te melden."
    elif text == "stop":
        reply = "Je bent afgemeld. Stuur 'hallo' om je opnieuw aan te melden."
    else:
        reply = f"Je stuurde: {message.text.body}\n\nType 'help' voor meer opties."

    await send_text_message(to=sender, message=reply)
