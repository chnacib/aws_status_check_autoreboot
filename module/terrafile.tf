module "role" {
  source    = "../role"
  role_name = "lambda_status_check_role"
}

module "status_check_reboot_region1" {
  source        = "../"
  function_name = "status_check_reboot"
  region        = "sa-east-1"
  role_arn      = module.role.arn
  memory_size   = 128
}

#module "status_check_reboot_region2" {
#  source        = "../"
#  function_name = "status_check_reboot"
#  region        = "us-east-1"
#  role_arn      = module.role.arn
#  memory_size   = 128
#}