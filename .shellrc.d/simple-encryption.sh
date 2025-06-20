function simple-encrypt() {
  echo -n Password: 
  read -s PASS
  echo

  echo "$1" | openssl aes-256-cbc -a -salt -pass "pass:$PASS"
}

function simple-decrypt() {
  echo -n Password: 
  read -s PASS
  echo

  echo "$1" | openssl aes-256-cbc -d -a -pass "pass:$PASS"
}


