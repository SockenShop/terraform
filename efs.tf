// preparation to deploy EFS for persistant storage
/*
resource "aws_security_group" "allow_nfs" {
  name        = "allow nfs for efs"
  description = "Allow NFS inbound traffic"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "NFS from VPC"
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = [module.vpc.vpc_cidr_block]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

}

resource "aws_efs_file_system" "ng_one_efs" {
  creation_token = "efs-ng-one"
}

resource "aws_efs_mount_target" "ng_one_efs_mt_0" {
  file_system_id  = aws_efs_file_system.ng_one_efs.id
  subnet_id       = module.vpc.private_subnets[0]
  security_groups = [aws_security_group.allow_nfs.id]
}

resource "aws_efs_mount_target" "ng_one_efs_mt_1" {
  file_system_id  = aws_efs_file_system.ng_one_efs.id
  subnet_id       = module.vpc.private_subnets[1]
  security_groups = [aws_security_group.allow_nfs.id]
}

resource "aws_efs_mount_target" "ng_one_efs_mt_2" {
  file_system_id  = aws_efs_file_system.ng_one_efs.id
  subnet_id       = module.vpc.private_subnets[2]
  security_groups = [aws_security_group.allow_nfs.id]
}
*/