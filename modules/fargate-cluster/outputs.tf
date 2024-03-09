output "name" {
  value = aws_eks_cluster.main.name
}
output "cluster_endpoint" {
  value = aws_eks_cluster.main.endpoint
}
output "cluster_ca_cert" {
  value = aws_eks_cluster.main.certificate_authority
}
output "identity" {
  value = aws_eks_cluster.main.identity
}
output "cluster_certificate_authority_data" {
  value = aws_eks_cluster.main.certificate_authority[0].data
}
