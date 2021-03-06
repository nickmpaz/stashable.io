#!/bin/bash

while getopts e: flag
do
    case "${flag}" in
        e) branch=${OPTARG};;
    esac
done

case $branch in
  master) 
    environment="prod";
    GOOGLE_POOL_ID=$GOOGLE_POOL_ID_PROD;
    GOOGLE_POOL_SECRET=$GOOGLE_POOL_SECRET_PROD;
    ;;
  develop) 
    environment="dev";
    GOOGLE_POOL_ID=$GOOGLE_POOL_ID_DEV;
    GOOGLE_POOL_SECRET=$GOOGLE_POOL_SECRET_DEV;
    ;;
esac

echo "Deploying to $environment";

# initialize terraform 

cd terraform 
terraform init
cd ..

# install and initialize amplify

cd frontend

sudo npm install -g @aws-amplify/cli
mkdir ~/.aws && touch ~/.aws/credentials && touch ~/.aws/config

export AMPLIFY_APP_ID=d1ud1g6a0miz27
export AMPLIFY_APP_NAME=Dolphin

export VUECONFIG="{\
\"SourceDir\":\"src\",\
\"DistributionDir\":\"dist\",\
\"BuildCommand\":\"npm run-script build\",\
\"StartCommand\":\"npm run-script serve\"\
}"

export AWSCLOUDFORMATIONCONFIG="{\
\"configLevel\":\"project\",\
\"useProfile\":false,\
\"profileName\":\"default\",\
\"accessKeyId\":\"$AWS_ACCESS_KEY_ID\",\
\"secretAccessKey\":\"$AWS_SECRET_ACCESS_KEY\",\
\"region\":\"us-east-1\"\
}"

export FRONTEND="{\
\"frontend\":\"javascript\",\
\"framework\":\"vue\",\
\"config\":$VUECONFIG\
}"

export AMPLIFY="{\
\"projectName\":\"$AMPLIFY_APP_NAME\",\
\"appId\":\"$AMPLIFY_APP_ID\",\
\"envName\":\"$environment\",\
\"defaultEditor\":\"vscode\"\
}"

export PROVIDERS="{\
\"awscloudformation\":$AWSCLOUDFORMATIONCONFIG\
}"

export AUTHCONFIG="{\
\"googleAppIdUserPool\":\"$GOOGLE_POOL_ID\",\
\"googleAppSecretUserPool\":\"$GOOGLE_POOL_SECRET\"\
}"

export CATEGORIES="{\
\"auth\":$AUTHCONFIG\
}"

amplify pull \
--amplify $AMPLIFY \
--frontend $FRONTEND \
--providers $PROVIDERS \
--categories $CATEGORIES \
--yes


npm ci
npm run build:$environment
aws s3 sync --delete ./dist s3://$(cd ../terraform && terraform output bucket_$environment)
