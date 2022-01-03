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

# TODO: add variable validation block (regex)
variable "nyt_cookie" {
  sensitive   = true
  description = <<-EOT
    Cookie string copied from an authenticated NYT session. 
    Should be in the format of "nyt-a:somevalue; NYT-S:somevalue; nyt-auth-method:somevalue; nyt-m:somevalue;"

    This will need to be updated once every 365 days.
  EOT
}

locals {
  name = "nyt-cw-dl-dbx"
}
