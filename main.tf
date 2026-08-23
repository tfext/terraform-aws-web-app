locals {
  root_domain = replace(var.domain, "/^[^.]+\\./", "")

  index_files       = fileset(var.dist_root, "**/index.html")
  index_file        = try(one(local.index_files), null)
  application_root  = local.index_file == null ? var.dist_root : "${trimsuffix(var.dist_root, "/")}/${dirname(local.index_file)}"
  application_files = local.index_file == null ? toset([]) : fileset(local.application_root, "**")

  dist_files = {
    for relative_path in local.application_files : relative_path => {
      content_type = lookup({
        ".css"  = "text/css"
        ".html" = "text/html"
        ".js"   = "text/javascript"
        ".png"  = "image/png"
        ".svg"  = "image/svg+xml"
      }, try(regex("\\.[^.]+$", lower(relative_path)), ""), "binary/octet-stream")
      hash   = filemd5("${local.application_root}/${relative_path}")
      source = "${local.application_root}/${relative_path}"
    }
  }

  deployment_hash = sha256(jsonencode({
    for relative_path, file in local.dist_files : relative_path => file.hash
  }))
}
