TAG=${1}
HOST_URL="git@oss.navercorp.com:hyeongsik-won/playground.git"
HOST_DIR="./doc-repo"
HOSTING_BASE_PATH="hyeongsik-won/playground"
OUTPUT_SUB_PATH="docs"
OUTPUT_PATH="${HOST_DIR}/${OUTPUT_SUB_PATH}"

rm -rf $HOST_DIR
git clone $HOST_URL $HOST_DIR
cd $HOST_DIR
git checkout master
cd ..
ls
rm -rf $OUTPUT_PATH/*
swift package --allow-writing-to-directory $OUTPUT_PATH \
    generate-documentation --target Yorkie \
    --disable-indexing \
    --output-path $OUTPUT_PATH \
    --transform-for-static-hosting \
    --hosting-base-path $HOSTING_BASE_PATH
cd $HOST_DIR
git add $OUTPUT_SUB_PATH
git commit -m "Update API reference for version ${TAG}"
git push
rm -rf $HOST_DIR

