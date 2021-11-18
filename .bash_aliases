alias dlv="dlv --check-go-version=false"
alias gitsubup="git submodule update --recursive"
alias k="kubectl"
alias kg="kubectl get"
alias kgpod="kubectl get pod"
alias kgall="kubectl get --all-namespaces all"
alias kdp="kubectl describe pod"
# kubectl apply
alias kap="kubectl apply"
# kubectl delete
alias krm="kubectl delete"
alias krmf="kubectl delete -f"
# kubectl services
alias kgsvc="kubectl get service"
# kubectl deployments
alias kgdep="kubectl get deployments"
# kubectl misc
alias kl="kubectl logs"
alias kei="kubectl exec -it"
alias gocover="gotestsum --debug --jsonfile=coverage.json --junitfile=coverage.xml --hide-summary=skipped --packages='./...' -- -covermode=set -coverprofile=test_go.coverage"
alias dimg="docker images --format 'table {{.Repository}}:{{.Tag}}\t{{.ID}}\t{{.CreatedAt}}\t{{.Size}}'"
