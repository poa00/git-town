package configdomain

import (
	"fmt"
	"strconv"

	"github.com/git-town/git-town/v11/src/gohacks"
	"github.com/git-town/git-town/v11/src/messages"
)

// PushHook contains the push-hook configuration setting.
type PushHook bool

func (pushHook PushHook) Bool() bool {
	return bool(pushHook)
}

func (pushHook PushHook) Negate() NoPushHook {
	boolValue := bool(pushHook)
	return NoPushHook(!boolValue)
}

func (pushHook PushHook) String() string {
	return strconv.FormatBool(pushHook.Bool())
}

func NewPushHookRef(value, source string) (*PushHook, error) {
	parsed, err := gohacks.ParseBool(value)
	if err != nil {
		return nil, fmt.Errorf(messages.ValueInvalid, source, value)
	}
	token := PushHook(parsed)
	return &token, nil
}

// NoPushHook helps using the type checker to verify correct negation of the push-hook configuration setting.
type NoPushHook bool

func (noPushHook NoPushHook) Bool() bool {
	return bool(noPushHook)
}