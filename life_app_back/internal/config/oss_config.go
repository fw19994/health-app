package config

// OSSConfig 阿里云OSS配置
type OSSConfig struct {
	Endpoint        string `json:"endpoint"`
	AccessKeyID     string `json:"access_key_id"`
	AccessKeySecret string `json:"access_key_secret"`
	BucketName      string `json:"bucket_name"`
	URLPrefix       string `json:"url_prefix"`
}
