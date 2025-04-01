#!/bin/bash

echo "Starting the teardown of the MERN Stack AWS infrastructure..."

# Navigate to the Terraform directory
cd "$(dirname "$0")"

# Run terraform destroy
terraform destroy -auto-approve

# Confirm deletion
if [ $? -eq 0 ]; then
    echo "AWS resources destroyed successfully!"
else
    echo "Failed to destroy AWS resources."
    exit 1
fi

echo "Teardown complete."
