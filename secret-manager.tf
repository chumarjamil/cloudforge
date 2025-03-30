resource "aws_secretsmanager_secret" "development-api" {
  count = 0
  name = "test"
}

# The map here can come from other supported configurations
# like locals, resource attribute, map() built-in, etc.
variable "development-api" {
  default = {
    DB_HOST = ""
    DB_USER = ""
    DB_PASSWORD = ""
    DB_DATABASE = ""
    SESSION_SECURE_COKE = ""
    SESSION_SECREET = ""
    SESSION_RESAVE = ""
    SESSION_SAVE_UNINITIAlIZED = ""
    API_PHP = ""
    FRONT_URL = ""
    MID_PRODUCTION = ""
    SERVER_KEY = ""
    CLIENT_KEY = ""
    SESSION_ID = ""
    TOKEN_UTAMA = ""
    MEMBERS_ID = ""
    API_URL = ""
    XENDIR_URL = ""
    XENDIT_PASSWORD = ""
    XENDIT_ID = ""
    API_INSTANT_DELIVERY = ""
    OUTLET_API_PHP = ""
  }

  type = map(string)
}

resource "aws_secretsmanager_secret_version" "development-api" {
  count = 0
  secret_id     = aws_secretsmanager_secret.development-api[0].id
  secret_string = jsonencode(var.development-api)
}
