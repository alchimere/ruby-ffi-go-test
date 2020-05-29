This is just a test to experiment some parallelism combining ruby with go using ruby FFI

How to test:

```shell
go generate
ruby ffi_test.rb
```

Even tested with ruby 1.8.7 just for fun

```shell
go generate
docker run -it --rm -v `pwd`:/app -w /app nwtgck/rvm-ruby:1.8.7 ./run.sh
```
