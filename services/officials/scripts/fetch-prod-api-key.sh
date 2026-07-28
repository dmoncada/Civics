aws ssm get-parameter \
    --region us-west-2 \
    --name /civics/prod/officials-test-key \
    --with-decryption \
    --query 'Parameter.Value' \
    --output text
