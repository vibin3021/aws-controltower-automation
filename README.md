# aws-controltower-automation
AWS Landing Zone Setup Using AWS Control Tower, Use Terraform to Automate Landing Zone Setup, Set up Cost Budget and Cost explorer
# AWS Control Tower Setup
## Steps
1. **Create AWS Organization**:
   - Navigate to AWS Organizations and create a new organization.
   - Enable all features for full functionality.

2. **Set Up AWS Control Tower**:
   - Choose the home region ( `us-east-1, us-west-1`).
   - Configure organizational units (OUs) (Log Archive, Audit account).
   - ('vib.logarchive@gmail.com,vib.logaudit@gmail.com')

3. **Enable AWS SSO**:
   - Configure AWS Single Sign-On (SSO) for centralized access management.

4. **Enable AWS CloudTrail**:
   - Create a trail to log API activity across all regions.

5. **Enable AWS Config**:
   - Set up AWS Config to monitor resource compliance.

6. **Enable AWS GuardDuty**:
   - Enable GuardDuty for threat detection (30-day free trial)

7. **Deploy Terraform Scripts**:
   - Use Terraform to automate the setup of VPC, subnets, security groups, and EC2 instances.

8. **Set Up AWS Budgets**:
   - Create a budget to monitor costs and set alerts for overruns.

10. **Deploy Lambda Function**:
    - Deploy a Lambda function to automate security compliance checks.
