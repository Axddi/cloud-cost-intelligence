########################################
# DynamoDB Table for Daily Cost Storage
########################################
resource "aws_dynamodb_table" "cost_table" {
  name         = "cloud-cost-history"
  billing_mode = "PAY_PER_REQUEST"

  hash_key  = "date"
  range_key = "service"

  attribute {
    name = "date"
    type = "S"
  }

  attribute {
    name = "service"
    type = "S"
  }
}
