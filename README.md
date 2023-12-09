<div align="center">

# The Journal - Mastodon Bot

A Mastodon bot that posts articles from [TheJournal.ie](https://thejournal.ie) RSS feed.

</div>

## Requirements

- [Python](https://www.python.org/)
- [Poetry](https://python-poetry.org/)
- [AWS CLI](https://aws.amazon.com/cli/)
- [Terraform](https://www.terraform.io/)
- Mastodon access token

## Project Structure

`python` - contains the python code that is deployed into AWS Lambda function.

- `main.py` - retreives articles from RSS feed and posts to Mastodon in regular intervals over a set amount of time (defined in MINUTE_INTERVAL)
- `utils.py` - common functions and data used in lambda function

`terraform` - contains the infrastructure code to create the AWS Lambda and Cloudwatch resources.

## Deployment

Deployment is done using Terraform. Running `terraform apply` will automatically zip the lambda function code and create the required lambda and cloudwatch resources. AWS credentials should be set using AWS CLI profiles prior to running `apply`.
