#### List User Accounts

``` bash
dscl . list /Users | grep -v '_'
```

#### Change Account Password

``` bash
sudo passwd username
```