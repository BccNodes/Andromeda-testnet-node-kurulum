<table width="900px" align="center">
    <tbody>
        <tr valign="top">
            <td width="300px" align="center">
            <span><strong>Twitter</strong></span><br><br />
            <a href="https://twitter.com/bccnodes" target="_blank" rel="noopener noreferrer">
            <img height="70px" src="https://github.com/berkcaNode/berkcaNode/blob/main/twitter.png">
            </td>
            <td width="300px" align="center">
            <span><strong>Website</strong></span><br><br />
            <a href="https://bccnodes.com/" target="_blank" rel="noopener noreferrer">
            <img height="70px" src="https://github.com/berkcaNode/berkcaNode/blob/main/web.png">
            </td>
            <td width="300px" align="center">
            <span><strong>Discord</strong></span><br><br />
            <a href="https://discord.gg/sXPSXw8dUa" target="_blank" rel="noopener noreferrer">
            <img height="70px" src="https://github.com/berkcaNode/berkcaNode/blob/main/discord.png">
            </td>
            <td width="300px" align="center">
            <span><strong>BccNodes Explorer</strong></span><br><br />
            <a href="https://explorer.bccnodes.com/" target="_blank" rel="noopener noreferrer">
            <img height="70px" src="https://github.com/berkcaNode/berkcaNode/blob/main/exp%20(1).png">
            </td>
        </tr>
    </tbody>
</table>

# Andromeda Manuel node kurulumu

<p align="center">
  <img height="220" height="auto" src="andro.jpeg">
</p>

Orijinal Döküman:
>- [Doğrulayıcı kurulum talimatları](https://github.com/AndromaverseLabs/testnet)

Explorer:
>- https://explorer.bccnodes.com/androma


## Gerekli güncellemeleri ve araçları kurunuz
```
sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get install -y build-essential curl wget jq
sudo su -c "echo 'fs.file-max = 65536' >> /etc/sysctl.conf"
sudo sysctl -p
sudo apt-get install make build-essential gcc git jq chrony -y
```

## Go yükleyin (tek komut)
```
if ! [ -x "$(command -v go)" ]; then
  ver="1.18.2"
  cd $HOME
  wget "https://golang.org/dl/go$ver.linux-amd64.tar.gz"
  sudo rm -rf /usr/local/go
  sudo tar -C /usr/local -xzf "go$ver.linux-amd64.tar.gz"
  rm "go$ver.linux-amd64.tar.gz"
  echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> ~/.bash_profile
  source ~/.bash_profile
fi
```

## Ignite CLI yükle
```
git clone https://github.com/ignite/cli --depth=1
cd cli 
make install
```

## Github reposunun bir kopyasını oluşturun ve kurun
```
cd $HOME
git clone https://github.com/AndromaverseLabs/testnet
cd testnet
cd Chain
ignite chain build

```

## Nodeu çalıştırmaya hazırlanalım
```
andromad config chain-id androma-1
andromad init NODEİSMİNİZ --chain-id androma-1
```
Cüzdan oluşturalım veya var olan cüzdanı geri getirelim

```andromad keys add CÜZDANİSMİ```             #Yeni oluşturmak için

``` andromad keys add CÜZDANİSMİ --recover ``` #Cüzdan kelimlerinizi kullanarak geri getirmek için



## Genesis ve addrbook yükleyelim
```
curl https://raw.githubusercontent.com/AndromaverseLabs/testnet/main/genesis.json > ~/.androma/config/genesis.json
```

## Peers ayarlayalım
```
PEERS=4d6e5790be281a584c9226749a4d09ce14fabd02@65.108.194.40:32656,9943fed25f830a8c0eaa63efa9e637c1875bfdc8@38.242.219.158:26656,93d68953fa8760fa8491de31385f24fd397169c3@54.37.131.8:26656,9693ecb10399e10e679d269b539895253f6641e4@44.192.114.118:26656,600410eead9d886603399808ed741ea03ee34c58@3.138.138.247:26656,1b8c61cd6953892408abb2f899e6d0904cfaf36c@195.201.165.123:21076,73a679ef0a381ec15b20dca64f91b1bd0781308a@65.109.53.53:05656,5ea3936c216086937677764fbf4a2326fdb7fc6f@185.182.184.200:36656,121ed0e634e58465024d1958638193313cf07cfc@143.244.172.72:26656,fc6f7914e4beb4b5278e7ba32ec2abde97cd8082@65.109.28.177:26656,a2bfc0fb6b3c2c25577008a97b1fbf1e5df8b7c6@149.102.157.96:56656,5d216c9ed005a1c6ef4d60463c28bf1776cde600@77.52.182.194:26656

sed -i.bak -e "s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.androma/config/config.toml
```

## 26656 portunu açalım
```
sudo ufw allow 26656
```

## Servis Oluşturalım
```
sudo tee /etc/systemd/system/andromad.service > /dev/null <<EOF
[Unit]
Description=Androma Daemon
After=network-online.target

[Service]
User=$USER
ExecStart=$(which andromad) start
Restart=always
RestartSec=3
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOF
```

## Nodeu Başlatalım
```
sudo mv /etc/systemd/system/andromad.service /lib/systemd/system/
sudo systemctl daemon-reload

sudo -S systemctl enable andromad
sudo service andromad start
sudo systemctl restart sourced && sudo journalctl -u andromad -f -o cat
```

Validator Oluşturalım
```
andromad tx staking create-validator \
  --amount 1000000uandr \
  --from CÜZDANİSMİ \
  --commission-max-change-rate "0.01" \
  --commission-max-rate "0.2" \
  --commission-rate "0.07" \
  --min-self-delegation "1" \
  --pubkey  $(andromad tendermint show-validator) \
  --moniker NODEİSMİNİZ \
  --chain-id androma-1
```

### İşe yarar komutlar
Logları kontrol et
```
journalctl -fu andromad -o cat
```

Servisi başlat
```
sudo systemctl start andromad
```

Servisi durdur
```
sudo systemctl stop andromad 
```

Servisi yeniden başlat
```
sudo systemctl restart andromad 
```
Delegate stake
```
andromad tx staking delegate VALOPERADRESİNİZ 10000000uandr --from=CÜZDANİSMİ --chain-id=androma-1 --gas=auto
```

# BccNodes API && RPC && STATE-SYNC

Orijinal Döküman:
>- [BccNodes API endpoint](https://andro.api.bccnodes.com/)

>- [BccNodes RPC endpoint](https://andro.rpc.bccnodes.com/)
