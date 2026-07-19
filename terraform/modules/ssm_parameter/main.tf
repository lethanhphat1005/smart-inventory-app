resource "aws_ssm_parameter" "main" {
  for_each = toset(nonsensitive(keys(var.parameters_config)))

  name = "${var.parameter_name_prefix}${nonsensitive(
    var.parameters_config[each.key].name
  )}"

  type  = "SecureString"
  value = var.parameters_config[each.key].value

  tags = merge(var.tags, {
    Name = nonsensitive(var.parameters_config[each.key].name)
  })
}
