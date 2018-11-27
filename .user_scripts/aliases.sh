alias vi=/usr/local/bin/vim
alias em=/usr/local/Cellar/emacs/25.2/bin/emacs
alias start_netdata=/Users/christianwitts/opt/netdata/usr/sbin/netdata
alias nim_static_nix='docker run --rm -v `pwd`:/usr/src/app -w /usr/src/app nimlang/nim:alpine nim c --passL:-static'
alias nim_deadcode='nim c -d:release -d:deadCodeElim'
alias naptime='pmset displaysleepnow'
alias dtrace_tools='man -k dtrace'
alias clear_dns='sudo killall -HUP mDNSResponder'
alias prom_tunnel='ssh -N -L 9090:localhost:9090 prom'
alias start_dep_track='docker run -d -p 9999:8080 --name dependency-track -v dependency-track:/data owasp/dependency-track'
alias start_service_fabric='docker run --name sftestcluster -d -p 19080:19080 -p 19000:19000 -p 25100-25200:25100-25200 mysfcluster'
alias java_opts='java -XX:+UnlockDiagnosticVMOptions -XX:+PrintFlagsFinal -version'
alias mtr_google='sudo mtr -T -P 80 -z -j -b www.google.com'
alias ssh_unsafe='ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no'
alias rustc_best='RUSTFLAGS="-Ccodegen-units=1" CARGO_INCREMENTAL=0 cargo build --release'
alias myip='curl icanhazip.com'
alias gssh='ssh -A -o StrictHostKeyChecking=no -i ~/.ssh/gcp-ir'
alias mkcd='_(){ mkdir $1; cd $_; }; _'
alias new_playbook='cookiecutter cookiecutter-ansible-role'
alias eating_space='du -sh ./* | sort -h'

