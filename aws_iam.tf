# --- IAM policy ---

resource "aws_iam_policy" "ansible-EC2-Policy" {
  name        = "ansible-EC2-Policy"
  path        = "/"
  policy = file("json/ansible-role-policy.json")
}

resource "aws_iam_policy" "AviController-EC2-Policy" {
  name        = "AviController-EC2-Policy"
  path        = "/"
  policy = file("json/avicontroller-role-policy.json")
}

resource "aws_iam_policy" "AviController-R53-Policy" {
  name        = "AviController-R53-Policy"
  path        = "/"
  policy = file("json/avicontroller-role-r53-policy.json")
}

resource "aws_iam_policy" "AviController-AutoScalingGroup-Policy" {
  name        = "AviController-AutoScalingGroup-Policy"
  path        = "/"
  policy = file("json/avicontroller-role-auto-scaling-group-policy.json")
}

resource "aws_iam_policy" "AviController-SNS-Policy" {
  name        = "AviController-SNS-Policy"
  path        = "/"
  policy = file("json/avicontroller-sns-policy.json")
}

resource "aws_iam_policy" "AviController-SQS-Policy" {
  name        = "AviController-SQS-Policy"
  path        = "/"
  policy = file("json/avicontroller-sqs-policy.json")
}

resource "aws_iam_policy" "AviController-ASG-Notification" {
  name        = "AviController-ASG-Notification"
  path        = "/"
  policy = file("json/avicontroller-asg-notification-policy.json")
}

resource "aws_iam_policy" "AviController-KMS-Policy" {
  name        = "AviController-KMS-Policy"
  path        = "/"
  policy = file("json/avicontroller-kms-policy.json")
}

resource "aws_iam_policy" "AviController-IAM-Policy" {
  name        = "AviController-IAM-Policy"
  path        = "/"
  policy = file("json/avicontroller-role-iam-policy.json")
}

resource "aws_iam_role" "Ansible-Refined-Role" {
  name = "Ansible-Refined-Role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

  tags = {
    tag-key = "ansible"
  }
}

resource "aws_iam_role" "AviController-Refined-Role" {
  name = "AviController-Refined-Role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
  tags = {
    tag-key = "avi"
  }
}

resource "aws_iam_role_policy_attachment" "ansible-attach1" {
  role       = aws_iam_role.Ansible-Refined-Role.name
  policy_arn = aws_iam_policy.ansible-EC2-Policy.arn
}

resource "aws_iam_role_policy_attachment" "avi-attach1" {
  role       = aws_iam_role.AviController-Refined-Role.name
  policy_arn = aws_iam_policy.AviController-EC2-Policy.arn
}

resource "aws_iam_role_policy_attachment" "avi-attach2" {
  role       = aws_iam_role.AviController-Refined-Role.name
  policy_arn = aws_iam_policy.AviController-R53-Policy.arn
}

resource "aws_iam_role_policy_attachment" "avi-attach3" {
  role       = aws_iam_role.AviController-Refined-Role.name
  policy_arn = aws_iam_policy.AviController-AutoScalingGroup-Policy.arn
}

resource "aws_iam_role_policy_attachment" "avi-attach4" {
  role       = aws_iam_role.AviController-Refined-Role.name
  policy_arn = aws_iam_policy.AviController-SNS-Policy.arn
}

resource "aws_iam_role_policy_attachment" "avi-attach5" {
  role       = aws_iam_role.AviController-Refined-Role.name
  policy_arn = aws_iam_policy.AviController-SQS-Policy.arn
}

resource "aws_iam_role_policy_attachment" "avi-attach6" {
  role       = aws_iam_role.AviController-Refined-Role.name
  policy_arn = aws_iam_policy.AviController-KMS-Policy.arn
}

resource "aws_iam_role_policy_attachment" "avi-attach7" {
  role       = aws_iam_role.AviController-Refined-Role.name
  policy_arn = aws_iam_policy.AviController-ASG-Notification.arn
}

resource "aws_iam_role_policy_attachment" "avi-attach8" {
  role       = aws_iam_role.AviController-Refined-Role.name
  policy_arn = aws_iam_policy.AviController-IAM-Policy.arn
}

resource "aws_iam_instance_profile" "Ansible-Instance-Profile" {
  name = "Ansible-Instance-Profile"
  role = aws_iam_role.Ansible-Refined-Role.name
}

resource "aws_iam_instance_profile" "AviController-Instance-Profile" {
  name = "AviController-Instance-Profile"
  role = aws_iam_role.AviController-Refined-Role.name
}

resource "aws_iam_role" "vmimport" {
  name = "vmimport"
  assume_role_policy = <<EOF
{
 "Version":"2012-10-17",
 "Statement":[
    {
       "Sid":"",
       "Effect":"Allow",
       "Principal":{
          "Service":"vmie.amazonaws.com"
       },
       "Action":"sts:AssumeRole",
       "Condition":{
          "StringEquals":{
             "sts:ExternalId":"vmimport"
          }
       }
    }
 ]
}
EOF

  tags = {
    tag-key = "avi"
  }
}

resource "aws_iam_role_policy" "vmimport" {
  name = "vmimport"
  role = aws_iam_role.vmimport.id

  policy = <<-EOF
{
   "Version":"2012-10-17",
   "Statement":[
      {
         "Effect":"Allow",
         "Action":[
            "s3:ListBucket",
            "s3:GetBucketLocation"
         ],
         "Resource": "*"
      },
      {
         "Effect":"Allow",
         "Action":[
            "s3:GetObject"
         ],
         "Resource": "*"
      },
      {
         "Effect":"Allow",
         "Action":[
            "ec2:ModifySnapshotAttribute",
            "ec2:CopySnapshot",
            "ec2:RegisterImage",
            "ec2:Describe*"
         ],
         "Resource":"*"
      }
   ]
}
  EOF
}
