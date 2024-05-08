##########################################
# Data Resource to Fetch AWS Account ID
##########################################

data "aws_caller_identity" "current" {}
