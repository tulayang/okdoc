```
import Crypto from 'crypto';

/************************************** Hash **************************************/

var hash   = Crypto.createHash('sha1');
var result = hash.update('a')
                 .update('a') 
                 .digest('hex');        // ⇒ e0c9035898dd52fc65c41454cec9c4d2611bfb37

/************************************** Hmac **************************************/

var hmac   = Crypto.createHmac('sha1', '123456');
var result = hmac.update('a')
                 .update('a') 
                 .digest('hex');        // ⇒ ba0572b07799c0fa754a669604323537cdabeb79

/************************************* Cipher *************************************/

var cipher = Crypto.createCipher('aes192', '123456');
cipher.update('abc',  'utf8'); 
cipher.update('010', 'binary');
var result = cipher.final('hex');       // ⇒ a16a2e4e1b22f3c824f159d3b5800c06

/************************************ Decipher ************************************/

var decipher = Crypto.createDecipher('aes192', '123456');
decipher.update('a16a2e4e1b22f3c824f159d3b5800c06', 'hex'); 
var result   = decipher.final('utf8');  // ⇒ abc010

/************************************** Sign **************************************/

// $ openssl genrsa -out a.pem 1024

var sign   = Crypto.createSign('RSA-SHA256');
var result = sign.update('abc')
                 .update('010')
                 .sign(
// 密钥
`-----BEGIN RSA PRIVATE KEY-----
MIICXQIBAAKBgQClyE/ApYk91LDdnhM8qIyukbl1p1Ek3z/5bAKq7bCyfevtw3DI
JIwJIyHpGjnosR6/4phApcOqTpLNVJ/Nc0AKWwZcEFlRO7Uty3EFBU8EbTTiCV2N
NKYJIvGnxV+43ubyuYla/RjwylOktUyTVHvMz4o3mVohW4FLaEiRu6rEIQIDAQAB
AoGBAJGdLE/uFmn005UVL5hsA4WiAeBRonhcj3ipYn54YGenKv+gVwO09jtgXHy+
yHaWfIfWpBzEfOSuN0ubNPHkdS45cEtgWtvX6OYuMWNr64YRW6YevxDr4Ui7bGdh
a+Zk0fkmchjvrgycD8MDLbqTFIyFkMAd6VUOY7YVRNlxMq8xAkEA0HcxdeUCrruS
JkXmGMt5g1HkJXrqpbRuQ4vPwQM+q6QuT5fk44MGj0U42feqFWfwMnPGAh6dkN0E
nS3kC6UyuwJBAMuVkRmeAM0HkB883e9rCdnsIzfqLdCFiOKKmdrBlxqfHlEqp8bD
2DgMYTS3s+3yQqQuBjkRxNQ5/Fw7E+lInNMCQC+PghFLtlj3IljpCZ4OjiKPxGVo
rbAwgheXBkca3ml6g7ZVCTt+4Tg+qsHP51YK6JoaH8rMAVbTlgHmPmkJv5ECQGmz
l2nQkqPheF/vr19+mNfP9h0y9mSc4IyW3/knqHfHA+uqlP/rcVjwfIvtkXtK3HT3
/H0nD6YNEU0l01m9PMcCQQCGtxn5szckko+6ketDhuJpNlUxU4gux0TidgDRkDQp
iF8QnAVbE6kDLlw/M1/Kf5mXS4+EssVzy1pUx0fZpgAw
-----END RSA PRIVATE KEY-----`, 
// 签名编码
'hex');  // ⇒ 53e8f22eb539be7d37a2c1d2dc5c0d7c1f974626e11dee
         //    8085f47d4b7afb004e7d06639c431be622070786cc4d68
         //    dbc3f22f69bc3bc431d60128c78657045108b5068e9f54
         //    e1af6966330852857e5f697a2e4d3b9a30849f3b373344
         //    5f7c76251f88ddd48fbf53be444f6d817f1e7ef2784d67
         //    556e39310e1cc405f5ddef2dfc

/************************************* Verify *************************************/

// $ openssl req -key a.pem -new -x509 -out cert.pem

var verify = Crypto.createVerify('RSA-SHA256');
var result = verify.update('abc')
                   .update('010')
                   .verify(
// 公钥
`-----BEGIN CERTIFICATE-----
MIICWDCCAcGgAwIBAgIJAO5P5yii8BuLMA0GCSqGSIb3DQEBCwUAMEUxCzAJBgNV
BAYTAkFVMRMwEQYDVQQIDApTb21lLVN0YXRlMSEwHwYDVQQKDBhJbnRlcm5ldCBX
aWRnaXRzIFB0eSBMdGQwHhcNMTUwNzA5MTAzNDI3WhcNMTUwODA4MTAzNDI3WjBF
MQswCQYDVQQGEwJBVTETMBEGA1UECAwKU29tZS1TdGF0ZTEhMB8GA1UECgwYSW50
ZXJuZXQgV2lkZ2l0cyBQdHkgTHRkMIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKB
gQClyE/ApYk91LDdnhM8qIyukbl1p1Ek3z/5bAKq7bCyfevtw3DIJIwJIyHpGjno
sR6/4phApcOqTpLNVJ/Nc0AKWwZcEFlRO7Uty3EFBU8EbTTiCV2NNKYJIvGnxV+4
3ubyuYla/RjwylOktUyTVHvMz4o3mVohW4FLaEiRu6rEIQIDAQABo1AwTjAdBgNV
HQ4EFgQUGsVvaLFUxW+hMc/jVpvQXH5hzL0wHwYDVR0jBBgwFoAUGsVvaLFUxW+h
Mc/jVpvQXH5hzL0wDAYDVR0TBAUwAwEB/zANBgkqhkiG9w0BAQsFAAOBgQAXS8da
q3Ybw3+KvIZz/tAGLkPshv4J7jwIKNvlZeMX0dGZsd1faZJyrCmzZ7Go43L24zqg
rAwXOlfz+pjoGEaQSyTXOJX23ZozCGEzI2OgmLxLuk2Wfn3OUiQK8RqjrOzXosTR
3RcofenE7hTk17gjs50aDHc/hu363U3gklxnWA==
-----END CERTIFICATE-----`, 
// 签名
'53e8f22eb539be7d37a2c1d2dc5c0d7c1f974626e11dee' + 
'8085f47d4b7afb004e7d06639c431be622070786cc4d68' + 
'dbc3f22f69bc3bc431d60128c78657045108b5068e9f54' + 
'e1af6966330852857e5f697a2e4d3b9a30849f3b373344' + 
'5f7c76251f88ddd48fbf53be444f6d817f1e7ef2784d67' + 
'556e39310e1cc405f5ddef2dfc', 
// 签名编码
'hex');    // ⇒ true

/*********************************** DiffieHellman ***********************************/

var diffieHellman = Crypto.createDiffieHellman(6);
var publicKey     = diffieHellman.generateKeys('hex');
var result        = diffieHellman.computeSecret('1010', 'hex');
var result        = diffieHellman.getPrime('hex');
var result        = diffieHellman.getGenerator('hex');
var result        = diffieHellman.getPublicKey('hex');
var result        = diffieHellman.getPrivateKey('hex');
```