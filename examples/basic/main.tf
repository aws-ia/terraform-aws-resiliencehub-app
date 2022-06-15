#####################################################################################
# Terraform module examples are meant to show an _example_ on how to use a module
# per use-case. The code below should not be copied directly but referenced in order
# to build your own root module that invokes this module
#####################################################################################

module "resiliencehub_app" {
  source      = "../.."
  rto         = 10
  rpo         = 10
  source_arns = []
}
