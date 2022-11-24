TAG=${1}
HOST_URL="https://github.com/hyeongsik-won/yorkie-ios-sdk.git"
API_REF_BRANCH=api-ref-doc
CLONED_DIR="./doc-repo"
HOSTING_BASE_PATH="hyeongsik-won/playground"
OUTPUT_SUB_PATH="docs"
OUTPUT_PATH="${CLONED_DIR}/${OUTPUT_SUB_PATH}"

rm -rf $CLONED_DIR
git clone $HOST_URL $CLONED_DIR
cd $CLONED_DIR
git checkout $API_REF_BRANCH
cd ..
ls
rm -rf $OUTPUT_PATH/*
swift package --allow-writing-to-directory $OUTPUT_PATH \
    generate-documentation --target Yorkie \
    --disable-indexing \
    --output-path $OUTPUT_PATH \
    --transform-for-static-hosting \
    --hosting-base-path $HOSTING_BASE_PATH
cd $CLONED_DIR
git add $OUTPUT_SUB_PATH
git commit -m "Update API reference for version ${TAG}"
git push
rm -rf $CLONED_DIR

