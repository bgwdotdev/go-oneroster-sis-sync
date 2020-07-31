package sync

import (
	"bytes"
	"encoding/json"
	log "github.com/sirupsen/logrus"
	"github.com/spf13/viper"
	"io/ioutil"
	"net/http"
	"net/url"
)

func PostLogin() string {
	response, err := http.PostForm(
		(viper.GetString("api_url") + "/login"),
		url.Values{
			"clientid":     {viper.GetString("api_ci")},
			"clientsecret": {viper.GetString("api_cs")},
		},
	)
	if err != nil {
		log.Error(err)
	}
	defer response.Body.Close()
	token, err := ioutil.ReadAll(response.Body)
	if err != nil {
		log.Error(err)
	}
	log.Debug(string(token))
	return string(token)
}

func PutData(data interface{}, endpoint, token string) {
	json, err := json.Marshal(data)
	if err != nil {
		log.Error(err)
	}
	url := viper.GetString("api_url") + endpoint
	req, err := http.NewRequest(
		"PUT",
		url,
		bytes.NewBuffer(json),
	)
	// remove special characters from "token"\n -- implementation error?
	t := token[1 : len(token)-2]
	bearer := "Bearer " + t
	req.Header.Add("Authorization", bearer)

	client := &http.Client{}
	resp, err := client.Do(req)
	if err != nil {
		log.Error(err)
	}
	b, err := ioutil.ReadAll(resp.Body)
	if err != nil {
		log.Error(err)
	}
	log.Debug(string(b))
}
