# Helper functions for working in Git to have a nice workflow
# - Checking out new branches correctly against a tracking branch
# - Creating pull requests against Stash or GitHub
# - Releasing your feature into your tracking branch


######################################
# Checkout a new branch, tracking against the
# currently checked out branch.
# Globals:
#   None
# Locals:
#   BRANCH         => Current branch we're using as the upstream
#   FEATURE_BRANCH => A combination of your username & branch name
# Arguments:
#   $1 => Branch name to work on (ie. ticket# DEV-123)
# Returns:
#   None
#######################################
function code-on {
    set -e -x
    local BRANCH=`git rev-parse --abbrev-ref HEAD`
    local FEATURE_BRANCH=$(whoami)"-${1}"

    git checkout -b $NEWBRANCH origin/${FEATURE_BRANCH}
    set +e +x
}

#######################################
# Create a pull-request for your work on stash
# Globals:
#   None
# Locals:
#   BRANCH          => Current branch you're working on
#   TRACKING_BRANCH => The upstream tracking branch you're merging to
#   REVIEWER_LIST   => Someone(s) to review your PR, if you want to
#   assign it
# Arguments:
#   $@ => The reviewer(s) in stash you want to assign [optional]
# Returns:
#   None
#######################################
function code-pr-stash {
    set -e -x
    local BRANCH=`git rev-parse --abbrev-ref HEAD`
    local TRACKING_BRANCH=`git rev-parse --abbrev-ref
--symbolic-full-name @{upstream} | awk '{sub(/\//," ")}1' | awk '{print
$2}'`
    local REVIEWER_LIST=()
    for REVIEWER in "$@"
    do
        if [[ ! ${REVIEWER:0:1} == "@" ]]; then
            REVIEWER="@${REVIEWER}"
        fi
        REVIEWER_LIST+="${REVIEWER} "
    done
    stash pull-request ${BRANCH} ${TRACKING_BRANCH} ${REVIEWER_LIST[@]}
    set +e +x
}

#######################################
# Create a pull-request for your work on GitHub
# Globals:
#   None
# Locals:
#   BRANCH          => Current branch you're working on
# Arguments:
#   None
# Returns:
#   None
#######################################
function code-pr-github {
    set -e -x
    local BRANCH=`git rev-parse --abbrev-ref HEAD`
    git push -u origin HEAD:${BRANCH}
    hub pull-request -h "${BRANCH}" -F -
    set +e +x
}

#######################################
# Release your now complete feature into the tracking branch
# and do some cleanup.
# The process flow is:
#  -> Pull remote tracking changes into your branch, and rebase
#     your work on top of it
#  -> Rebase your work into a single commit
#  -> Push to your remote branch, forcefully
#  -> Push your changes onto the HEAD of the tracking branch
#  -> Delete your feature branch remotely, and then locally
# Globals:
#   None
# Locals:
#   BRANCH          => Current branch you're working on
#   TRACKING_BRANCH => The upstream tracking branch you're merging to
# Arguments:
#   None
# Returns:
#   None
#######################################
function code-release {
    set -e -x
    local BRANCH=`git rev-parse --abbrev-ref HEAD`
    local TRACKING_BRANCH=`git rev-parse --abbrev-ref
--symbolic-full-name @{upstream} | awk '{sub(/\//," ")}1' | awk '{print
$2}'`
    git pull --rebase
    git rebase -i
    git push origin HEAD:${BRANCH} -f
    git push origin HEAD:${TRACKING_BRANCH}
    git push origin :${BRANCH}
    git checkout ${TRACKING_BRANCH}
    git pull
    git branch -d ${BRANCH}
    set +e +x
}

