package config

import (
	"fmt"
	"log"
	"reflect"
	"strings"

	"github.com/go-chi/jwtauth"
	"github.com/spf13/viper"
)

type conf struct {
	DatabaseDriver   string `mapstructure:"DATABASE_DRIVER"`
	DatabaseUsername string `mapstructure:"DATABASE_USERNAME"`
	DatabasePassword string `mapstructure:"DATABASE_PASSWORD"`
	DatabaseHost     string `mapstructure:"DATABASE_HOST"`
	DatabasePort     string `mapstructure:"DATABASE_PORT"`
	DatabaseDBName   string `mapstructure:"DATABASE_DB_NAME"`
	HTTP_PORT        string `mapstructure:"HTTP_PORT"`
	JWTSecret        string `mapstructure:"JWT_SECRET"`
	JWTExpiresIn     int    `mapstructure:"JWT_EXPIRES_IN"`
	TokenAuth        *jwtauth.JWTAuth
}

func getEnvsFromSystem(cfg interface{}) {
	val := reflect.ValueOf(cfg).Elem()
	typ := val.Type()

	for i := 0; i < val.NumField(); i++ {
		field := typ.Field(i)
		envKey := field.Tag.Get("mapstructure")
		if envKey != "" {
			viper.BindEnv(envKey)
		}
	}
}

func getEnvsFromConfigDotEnv() {
	viper.SetConfigFile(".env")
	viper.SetConfigType("env")

	err := viper.MergeInConfig()
	if err == nil {
		log.Println("Loding envs from: .env")
	}
}

func getEnvsFromConfigJson() {
	viper.SetConfigFile("config.json")
	viper.SetConfigType("json")

	err := viper.MergeInConfig()
	if err == nil {
		log.Println("Loding envs from: config.json")
	}
}

func getEnvsFromConfigYaml() {
	viper.SetConfigFile("config.yaml")
	viper.SetConfigType("yaml")

	err := viper.MergeInConfig()
	if err == nil {
		log.Println("Loding envs from: config.yaml")
	}
}

func getEnvs(cfg *conf) {
	getEnvsFromSystem(cfg)
	getEnvsFromConfigDotEnv()
	getEnvsFromConfigJson()
	getEnvsFromConfigYaml()
}

func checkFields(cfg conf) error {
	missingFields := []string{}
	val := reflect.ValueOf(cfg)
	typ := val.Type()
	for i := 0; i < val.NumField(); i++ {
		field := val.Field(i)
		if field.IsZero() {
			missingFields = append(missingFields, typ.Field(i).Name)
		}
	}

	if len(missingFields) > 0 {
		return fmt.Errorf("missing required configuration fields: %s", strings.Join(missingFields, ", "))
	}

	return nil
}

func Load() (*conf, error) {
	var cfg conf

	viper.AddConfigPath(".")
	viper.AutomaticEnv()
	getEnvs(&cfg)

	if err := viper.Unmarshal(&cfg); err != nil {
		log.Printf("Error unmarshalling config: %s\n", err)
		return nil, err
	}
	cfg.TokenAuth = jwtauth.New("HS256", []byte(cfg.JWTSecret), nil)

	err := checkFields(cfg)
	if err != nil {
		return nil, err
	}

	return &cfg, nil
}
