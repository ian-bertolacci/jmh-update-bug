package com.cool.library;

public class MyClass {
  private int value;

  public MyClass( int inputValue ) {
    this.value = inputValue;
  }

  public int getValue(){
    return this.value;
  }

  public int increment( int by ) {
    this.value += by;
    return this.value;
  }

  public int increment(){
    return this.increment( 1 );
  }

  public int decrement( int by ){
    this.value -= by;
    return this.value;
  }

  public int decrement( ) {
    return this.decrement( 1 );
  }

}
