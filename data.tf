data "aws_vpc" "selected" {
  filter {
    name   = "tag:Name"
    values = ["VPC_${upper(replace(var.app_name, "-", "_"))}"]
  }
}

data "aws_subnet_ids" "private" {
  vpc_id = data.aws_vpc.selected.id

  tags = {
    Tier = "Private"
  }
}

data "aws_subnet" "private" {
  count = length(data.aws_subnet_ids.private.ids)
  id    = tolist(data.aws_subnet_ids.private.ids)[count.index]
}
