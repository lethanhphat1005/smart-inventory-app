module "networking" {
  source = "./modules/networking"

  project_name = var.project_name
  tags         = var.tags

  region            = var.region
  vpc_cidr          = var.vpc_cidr
  public_subnets    = var.public_subnets
  allowed_ssh_cidrs = var.allowed_ssh_cidrs
  enable_eip        = true
}

module "iam" {
  source = "./modules/iam"

  project_name = var.project_name
  tags         = var.tags

  enable_cloudwatch_agent_policy = true
}

module "ec2" {
  source = "./modules/ec2"

  project_name = var.project_name
  tags         = var.tags

  instance_type             = "t3.small"
  iam_instance_profile_name = module.iam.instance_profile_name
  subnet_id                 = module.networking.public_subnet_ids[0]
  security_group_ids        = [module.networking.backend_security_group_id]

  create_key_pair = true
  key_pair_name   = "${var.project_name}-ec2-launch-key"
  public_key      = file(var.public_key_path)

  has_associate_public_ip     = true
  has_disable_api_termination = false

  root_volume_size = 20
  root_volume_type = "gp3"

  enable_eip_association = true
  eip_allocation_id      = module.networking.ec2_eip_allocation_id
}

module "cloudwatch" {
  source = "./modules/cloudwatch"

  project_name = var.project_name
  tags         = var.tags
  region       = var.region

  instance_id = module.ec2.instance_id
  sns_email   = var.sns_email

  enable_attached_ebs_alarm = false
  enable_disk_widget        = false
  enable_disk_alarm         = false

  cpu_alarm = {
    threshold          = 80
    period             = 300
    evaluation_periods = 2
  }

  disk_alarm = {
    threshold          = 85
    period             = 300
    evaluation_periods = 1
  }
}