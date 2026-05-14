# Meta WhatsApp Business API — Setup Gids

Volg deze stappen om je WhatsApp API-toegang te activeren.
Geschatte tijd: **10–15 minuten**.

---

## Stap 1 — Meta developer account aanmaken

1. Ga naar **https://developers.facebook.com**
2. Klik rechtsboven op **"Log In"** en log in met je Facebook-account
3. Als je nog geen developer account hebt:
   - Klik op **"Get Started"**
   - Accepteer de gebruiksvoorwaarden
   - Bevestig je e-mailadres als dat gevraagd wordt

---

## Stap 2 — Nieuwe app aanmaken

1. Klik rechtsboven op **"My Apps"**
2. Klik op de groene knop **"Create App"**
3. Kies als app-type: **"Business"** → klik **"Next"**
4. Vul in:
   - **App name**: bijv. `WhatsApp Automation`
   - **App contact email**: jouw e-mailadres
   - **Business account**: kies je bedrijf (of maak er een aan)
5. Klik op **"Create App"**

---

## Stap 3 — WhatsApp toevoegen aan je app

1. Je ziet nu het **App Dashboard** met een lijst van producten
2. Zoek het blok **"WhatsApp"** en klik op **"Set Up"**
3. Kies of maak een **WhatsApp Business Account (WABA)**
4. Klik op **"Continue"**

---

## Stap 4 — Phone Number ID en Access Token ophalen

1. Ga in het linkermenu naar **WhatsApp → API Setup**
2. Je ziet nu twee belangrijke waarden:

   | Gegeven | Waar te vinden |
   |---|---|
   | **Phone Number ID** | Onder "From" — een lang nummer zoals `123456789012345` |
   | **Temporary Access Token** | Klik op **"Generate"** — begint met `EAAG...` |

3. Kopieer beide waarden — je hebt ze nodig in `setup.sh`

> ⚠️ De **Temporary Access Token** verloopt na 24 uur.
> Voor productie gebruik je een **permanent token** (zie Stap 7).

---

## Stap 5 — Webhook instellen

1. Ga naar **WhatsApp → Configuration** in het linkermenu
2. Klik op **"Edit"** naast het Webhook-veld
3. Vul in:
   - **Callback URL**: de URL die `start.sh` print, bijv.
     `https://abcd1234.ngrok.io/webhook`
   - **Verify Token**: het token dat je zelf hebt gekozen in `setup.sh`
     (bijv. `mijn-geheime-token`)
4. Klik op **"Verify and Save"**
   - Als het goed gaat zie je een groen vinkje ✓
   - Werkt het niet? Controleer of `start.sh` actief is

5. Klik onder **"Webhook Fields"** op **"Manage"**
6. Zet **"messages"** op **Subscribed** ✓
7. Klik **"Done"**

---

## Stap 6 — Testnummer toevoegen en eerste bericht sturen

1. Ga naar **WhatsApp → API Setup**
2. Scroll naar **"To"** → klik op **"Manage phone number list"**
3. Voeg je eigen telefoonnummer toe (met landcode, bijv. `+31612345678`)
4. Je ontvangt een WhatsApp-bericht met een verificatiecode — voer die in
5. Klik op **"Send Message"** om een testbericht te sturen
6. Check je WhatsApp — je zou nu een bericht moeten ontvangen ✓

---

## Stap 7 — Permanent Access Token aanmaken (voor productie)

De tijdelijke token verloopt na 24 uur. Maak een permanente aan:

1. Ga naar **https://business.facebook.com/settings**
2. Klik links op **"System Users"** (onder Gebruikers)
3. Klik op **"Add"** → geef de system user een naam (bijv. `whatsapp-bot`)
   en rol **"Admin"**
4. Klik op **"Generate New Token"**
5. Kies je app en selecteer de permissies:
   - `whatsapp_business_messaging`
   - `whatsapp_business_management`
6. Klik **"Generate Token"** en kopieer de token
7. Vervang de token in je `.env`:
   ```
   WHATSAPP_ACCESS_TOKEN=jouw_permanente_token
   ```
8. Herstart de server: `./start.sh`

---

## Samenvatting — wat heb je nodig?

| Variabele | Voorbeeld waarde |
|---|---|
| `WHATSAPP_PHONE_NUMBER_ID` | `123456789012345` |
| `WHATSAPP_ACCESS_TOKEN` | `EAAG...` (permanent token) |
| `WHATSAPP_VERIFY_TOKEN` | Zelf gekozen, bijv. `mijn-geheime-token` |

---

## Problemen?

| Probleem | Oplossing |
|---|---|
| Webhook verificatie mislukt | Controleer of `start.sh` actief is en de ngrok URL klopt |
| Geen berichten ontvangen | Controleer of "messages" gesubscribed is in Webhook Fields |
| Token verlopen | Genereer een nieuw token (Stap 4) of gebruik een permanent token (Stap 7) |
| ngrok URL verandert | Ngrok gratis versie geeft elke keer een nieuwe URL — update de webhook in Meta |
