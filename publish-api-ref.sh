TAG=${1}
#HOST_URL="https://github.com/hyeongsik-won/yorkie-ios-sdk.git"
API_REF_BRANCH=api-ref-doc
CLONED_DIR="doc-repo"
HOSTING_BASE_PATH="hyeongsik-won/playground"
OUTPUT_SUB_PATH="docs"
#OUTPUT_PATH="${CLONED_DIR}/${OUTPUT_SUB_PATH}"
OUTPUT_PATH="doc-temp"

#rm -rf $CLONED_DIR
#git clone $HOST_URL $CLONED_DIR
#cd $CLONED_DIR
#git checkout $API_REF_BRANCH
#cd ..
rm -rf $OUTPUT_PATH/*
swift package --allow-writing-to-directory $OUTPUT_PATH \
    generate-documentation --target Yorkie \
    --disable-indexing \
    --output-path $OUTPUT_PATH \
    --transform-for-static-hosting \
    --hosting-base-path $HOSTING_BASE_PATH
#cd $CLONED_DIR
echo "git checkout $API_REF_BRANCH"
git checkout $API_REF_BRANCH
rm -rf docs
mv $OUTPUT_PATH docs
#git add $OUTPUT_SUB_PATH
git add docs
git commit -m "Update API reference for version ${TAG}"
git push origin HEAD:$API_REF_BRANCH
#rm -rf $CLONED_DIR
