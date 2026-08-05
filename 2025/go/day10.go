package main

import (
	"fmt"
	"os"
	"strconv"
	"strings"
)

type ButtonState struct {
	state   int
	presses int
}

func partOne(input string) int {
	total_min_presses := 0
	processed := map[int]struct{}{}
	queue := make([]ButtonState, 1, 40)
	for line := range strings.Lines(input) {
		target_str := line[1:strings.IndexByte(line, ']')]
		button_len := len(target_str)
		target_state := 0
		for i, c := range target_str {
			if c == '#' {
				target_state |= 1 << (button_len - 1 - i)
			}
		}

		buttons := make([]int, 0, 16)
		button_start := strings.IndexByte(line, '(')
		button_end := strings.IndexByte(line, '{') - 1
		buttons_str := line[button_start:button_end]
		for button_str := range strings.SplitSeq(buttons_str, " ") {
			button := 0
			for digit := range strings.SplitSeq(button_str[1:len(button_str)-1], ",") {
				n, _ := strconv.Atoi(digit)
				button |= 1 << (button_len - 1 - n)
			}
			buttons = append(buttons, button)
		}

		queue[0] = ButtonState{}
		processed[0] = struct{}{}
		current_min_presses := 1 << 22

		for len(queue) > 0 {
			next := queue[0]
			queue = queue[1:]
			if next.state == target_state {
				current_min_presses = min(current_min_presses, next.presses)
				continue
			}
			if next.presses >= current_min_presses {
				continue
			}
			for _, button := range buttons {
				new_state := next.state ^ button
				if _, prs := processed[new_state]; !prs {
					processed[new_state] = struct{}{}
					queue = append(queue, ButtonState{state: new_state, presses: next.presses + 1})
				}
			}
		}

		total_min_presses += current_min_presses
		queue = make([]ButtonState, 1, 40)
		processed = map[int]struct{}{}
	}

	return total_min_presses
}

func main() {
	bytes, err := os.ReadFile("input/10")
	if err != nil {
		fmt.Println("error: ", err.Error())
		return
	}
	input := string(bytes)
	res := partOne(input)
	fmt.Printf("res: %d\n", res)
}
