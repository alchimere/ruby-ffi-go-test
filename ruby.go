//go:generate go build -buildmode=c-shared -o ruby.so ruby.go
package main

import (
	"fmt"
	"time"

	"C"
)

var started = false
var nbLoops = 0

//export StartBackground
func StartBackground(message *C.char, msSleep C.int) {
	msg := C.GoString(message) // TODO: duplicate string ?
	if !started {
		started = true
		go func() {
			fmt.Printf("ruby.go: start goroutine\n")
			for started {
				fmt.Printf("ruby.go: %s wait %dms (%d loops)\n", msg, msSleep, nbLoops)
				<-time.After(time.Duration(msSleep) * time.Millisecond)
				nbLoops++
			}
			fmt.Printf("ruby.go: end goroutine\n")
		}()

		for i := 0; i < 3; i++ {
			go func() {
				// Always do something active
				for started {
					// loop
				}
			}()
		}
	}
}

//export StopBackground
func StopBackground() C.int {
  started = false
	return C.int(nbLoops)
}

// Ignored, library doesn't need main
func main() {}
