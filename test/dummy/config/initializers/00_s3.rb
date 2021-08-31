
::S3_CREDENTIALS ||= {
  :access_key_id => ENV['AWS_KEY_TRAVIS'],
  :secret_access_key => ENV['AWS_SECRET_TRAVIS'],
  bucket: 'ish-test-3',
  :s3_region => 'us-east-1'
}
