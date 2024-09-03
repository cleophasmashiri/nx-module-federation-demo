#!/bin/bash

# Variables
REGION="us-east-1"  # Change to your preferred region
AMI_ID="ami-0c55b159cbfafe1f0"  # Amazon Linux 2 AMI (HVM), SSD Volume Type (64-bit x86) in us-east-1
INSTANCE_TYPE="t2.micro"
KEY_NAME="my-key-pair"  # Change to your key pair name
SECURITY_GROUP_NAME="docker-sg"
SECURITY_GROUP_DESC="Security group for Docker EC2 instance"
USER_DATA_FILE="user_data.sh"

# Create a security group
SECURITY_GROUP_ID=$(aws ec2 create-security-group \
    --group-name $SECURITY_GROUP_NAME \
    --description "$SECURITY_GROUP_DESC" \
    --region $REGION \
    --query 'GroupId' \
    --output text)

# Add rules to the security group
aws ec2 authorize-security-group-ingress --group-id $SECURITY_GROUP_ID --protocol tcp --port 22 --cidr 0.0.0.0/0 --region $REGION  # SSH
aws ec2 authorize-security-group-ingress --group-id $SECURITY_GROUP_ID --protocol tcp --port 80 --cidr 0.0.0.0/0 --region $REGION  # HTTP
aws ec2 authorize-security-group-ingress --group-id $SECURITY_GROUP_ID --protocol tcp --port 443 --cidr 0.0.0.0/0 --region $REGION  # HTTPS

# Create a user data script to install Docker
cat <<EOF > $USER_DATA_FILE
#!/bin/bash
yum update -y
amazon-linux-extras install docker -y
service docker start
usermod -a -G docker ec2-user
EOF

# Launch the EC2 instance
INSTANCE_ID=$(aws ec2 run-instances \
    --image-id $AMI_ID \
    --instance-type $INSTANCE_TYPE \
    --key-name $KEY_NAME \
    --security-group-ids $SECURITY_GROUP_ID \
    --user-data file://$USER_DATA_FILE \
    --region $REGION \
    --query 'Instances[0].InstanceId' \
    --output text)

# Wait for the instance to be running
aws ec2 wait instance-running --instance-ids $INSTANCE_ID --region $REGION

# Get the public IP of the instance
PUBLIC_IP=$(aws ec2 describe-instances \
    --instance-ids $INSTANCE_ID \
    --region $REGION \
    --query 'Reservations[0].Instances[0].PublicIpAddress' \
    --output text)

echo "EC2 Instance with Docker is up and running!"
echo "Instance ID: $INSTANCE_ID"
echo "Public IP: $PUBLIC_IP"

# Cleanup
rm $USER_DATA_FILE
