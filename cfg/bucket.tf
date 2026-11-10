resource "yandex_iam_service_account_static_access_key" "terraform_sa_key" {
  service_account_id = var.service_account_id
}

resource "yandex_storage_bucket" "main" {
  bucket     = var.bucket_name
  access_key = yandex_iam_service_account_static_access_key.terraform_sa_key.access_key
  secret_key = yandex_iam_service_account_static_access_key.terraform_sa_key.secret_key
}

resource "yandex_storage_bucket_grant" "public_read" {
  bucket     = yandex_storage_bucket.main.bucket
  access_key = yandex_iam_service_account_static_access_key.terraform_sa_key.access_key
  secret_key = yandex_iam_service_account_static_access_key.terraform_sa_key.secret_key
  grant {
    permissions = ["READ"]
    type        = "Group"
    uri         = "http://acs.amazonaws.com/groups/global/AllUsers"
  }
}

resource "yandex_storage_object" "picture" {
  bucket       = yandex_storage_bucket.main.bucket
  key          = "Vladimir_Vlasov.jpg"
  source       = "${path.module}/Vladimir_Vlasov.jpg"
  access_key   = yandex_iam_service_account_static_access_key.terraform_sa_key.access_key
  secret_key   = yandex_iam_service_account_static_access_key.terraform_sa_key.secret_key
  content_type = "image/jpeg"
  depends_on   = [yandex_storage_bucket_grant.public_read]
}
