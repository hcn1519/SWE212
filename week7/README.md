# How to compile and run programs

## Week 7

1. Open up the shell window
2. Move to week7 directory

```shell
cd week7
```

### TwentySeven

1. Complie the `TwentySeven` program

```shell
g++ TwentySeven.cpp -o TwentySeven
```

2. Run the TwentySeven program and see the result

```shell
./TwentySeven ../pride-and-prejudice.txt 
```

### TwentyEight

1. Complie the `TwentyEight` program

- TwentyEight uses coroutine features of c++ which were adopted in c++20.

```shell
g++ -std=c++20 TwentyEight.cpp -o TwentyEight
```

2. Run the `TwentyEight` program and see the result

- TwentyEight not only outputs final results, but also intermediate results as implemented in the code in the [repository](https://github.com/crista/exercises-in-programming-style/blob/master/28-lazy-rivers/tf-28.py).

```shell
./TwentyEight ../pride-and-prejudice.txt
```