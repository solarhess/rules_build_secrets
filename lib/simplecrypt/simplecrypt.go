package main

import (
	"crypto/aes"
	"crypto/cipher"
	"crypto/rand"
	"encoding/base64"
	"errors"
	"flag"
	"io"
	"io/ioutil"
	"os"
)

func main() {
	modeEncryptPtr := flag.Bool("encrypt", false, "Whether to encrypt or decrypt.")
	clearFilePtr := flag.String("clear_file", "", "The file containing the clear text")
	cryptFilePtr := flag.String("crypt_file", "", "The file containing the encrypted message")
	keyString := os.Getenv("CIPHER_KEY") // the cipher to use for encrypting and decrypting
	flag.Parse()

	if keyString == "" {
		panic("CIPHER_KEY environment variable was not set")
	}
	if len(keyString) != 32 {
		panic("CIPHER_KEY must be 32 characters long")
	}

	if *clearFilePtr == "" {
		panic("-clear_file required ")
	}
	if *cryptFilePtr == "" {
		panic("-crypt_file required ")
	}

	cipherKey := []byte(keyString)

	if *modeEncryptPtr {
		errEnc := encrypt(cipherKey, *clearFilePtr, *cryptFilePtr)
		if errEnc != nil {
			panic(errEnc)
		}
	} else {
		errDec := decrypt(cipherKey, *clearFilePtr, *cryptFilePtr)
		if errDec != nil {
			panic(errDec)
		}
	}
}

func encrypt(key []byte, clearFilePath string, cryptFilePath string) error {
	if _, err := os.Stat(clearFilePath); os.IsNotExist(err) {
		return errors.New("Clear file does not exist")
	}

	clearData, errdf := ioutil.ReadFile(clearFilePath)
	if errdf != nil {
		return errdf
	}
	cryptData, errCrypt := encryptString(key, string(clearData))
	if errCrypt != nil {
		return errCrypt
	}
	ioutil.WriteFile(cryptFilePath, []byte(cryptData), 0644)
	return nil
}

func decrypt(key []byte, clearFilePath string, cryptFilePath string) error {
	if _, err := os.Stat(cryptFilePath); os.IsNotExist(err) {
		return errors.New("Crypt File does not exist")
	}
	cryptData, errdf := ioutil.ReadFile(cryptFilePath)
	if errdf != nil {
		return errdf
	}
	clearData, errCrypt := decryptString(key, string(cryptData))
	if errCrypt != nil {
		return errCrypt
	}
	ioutil.WriteFile(clearFilePath, []byte(clearData), 0644)
	return nil

}

func encryptString(key []byte, message string) (encmess string, err error) {
	plainText := []byte(message)

	block, err := aes.NewCipher(key)
	if err != nil {
		return
	}

	//IV needs to be unique, but doesn't have to be secure.
	//It's common to put it at the beginning of the ciphertext.
	cipherText := make([]byte, aes.BlockSize+len(plainText))
	iv := cipherText[:aes.BlockSize]
	if _, err = io.ReadFull(rand.Reader, iv); err != nil {
		return
	}

	stream := cipher.NewCFBEncrypter(block, iv)
	stream.XORKeyStream(cipherText[aes.BlockSize:], plainText)

	//returns to base64 encoded string
	encmess = base64.URLEncoding.EncodeToString(cipherText)
	return
}

func decryptString(key []byte, securemess string) (decodedmess string, err error) {
	cipherText, err := base64.URLEncoding.DecodeString(securemess)
	if err != nil {
		return
	}

	block, err := aes.NewCipher(key)
	if err != nil {
		return
	}

	if len(cipherText) < aes.BlockSize {
		err = errors.New("Ciphertext block size is too short!")
		return
	}

	//IV needs to be unique, but doesn't have to be secure.
	//It's common to put it at the beginning of the ciphertext.
	iv := cipherText[:aes.BlockSize]
	cipherText = cipherText[aes.BlockSize:]

	stream := cipher.NewCFBDecrypter(block, iv)
	// XORKeyStream can work in-place if the two arguments are the same.
	stream.XORKeyStream(cipherText, cipherText)

	decodedmess = string(cipherText)
	return
}
