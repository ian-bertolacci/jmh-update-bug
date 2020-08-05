package com.cool.library.benchmarks;

import org.openjdk.jmh.annotations.*;
import org.openjdk.jmh.infra.Blackhole;
import java.util.concurrent.TimeUnit;

import java.util.*;
import java.util.function.*;
import static java.lang.Math.*;

import com.cool.library.MyClass;

@BenchmarkMode(Mode.AverageTime)
@OutputTimeUnit(TimeUnit.MILLISECONDS)
@Fork(value=0)
@Measurement(iterations=10,time=10,timeUnit=TimeUnit.MILLISECONDS)
@Warmup(iterations=0)
public class MyClassBenchmark {

  public static final FactoryA factoryA = new FactoryA();

  public static class FactoryA {
    private int nextValue;

    FactoryA(){
      this.nextValue = 0;
    }

    public int createValue() {
      int returnValue = this.nextValue;
      this.nextValue += 1;
      return returnValue;
    }
  }

  @State(Scope.Thread)
  public static class StateClass {
    @Param({"1", "100000"})
    public int numOperations;

    public MyClass instance;
    public int[] data;

    @Setup(Level.Iteration)
    public void setup() {
      this.instance = new MyClass( 0 );
      this.data = new int[this.numOperations];

      for( int i = 0; i < this.numOperations; ++i ){
        this.data[i] = MyClassBenchmark.factoryA.createValue();
      }
    }
  }

  @Benchmark
  public void construct( Blackhole blackhole ){
    blackhole.consume( new MyClass(0) );
  }

  @Benchmark
  public void increment( StateClass state, Blackhole blackhole ) {
    for( int by : state.data ){
      state.instance.increment( by );
    }
    System.out.println( state.instance.getValue() );
    blackhole.consume( state.instance.getValue() );
  }

  @Benchmark
  public void decrement( StateClass state, Blackhole blackhole ) {
    for( int by : state.data ){
      state.instance.decrement( by );
    }
    System.out.println( state.instance.getValue() );
    blackhole.consume( state.instance.getValue() );
  }
}
