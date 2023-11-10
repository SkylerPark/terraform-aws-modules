resource "aws_eip" "this" {
  instance = var.instance
  tags = merge(
    { "Name" = var.name },
    var.tags
  )
}
