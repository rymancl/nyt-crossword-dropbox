variable "region" {
  default     = "us-east-1"
  description = "AWS region to deploy into."
}
variable "dropbox_path" {
  default     = "/Supernote/Document"
  description = "The path in Dropbox to upload files at."
}

variable "dropbox_token" {
  sensitive   = true
  description = "Dropbox API token."
}

variable "nyt_cookie" {
  sensitive = true
  type = object({
    nyt-a           = string
    NYT-S           = string
    nyt-auth-method = string
    nyt-m           = string
  })
  description = <<-EOT
    Cookie contents copied from an authenticated NYT session. 
    This will need to be updated once every 365 days.
  EOT
}

locals {
  name              = "nyt-cw-dl-dbx"
  nyt_cookie_string = "nyt-a=${var.nyt_cookie.nyt-a}; NYT-S=${var.nyt_cookie.NYT-S}; nyt-auth-method=${var.nyt_cookie.nyt-auth-method}; nyt-m=${var.nyt_cookie.nyt-m};"
}
