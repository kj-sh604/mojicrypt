# mojicrypt

> just a fun little thing that me and a friend thought would be fun to write.

aes-256-gcm encryption with unicode-encoded output. 
turns your secrets into a wall of emojis and symbols.

## what it does

takes a plaintext message (or any file) and a passphrase, encrypts it with aes-256-gcm (256-bit key derived via scrypt), and encodes the ciphertext as non-alphanumeric unicode characters: emoji faces, animals, food, arrows, math symbols, and other fun glyphs.

## dependencies

- python 3.6+
- [pycryptodome](https://pypi.org/project/pycryptodome/)

## install

```sh
pip install pycryptodome
sudo make install
```

## usage

### encrypt (auto-generated keyfile)

```sh
# no -p or -k given — generates mojicrypt-key<epoch>_<uuid>.ukey automatically
mojicrypt encrypt "your secret message"
# no passphrase given — generated keyfile: mojicrypt-key1709500000_a1b2..ukey
# keep that file safe - you'll need it to decrypt
```

### encrypt (manual passphrase)

```sh
mojicrypt encrypt -p "mypassphrase" "hello world"
# 😁🌏🐃😉🐄🌐🌆😎😯🐗🍝🌊😮🐊😞😏☋🍣🐃😰☃🍟🍔😏...
```

### decrypt

```sh
# using a keyfile
mojicrypt decrypt -k mojicrypt-key1709500000_a1b2....ukey "😁🌏🐃😉..."

# using a passphrase
mojicrypt decrypt -p "mypassphrase" "😁🌏🐃😉🐄🌐🌆😎😯🐗🍝🌊😮🐊😞😏☋🍣🐃😰☃🍟🍔😏..."
# hello world
```

### encrypt a file

```sh
# auto-generates a keyfile, encrypts photo.jpg → photo.jpg.uc
mojicrypt encrypt -f photo.jpg

# with explicit passphrase
mojicrypt encrypt -p "mypassphrase" -f document.pdf -o document.pdf.uc
```

### decrypt a file

```sh
# using the auto-generated keyfile (strips .uc from output name automatically)
mojicrypt decrypt -k mojicrypt-key1709500000_a1b2....ukey -f photo.jpg.uc

# with explicit passphrase and output path
mojicrypt decrypt -p "mypassphrase" -f archive.tar.gz.uc -o archive.tar.gz
```

### piping

```sh
echo "secret" | mojicrypt encrypt -p "key"
cat encrypted.txt | mojicrypt decrypt -p "key"
```

### version

```sh
mojicrypt -v
```

## how it works

1. derives a 256-bit key from your passphrase using **scrypt** (N=32768, r=8, p=1)
2. encrypts plaintext with **aes-256-gcm** (12-byte nonce, 128-bit auth tag)
3. encodes the salt + nonce + tag + ciphertext as unicode glyphs (1 byte → 1 glyph)
4. decryption reverses the process — glyphs → bytes → aes-gcm decrypt

the glyph table uses 256 unique symbols from these unicode blocks:

| block               | range            | count |
|---------------------|------------------|-------|
| emoji faces         | U+1F600–U+1F63F | 64    |
| weather/nature      | U+1F300–U+1F31F | 32    |
| animals             | U+1F400–U+1F41F | 32    |
| food                | U+1F345–U+1F364 | 32    |
| misc symbols        | U+2600–U+261F   | 32    |
| arrows              | U+2190–U+219F   | 16    |
| geometric shapes    | U+25A0–U+25AF   | 16    |
| math operators      | U+2200–U+221F   | 32    |

no alphanumeric characters, spaces, or joiners. each byte maps 1:1 to a glyph.

## security

| component        | algorithm / parameter                  |
|------------------|----------------------------------------|
| encryption       | aes-256-gcm (authenticated encryption) |
| key derivation   | scrypt (N=2¹⁵, r=8, p=1)              |
| auth tag         | 128-bit gcm tag                        |
| salt             | 128-bit random                         |
| nonce            | 96-bit random                          |
| rng              | cryptographically secure (os.urandom)  |

equivalent to or exceeding the security of aes-256, sha-256, and rsa-2048.

## wire format

```
[ salt: 16 bytes ][ nonce: 12 bytes ][ tag: 16 bytes ][ ciphertext: N bytes ]
```

total overhead: 44 unicode glyphs prepended to the ciphertext.

## license

[0BSD](LICENSE)
