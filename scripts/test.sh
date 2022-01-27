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
$GOBIN/gotestsum --junitfile test_results.xml --jsonfile test_results.json --format standard-verbose -- $GOFLAGS -run=$TESTS $TESTFLAGS -v -timeout=$TIMEOUT -covermode=$COVERMODE -coverpkg=$PACKAGES_COMMA -exec $DIR/test-xprog.sh github.com/mattermost/mattermost-server/v6/shared/markdown github.com/mattermost/mattermost-server/v6/shared/mfa github.com/mattermost/mattermost-server/v6/shared/mlog 2>&1 > >( tee output )

EXIT_STATUS=$?

cat test_results.json | $GOBIN/go-test-report -g 100 -t "Worldr Server test report" 
car output > test_results.log
rm output
find . -name 'cprofile*.out' -exec sh -c 'tail -n +2 "{}" >> cover.out ; rm "{}"' \;
rm -f config/*.crt
rm -f config/*.key

exit $EXIT_STATUS
