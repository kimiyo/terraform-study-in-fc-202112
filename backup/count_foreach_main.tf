provider "aws" {
    region="ap-northeast-2"
}

resource "aws_iam_user" "user_1" {
    name = "user_1"
}

resource "aws_iam_user" "user_2" {
    name = "user_2"
}

resource "aws_iam_user" "user_3" {
    name = "user_3"
}

output "user_arns" {
    value = [
        aws_iam_user.user_1.arn,
        aws_iam_user.user_2.arn,
        aws_iam_user.user_3.arn,
    ]
}

resource "aws_iam_user" "count" {
    count = 5
    name = "count-user-${count.index}"
}

output "count_user_arns" {
    value = aws_iam_user.count.*.arn
}

resource "aws_iam_user" "for_each_set" {
    for_each = toset([
        "for_each_set_user_1",
        "for_each_set_user_2",
        "for_each_set_user_3",
    ])

    name = each.key # each.value 도 있음
}

output "for_each_set_user_arns" {
   value = values(aws_iam_user.for_each_set).*.arn
}

resource "aws_iam_user" "for_each_map" {
    for_each = {
        alice={
            level = "low"
            manager = "posquit0"
        }
        bob={
            level = "mid"
            manager = "nodin"
        }
        john={
            level = "high"
            manager = "steve"
        }
    }

    name = each.key # each.value 도 있음
    tags = each.value
}

output "for_each_map_user_arns"{
    value = values(aws_iam_user.for_each_map).*.arn
}