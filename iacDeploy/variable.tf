####Variables for Resource name
variable "resource_name" {
  description = "The resource name variable"
  type  = string
  default = "lab-ten-mse"
}

variable "img_tag" {
  description = "The image tag number to be assigned on the lambda"
  type = string
  default = "latest"
}
