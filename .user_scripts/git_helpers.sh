# Helper functions for working in Git to have a nice workflow
# - Checking out new branches correctly against a tracking branch
# - Creating pull requests against Stash or GitHub
# - Releasing your feature into your tracking branch

PR_LINK=''
JIRA_HOST=''
# Don't forget to create your ~/.netrc file to login to Jira
# machine fqdn login username password password

#######################################
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
    set -x
    local ORIGIN=`git rev-parse --abbrev-ref HEAD`
    local FEATURE_BRANCH=$(whoami)"-${1}"

    git checkout -b ${FEATURE_BRANCH} origin/${ORIGIN}
    set +x
}

#######################################
# Push your code up
# Globals:
#   None
# Locals:
#   BRANCH          => Current branch you're working on
# Arguments:
#   None
# Returns:
#   None
#######################################
function code-push {
    set -x
    local BRANCH=`git rev-parse --abbrev-ref HEAD`
    git push origin HEAD:${BRANCH}
    set +x
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
    set -x
    local BRANCH=`git rev-parse --abbrev-ref HEAD`
    local TRACKING_BRANCH=`git rev-parse --abbrev-ref --symbolic-full-name @{upstream} | awk '{sub(/\//," ")}1' | awk '{print $2}'`
    local REVIEWER_LIST=()
    for REVIEWER in "$@"
    do
        if [[ ! ${REVIEWER:0:1} == "@" ]]; then
            REVIEWER="@${REVIEWER}"
        fi
        REVIEWER_LIST+="${REVIEWER} "
    done
    stash pull-request ${BRANCH} ${TRACKING_BRANCH} ${REVIEWER_LIST[@]}
    set +x
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
    set -x
    local BRANCH=`git rev-parse --abbrev-ref HEAD`
    local TRACKING_BRANCH=`git rev-parse --abbrev-ref --symbolic-full-name @{upstream} | awk '{sub(/\//," ")}1' | awk '{print $2}'`
    local MESSAGE=`git log --oneline -1 --pretty=%s`
    git push origin HEAD:${BRANCH}
    PR_LINK=$(echo "${MESSAGE}" | hub pull-request -b "${TRACKING_BRANCH}" -h "${BRANCH}" -F -)
    echo $PR_LINK
    set +x
}

function code-pr-self {
    set -x
    local BRANCH=`git rev-parse --abbrev-ref HEAD`
    local TRACKING_BRANCH=`git rev-parse --abbrev-ref --symbolic-full-name @{upstream} | awk '{sub(/\//," ")}1' | awk '{print $2}'`
    local MESSAGE=`git log --oneline -1 --pretty=%B`
    git push origin HEAD:${BRANCH}
    PR_LINK=$(echo "${MESSAGE}" | hub pull-request -b "${TRACKING_BRANCH}" -h "${BRANCH}" -a ChristianWitts -l enhancement -F -)
    echo $PR_LINK
    set +x
}

#######################################
# Link your Pull Request to a JIRA issue
# Globals:
#   None
# Locals:
#   LINK_TITLE => The first line of your commit
#   ISSUE      => The issue#, derived from the branch name
# Arguments:
#   None
# Returns:
#   None
#######################################
function link-pr {
    set -x
    local LINK_TITLE=`git log --oneline -1 --pretty=%s`
    local ISSUE=`git rev-parse --abbrev-ref HEAD | sed 's/'$(whoami)-'//'`
    curl -n -XPOST -H "Content-Type: application/json" \
        ${JIRA_HOST}/rest/api/latest/issue/${ISSUE}/remotelink -d \
            '{"object": {"url": "'${PR_LINK}'", "title": "'${LINK_TITLE}'"}}'
    set +x
}

#######################################
# Create a PR
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
function code-pr {
    set -x
    code-pr-github
    link-pr
    set +x
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
    set -x
    local BRANCH=`git rev-parse --abbrev-ref HEAD`
    local TRACKING_BRANCH=`git rev-parse --abbrev-ref --symbolic-full-name @{upstream} | awk '{sub(/\//," ")}1' | awk '{print $2}'`
    git pull --rebase
    git rebase -i
    git push origin HEAD:${BRANCH} --force-with-lease
    git push origin HEAD:${TRACKING_BRANCH}
    git push origin :${BRANCH}
    git checkout ${TRACKING_BRANCH}
    git pull
    git branch -d ${BRANCH}
    set +x
}

# Gitignore generator helper
function gi {
    curl -L -s -o .gitignore https://www.gitignore.io/api/\$@
}

# Plot git commit history
function gitc-plot {
    git log --pretty=%ai |
        sort |
        cut -f1-2 -d' ' |
        group-by-date -d -o %F |
        sed 's/,/\t/' > /tmp/out.csv

    ~/.user_scripts/plots/git-log.plot
}
