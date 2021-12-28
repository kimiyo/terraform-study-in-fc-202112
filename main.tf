provider "aws" {
    region="ap-northeast-2"
}

variable "is_john" {
    type = bool
    default = true
}

locals {
    message = var.is_john ? "Hello John" : "Hello"
}

output "message" {
    value = local.message
}

variable "internet_gateway_enabled"{
    type = bool
    default = true
}

resource "aws_vpc" "this" {
    cidr_block = "10.0.0.0/16"
    tags= {
        "Name"="jhtest"
    }
}

resource "aws_internet_gateway" "this" {
    count = var.internet_gateway_enabled ? 1 : 0

    vpc_id = aws_vpc.this.id
}

resource "aws_iam_group" "developer" {
    name = "developer"
}
resource "aws_iam_group" "employee" {
    name = "employee"
}
output "groups" {
    value = [
        aws_iam_group.developer,
        aws_iam_group.employee,
    ]
}

variable "users" {
    type = list(any)
}

resource "aws_iam_user" "this" {
    for_each = {
        for user in var.users :
        user.name => user
    }
    name = each.key

    tags = {
        level = each.value.level
        role = each.value.role
    }
}

resource "aws_iam_user_group_membership" "this"{
    for_each = {
        for user in var.users :
        user.name => user
    }
    user = each.key
    groups = each.value.is_developer ? [aws_iam_group.developer.name, aws_iam_group.employee.name] : [aws_iam_group.employee.name]
}

locals {
    developers = [
        for user in var.users:
        user
        if user.is_developer
    ]
}

resource "aws_iam_user_policy_attachment" "developer" {
    for_each = {
        for user in local.developers :
        user.name => user
    }

    user = each.key
    policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
    depends_on = [
      aws_iam_user.this
    ]
}

output "developers" {
    value = local.developers
}

output "high_level_users" {
    value = [
        for user in var.users:
        user
        if user.level > 5
    ]
}