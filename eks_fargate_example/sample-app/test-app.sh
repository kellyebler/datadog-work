#!/bin/bash

# Test script to generate traffic to the sample app
# Run this after port-forwarding: kubectl port-forward -n sample-app service/sample-otel-app 8080:80

BASE_URL="http://localhost:8080"

echo "Testing OpenTelemetry Sample App..."
echo "=================================="
echo ""

echo "1. Testing / endpoint..."
curl -s $BASE_URL/ | jq .
echo ""

echo "2. Testing /api/users endpoint..."
curl -s $BASE_URL/api/users | jq .
echo ""

echo "3. Testing /api/process endpoint..."
curl -s $BASE_URL/api/process | jq .
echo ""

echo "4. Testing /health endpoint..."
curl -s $BASE_URL/health | jq .
echo ""

echo "=================================="
echo "Generating load (10 requests to each endpoint)..."
echo ""

for i in {1..10}; do
  curl -s $BASE_URL/ > /dev/null &
  curl -s $BASE_URL/api/users > /dev/null &
  curl -s $BASE_URL/api/process > /dev/null &
  echo "Batch $i sent..."
  sleep 0.5
done

wait

echo ""
echo "✅ Load generation complete!"
echo "Check Datadog APM for traces from service: sample-otel-app"
