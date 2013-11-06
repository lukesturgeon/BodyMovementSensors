class SensorDataList {

  int _data[];
  int _length;
  int _defaultValue;

  SensorDataList (int dataLength, int dataDefault) {
    _length = dataLength;
    _data = new int[dataLength];
    _defaultValue = dataDefault;

    for (int i = 0; i < _length; i++) {
      _data[i] = _defaultValue;
    }
  }

  void add (float n) {
    // just convert the float to int and then run again
    add(int(n));
  }

  void reset() {    
    for (int i = 0; i < _length; i++) {
      _data[i] = _defaultValue;
    }
  }

  void add (int n) {
    // shift down all the existing values by 1
    for ( int i = 1; i < _length; i++ ) {
      _data[i-1] = _data[i];
    }

    // add new data to the end of the list
    _data[_length-1] = n;
  }

  int get( int n ) {
    return _data[n];
  }

  int getMin() {
    return min(_data);
  }

  int getMax() {
    return max(_data);
  }
}
