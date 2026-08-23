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

The CloudFront function rewrites extensionless and `.html` requests to
`/index.html` for client-side routing. The module has no outputs.
