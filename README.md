# terraform-aws-web-app

Deploy a single-page web application to S3 behind CloudFront and Route53.

The module recursively searches `dist_root` for exactly one `index.html`,
uploads every file in that directory to the S3 bucket under `app/`, and
invalidates `/*` after the deployed file set changes.

```hcl
module "web_app" {
  source = "github.com/tfext/terraform-aws-web-app"
  # source = "../aws-web-app"

  name        = "example"
  domain      = "app.example.com"
  dist_root   = "${path.root}/../dist"
  bucket_name = "app.example.com"

  providers = {
    aws      = aws
    aws.east = aws.east
  }
}
```

The `aws.east` provider must target `us-east-1`, where CloudFront certificates
are stored. The module derives the Route53 zone and wildcard certificate domain
by removing the first label from `domain`.

Pass `certificate_arn` to use a specific `us-east-1` certificate instead of
looking up the issued `*.<parent domain>` certificate, which fails if more than
one matches. Set `manage_dns = false` when the domain's DNS is hosted outside
Route53. No zone is looked up and no record is created, so point a CNAME for
`domain` at the `distribution_domain_name` output yourself.

The bucket uses SSE-S3 (`AES256`) default encryption, and the distribution
requires TLS 1.2 or newer (`TLSv1.2_2021`). The CloudFront function rewrites
extensionless and `.html` requests to `/index.html` for client-side routing.

## Inputs

| Name | Type | Default | Description |
|---|---|---|---|
| `name` | `string` | required | Name used for the web application's AWS resources |
| `domain` | `string` | required | Application domain name, at least three labels |
| `dist_root` | `string` | required | Directory searched recursively for exactly one `index.html` |
| `bucket_name` | `string` | required | Name of the S3 bucket that stores the application files |
| `manage_dns` | `bool` | `true` | Look up the Route53 zone and create the alias record for `domain` |
| `certificate_arn` | `string` | `null` | `us-east-1` ACM certificate ARN. The default looks the certificate up by name |

## Outputs

| Name | Description |
|---|---|
| `distribution_id` | CloudFront distribution ID |
| `distribution_domain_name` | CloudFront domain name, the CNAME target when DNS is hosted elsewhere |
| `distribution_arn` | CloudFront distribution ARN |
| `bucket` | Name of the S3 bucket that stores the application files |
