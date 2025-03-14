resource "random_password" "password" {
  length           = 32
  special          = true
  upper            = true
  numeric          = true
  override_special = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789@#$%^&*()-=+[]{}|;:'\",.<>?/"
}