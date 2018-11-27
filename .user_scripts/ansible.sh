function ans-new-role {
    molecule init role -r $1 -d docker
}

function ans-test {
    molecule test
}

