This Terraform configuration creates the necessary resources to deploy an AWS Web Application Firewall (WAF) and sends the WAF logs to an on-premise instance of Splunk. Be sure to replace the placeholders in the locals block with your actual Splunk instance URL, HEC token, and desired port.

This Terraform template sets up an infrastructure on AWS using various resources such as AWS WAFv2, S3 bucket, Kinesis Firehose, IAM roles, VPC, subnets, security groups, and an application load balancer with both HTTP and HTTPS listeners.

1. `provider "aws"`: Configures the AWS provider with the "us-west-2" region.
2. `locals`: Defines local values for WAFv2 Web ACL name, S3 bucket name, Firehose stream name, Splunk configuration settings (host, token, port, and SSL validation).
3. `resource "aws_wafv2_web_acl"`: Creates an AWS WAFv2 Web ACL with the specified name, description, and scope. It has a default action to allow requests and enables CloudWatch metrics and sampled requests.
4. `resource "aws_s3_bucket"`: Creates an S3 bucket with the specified name.
5. `resource "aws_kinesis_firehose_delivery_stream"`: Creates a Kinesis Firehose delivery stream with the specified name, destination (Splunk), and configuration settings (S3 and Splunk).
6. `resource "aws_iam_role"`: Creates an IAM role for the Firehose delivery stream.
7. `resource "aws_iam_role_policy"`: Attaches a policy to the Firehose IAM role using the policy document defined in the data source.
8. `data "aws_iam_policy_document"`: Defines an IAM policy document with the necessary permissions for the Firehose delivery stream.
9. `resource "aws_vpc"`: Creates a VPC with the specified CIDR block and name tag.
10. `resource "aws_subnet"`: Creates a subnet within the VPC with the specified CIDR block and name tag.
11. `resource "aws_security_group"`: Creates a security group with the specified name and description, associated with the VPC.
12. `resource "aws_lb"`: Creates an external application load balancer with the specified name, security group, and subnet.
13. `resource "aws_lb_listener" (HTTP)`: Creates an HTTP listener for the load balancer on port 80 with a fixed-response action.
14. `resource "aws_lb_listener" (HTTPS)`: Creates an HTTPS listener for the load balancer on port 443 with a fixed-response action, SSL policy, and certificate ARN.
15. `resource "aws_wafv2_web_acl_association"`: Associates the WAFv2 Web ACL with the HTTPS listener of the load balancer.

In summary, this Terraform template creates a complete infrastructure with a WAFv2 Web ACL protecting an application load balancer, Kinesis Firehose stream for log delivery to Splunk, and necessary IAM roles and policies for permissions.

After saving the configuration to a file named main.tf, run the following commands:

```sh
terraform init
terraform apply
```

Once the resources are created, you need to configure your AWS WAF to send logs to the Kinesis Data Firehose delivery stream. Follow the instructions in the official AWS documentation to set up WAF logging for the newly created Web ACL.

Finally, make sure your on-premise Splunk instance is configured to receive data from AWS Kinesis Data Firehose. For more details, refer to the official Splunk documentation.

With these steps, you will have successfully configured a Terraform template to deploy an AWS Web Application Firewall and send logs to an on-premise instance of Splunk.