package parser

import (
	"encoding/json"
	"fmt"
	"regexp"
)

var suricataMD5RegexRemovePrefix = regexp.MustCompile(`^[^\{]*`)

type IPToMacResolver interface {
	IpToMac(string) (string, error)
}

type SuricataMD5Parser struct {
	RemovePrefix   *regexp.Regexp
	ResolverIp2Mac IPToMacResolver
}

func (s *SuricataMD5Parser) Parse(line string) ([]ApiCall, error) {
	var (
		ip, mac, tid string
		endpointKey  string
		ok, found    bool
		data         map[string]interface{}
		tmp          interface{}
		err          error
	)
	jsonString := s.RemovePrefix.ReplaceAllString(line, "")
	if err = json.Unmarshal([]byte(jsonString), &data); err != nil {
		return nil, err
	}

	if tmp, found = data["md5"]; !found {
		return nil, fmt.Errorf("md5 not found")
	}

	if tid, ok = tmp.(string); !ok {
		return nil, fmt.Errorf("md5 not found")
	}

	if tmp, found = data["http_host"]; found {
		if str, ok := tmp.(string); ok && str != "" {
			endpointKey = "dstip"
		}
	} else if tmp, found = data["sender"]; found {
		if str, ok := tmp.(string); ok && str != "" {
			endpointKey = "srcip"
		}
	}

	if tmp, found = data[endpointKey]; !found {
		return nil, fmt.Errorf("endpoint not found")
	}

	if ip, ok = tmp.(string); !ok {
		return nil, fmt.Errorf("endpoint not found")
	}

	if tmp, err = s.ResolverIp2Mac.IpToMac(ip); err != nil {
		return nil, err
	}

	if mac, ok = tmp.(string); !ok {
		return nil, fmt.Errorf("endpoint not found")
	}

	data["mac"] = mac
	return []ApiCall{
		&PfqueueApiCall{
			Method: "trigger_violation",
			Params: []interface{}{
				"mac", mac,
				"tid", tid,
				"type", "suricata_md5",
			},
		},
		&PfqueueApiCall{
			Method: "metadefender_process",
			Params: []interface{}{data},
		},
	}, nil
}

func (*SuricataMD5Parser) IpToMac(ip string) (string, error) {
	return "", nil
}

func NewSuricataMD5Parser(*PfdetectConfig) (Parser, error) {
	p := &SuricataMD5Parser{
		RemovePrefix: suricataMD5RegexRemovePrefix.Copy(),
	}
	p.ResolverIp2Mac = p
	return p, nil
}
