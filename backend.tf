terraform {
  backend "s3" {
    bucket = "bloomlessons-tutorials-terraform-states"
    key    = "k8s-fargate"
    region = "us-west-2"
  }
}
