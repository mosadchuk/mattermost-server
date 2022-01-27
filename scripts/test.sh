#!/usr/bin/env bash
set -o pipefail

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

GO=$1
GOFLAGS=$2
PACKAGES=$3
TESTS=$4
TESTFLAGS=$5
GOBIN=$6
TIMEOUT=$7
COVERMODE=$8

PACKAGES_COMMA=$(echo $PACKAGES | tr ' ' ',')

echo "Packages to test: $PACKAGES"
echo "GOFLAGS: $GOFLAGS"

find . -name 'cprofile*.out' -exec sh -c 'rm "{}"' \;
find . -type d -name data -not -path './vendor/*' -not -path './data' | xargs rm -rf

echo "$GO test $GOFLAGS -run=$TESTS $TESTFLAGS -v -timeout=$TIMEOUT -covermode=$COVERMODE -coverpkg=$PACKAGES_COMMA -exec $DIR/test-xprog.sh $PACKAGES 2>&1 > >( tee output )"
$GO test --json $GOFLAGS -run=$TESTS $TESTFLAGS -v -timeout=$TIMEOUT -covermode=$COVERMODE -coverpkg=$PACKAGES_COMMA -exec $DIR/test-xprog.sh github.com/mattermost/mattermost-server/v6/shared/markdown github.com/mattermost/mattermost-server/v6/shared/mfa github.com/mattermost/mattermost-server/v6/shared/mlog 2>&1 > >( tee output )

EXIT_STATUS=$?

cat output | $GOBIN/go-junit-report > report.xml
cat output | $GOBIN/go-test-report 
cat output > output.txt
rm output
find . -name 'cprofile*.out' -exec sh -c 'tail -n +2 "{}" >> cover.out ; rm "{}"' \;
rm -f config/*.crt
rm -f config/*.key

exit $EXIT_STATUS
