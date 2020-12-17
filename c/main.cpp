
#include <assert.h>
#include <iostream>
#include <stdlib.h>
#include <iomanip>


size_t encode(int value, uint8_t* output) {
    size_t outputSize = 0;
    while (value > 127) {      
        output[outputSize] = ((uint8_t)(value & 127)) | 128;
        value >>= 7;
        outputSize++;
    }
    output[outputSize++] = ((uint8_t)value) & 127;
    return outputSize;
}


int main() 
{

  int number = 150;
  uint8_t* str = (uint8_t*)calloc(8, sizeof(uint8_t));
  
  size_t size = encode(number, str);

  for (int i; i < size; ++i) {
    std::cout << std::setw(2) << std::setfill('0') << std::hex << (int)str[i] << " ";
  }

  std::cout << std::endl;
  
  return 0;
}
