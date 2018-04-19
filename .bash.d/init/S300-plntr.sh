export PLNTR_DEPLOY_D=${HOME}/dev/plntr/docker-images/wi-deploy
export PLNTR_API_D=${PLNTR_DEPLOY_D}/src/github.com/PlanitarInc/walk-inside-api
export PLNTR_APP_D=${PLNTR_DEPLOY_D}/src/github.com/PlanitarInc/walk-inside-app
export PLNTR_OLD_D=${HOME}/dev/plntr/wi-old

plntr() {
  local project="$1"; shift
  local cmd="$1"; shift

  case "$project" in
  deploy|wi-deploy)
    case "$cmd" in
    env)
      export FLEETCTL_TUNNEL=54.152.228.143
      ;;
    cd)
      export FLEETCTL_TUNNEL=54.152.228.143
      cd $PLNTR_DEPLOY_D
      ;;
    utils)
      echo "make wi-build && make wi-push && make wi-push-today && tar czvf dist.tgz nginx/bin/dist/  && aws s3 mv dist.tgz s3://users.plntr.ca/ && echo 'rm dist.tgz && curl http://users.plntr.ca.s3.amazonaws.com/dist.tgz -o dist.tgz'"
      echo "rm -f dist.tgz && curl http://users.plntr.ca.s3.amazonaws.com/dist.tgz -o dist.tgz && rm -rf nginx/ && tar xzvf dist.tgz && rm -rf walk-inside-app/ && mv nginx/bin/dist/ walk-inside-app && nginx -s reload"
      ;;
    esac
    ;;

  api|wi-api)
    case "$cmd" in
    env)
      export GOPATH=$PLNTR_DEPLOY_D
      export PATH=$PATH:$GOPATH/bin
      ;;
    cd)
      export GOPATH=$PLNTR_DEPLOY_D
      export PATH=$PATH:$GOPATH/bin
      cd $PLNTR_API_D
      ;;
    utils)
      echo './script/cluster start'
      ;;
    esac
    ;;

  app|wi-app|web-app)
    case "$cmd" in
    env)
      export FLEETCTL_TUNNEL=54.152.228.143
      ;;
    cd)
      export FLEETCTL_TUNNEL=54.152.228.143
      cd $PLNTR_APP_D
      ;;
    utils)
      echo 'grunt clean; grunt && grunt watch;'
      ;;
    esac
    ;;

  cvc|count-von-count)
    echo 'Plntr: cvc commands are not implemented' >&2
    false
    ;;

  old|wi-old)
    case "$cmd" in
    env)
      ;;
    cd)
      cd $PLNTR_OLD_D
      ;;
    utils)
      ;;
    esac
    ;;

  *)
    echo "Usage: plntr <project> <cmd>"
    echo ""
    echo "Projects:"
    echo "  wi-deploy"
    echo "  wi-api"
    echo "  wi-app"
    echo "  wi-old"
    echo "  cvc"
    echo ""
    echo "Commands:"
    echo "  help|-h  -- see this text message"
    echo "  cd       -- cd into projects' dir"
    echo "  env      -- set project's ENV vars"
    echo "  utils    -- print useful commands for the project"

    case "$project" in
    l|list|h|help|-h) return 0 ;;
    *) return 1;;
    esac
    ;;

  esac
}
