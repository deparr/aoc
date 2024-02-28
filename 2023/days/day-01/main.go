package main

import (
	"aoc/utils"
	"fmt"
)

func main() {
    lines := utils.ReadLines()
    var res int64 = 0
    var left byte
    var right byte
    for _, line := range lines {

        for i := 0; i < len(line); i++ {
            if line[i] >= '0' && line[i] <= '9' {
                left = line[i] - '0'
                break;
            }

        }

        for i := len(line)-1; i >= 0; i-- {
            if line[i] >= '0' && line[i] <= '9' {
                right = line[i] - '0'
                break;
            }

        }

        res += int64(left * 10 + right)
    }

    fmt.Println(res)
}
