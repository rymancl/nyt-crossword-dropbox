# nyt-crossword-dropbox
Automated NYT crossword to Dropbox downloader, built with AWS.

* [Inspiration](https://old.reddit.com/r/Supernote/comments/rulnnb/how_i_automatically_upload_the_daily_nyt)
* All credit to [Nathan Buchar](https://github.com/nathanbuchar) for the Node JS code
  * [Blog post](https://nathanbuchar.com/automatically-uploading-the-nyt-crossword-supernote/)

## Requirements
* AWS account
* Dropbox account + [API token](https://dropbox.tech/developers/generate-an-access-token-for-your-own-account)
* New York Times Games [subscription](https://www.nytimes.com/subscription/games)
* Terraform [v1.0.0 or greater](https://www.terraform.io/downloads)

## Usage
* Extract cookie from authenticated NYT session and pass cookie parts into `var.nyt_cookie`
  * Cookies that are required to authenticate are: `nyt-a`, `NYT-S`, `nyt-auth-method`, and `nyt-m`
* Pass Dropbox API key into `var.dropbox_token`
* Deploy via [Terraform](https://www.terraform.io/)

## Warnings
* The Dropbox API token and NYT cookie are stored in plaintext in the Lambda environment variables.
By default, they are encrypted at rest. It is advisable to also enable [helpers for encryption](https://docs.aws.amazon.com/lambda/latest/dg/configuration-envvars.html#configuration-envvars-encryption) in transit using a customer-managed KMS key.