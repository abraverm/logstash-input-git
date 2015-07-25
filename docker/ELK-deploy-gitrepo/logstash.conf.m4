input {
  gitrepo {
    search_params => {
      repository => "GIT_REPO"
      branch => "GIT_BRANCH"
  }
    }
}
output {
  elasticsearch_http {
    host => "ES_HOST"
    port => ES_PORT
    document_id => "%{[sha]}"
    user => "ES_USER"
    password => "ES_PASSWORD"
    index => "ES_INDEX"
  }
}
