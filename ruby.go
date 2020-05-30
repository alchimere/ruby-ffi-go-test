//go:generate go build -buildmode=c-shared -o ruby.so ruby.go
package main

import (
	"fmt"

	"C"
)

var started = false
var nbLoops = 0

//export StartBackground
func StartBackground(message *C.char, nbGoroutines C.int) {
	msg := C.GoString(message) // TODO: duplicate string ?
	if !started {
		started = true
		fmt.Printf("ruby.go: start %d goroutines. msg: %q\n", nbGoroutines, msg)
		for i := int64(0); i < int64(nbGoroutines); i++ {
			go func(id int64) {
				// Always do something active
				for started {
					if id == 0 {
						nbLoops++
					}
				}
			}(i)
		}
	}
}

//export StopBackground
func StopBackground() C.int {
  started = false
	return C.int(nbLoops / 1000) // Avoid int overflow
}

// Ignored, library doesn't need main
func main() {}
