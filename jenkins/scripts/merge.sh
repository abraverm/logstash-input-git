 set +x
 echo "====================="
 echo "Checking Commit"
 echo "====================="
 echo "==== Trying merge to master ===="
 pushd "$WORKSPACE/logstash-input-gitrepo_${BUILD_NUMBER}"
 # store the checked-out refspec in a branch
 git checkout -b thechange
 # switch to branch
 git checkout ci
 # and merge or fail
 if ! git merge --commit -m 'Merge the gated change' thechange; then
   echo -e "\033[01;31m===> This change has to be rebased!\033[00m"
   echo ""
   exit 1
 fi
 echo " - merge to master OK"
 echo "====================="
 echo ""
 echo "changes:"
 git diff HEAD^..HEAD
 exit 0
