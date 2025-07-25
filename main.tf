data "aws_ami" "this" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name = "name"
    values = ["amzn2-ami-hvm-*-gp2"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

resource "aws_key_pair" "this" {
  key_name   = "aws-grafana-lab-key"
  public_key = file("~/.ssh/id_ed25519.pub")

  tags = {
    Name = "mate-aws-grafana-lab"
  }
}

resource "aws_instance" "this" {
  ami           = data.aws_ami.this.id
  instance_type = "t2.micro"

  associate_public_ip_address = true
  subnet_id     = var.subnet_id
  vpc_security_group_ids = [var.security_group_id]

  key_name = aws_key_pair.this.key_name

  tags = {
    Name = "mate-aws-grafana-lab"
  }

  user_data = file("./install-grafana.sh")
  iam_instance_profile = aws_iam_instance_profile.grafana_profile.name
}


##############################################
######## Write your code here -> #############
##############################################

# 1 - create policy 

resource "aws_iam_policy" "grafana" {
  name   = "grafana-policy"
  path   = "/"

  
  policy = file("grafana-policy.json")

}

# 2 - create role 

resource "aws_iam_role" "grafana_role" {
  name = "grafana-role-asume-policy"
  assume_role_policy = file("grafana-role-asume-policy.json")
}

# 3 - create policy to role attachment 

resource "aws_iam_role_policy_attachment" "attach_grafana_policy" {
  role = aws_iam_role.grafana_role.name
  policy_arn = aws_iam_policy.grafana.arn
}

# 4 - create instance profile 

resource "aws_iam_instance_profile" "grafana_profile" {
  name = "grafana-instance-profile"
  role = aws_iam_role.grafana_role.name
}
