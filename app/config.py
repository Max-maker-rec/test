from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    whatsapp_phone_number_id: str
    whatsapp_access_token: str
    whatsapp_verify_token: str
    host: str = "0.0.0.0"
    port: int = 8000

    class Config:
        env_file = ".env"


settings = Settings()
