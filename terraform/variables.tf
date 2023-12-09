variable "bot_name" {
  type    = string
  default = "the_journal-mastodon-bot"
}

variable "masto_api_base_url" {
  type    = string
  default = "https://botsin.space"
}

variable "masto_access_token" {
  type        = string
  description = "Mastodon access token. Set in terraform.tfvars"
}

variable "feed_url" {
  type    = string
  default = "http://thejournal.ie/feed"
}
