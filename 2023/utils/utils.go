package utils

import (
	"bufio"
	"fmt"
	"os"
)

// Turn stdin into lines
func ReadLines() []string {
	lines := make([]string, 0, 20)

	rd := bufio.NewReader(os.Stdin)
    buf := make([]byte, 1024)

	buf, prefix, err := rd.ReadLine()
	for err == nil {
        lines = append(lines, string(buf))
		buf, prefix, err = rd.ReadLine()
		if prefix {
			fmt.Fprintln(os.Stderr, "Prefix hit in utils.ReadLine")
            break
		}
	}

	return lines
}
